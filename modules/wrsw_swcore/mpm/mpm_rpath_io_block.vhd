-------------------------------------------------------------------------------
-- Title        : Multiport Memory - Read Path IO Block
-- Project      : White Rabbit Switch
-------------------------------------------------------------------------------
-- File         : mpm_rpath_io_block.vhd
-- Author       : Tomasz Włostowski, Maciej Lipinski
-- Company      : CERN BE-CO-HT
-- Created      : 2012-02-12
-- Last update  : 2013-08-27
-- Platform     : FPGA-generic
-- Standard     : VHDL'93
-------------------------------------------------------------------------------
--
-- Copyright (c) 2012 - 2013 CERN / BE-CO-HT
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gencores_pkg.all;
use work.genram_pkg.all;

entity mpm_rpath_io_block is
  
  generic (
    g_num_pages            : integer;
    g_data_width           : integer;
    g_page_addr_width      : integer;
    g_page_size            : integer;
    g_partial_select_width : integer;
    g_ratio                : integer;
    g_ll_data_width        : integer;
    g_max_oob_size         : integer;
    g_min_packet_size      : integer := 32; -- words
    g_max_packet_size      : integer);

  port (
    clk_io_i   : in std_logic;
    rst_n_io_i : in std_logic;

-- Read Port Interface
    rport_d_o        : out std_logic_vector(g_data_width-1 downto 0);
    rport_dvalid_o   : out std_logic;
    rport_dlast_o    : out std_logic;
    rport_dsel_o     : out std_logic_vector(g_partial_select_width-1 downto 0);
    rport_dreq_i     : in  std_logic;
    rport_abort_i    : in  std_logic;
    rport_pg_req_o   : out std_logic;
    rport_pg_valid_i : in  std_logic;
    rport_pg_addr_i  : in  std_logic_vector(g_page_addr_width-1 downto 0);

-- Linked List Interface
    ll_req_o   : out std_logic;
    ll_grant_i : in  std_logic;
    ll_addr_o  : out std_logic_vector(g_page_addr_width-1 downto 0);
    ll_data_i  : in  std_logic_vector(g_ll_data_width  -1 downto 0);

-- Page FIFO interface
    pf_full_i     : in  std_logic;
    pf_we_o       : out std_logic;
    pf_fbm_addr_o : out std_logic_vector(f_log2_size(g_num_pages * g_page_size / g_ratio) - 1 downto 0);
    pf_pg_lines_o : out std_logic_vector(f_log2_size(g_page_size / g_ratio + 1)-1 downto 0);

-- Data FIFO interface
    df_empty_i : in  std_logic;
    df_flush_o : out std_logic;
    df_rd_o    : out std_logic;
    df_d_i     : in  std_logic_vector(g_data_width-1 downto 0)
    );

end mpm_rpath_io_block;

architecture behavioral of mpm_rpath_io_block is

  constant c_lines_per_page     : integer := g_page_size/g_ratio;
  constant c_page_lines_width   : integer := f_log2_size(c_lines_per_page + 1);
  constant c_page_size_width    : integer := f_log2_size(g_page_size + 1);
  constant c_word_count_width   : integer := f_log2_size(g_max_packet_size + 1);
  constant c_max_oob_size_width : integer := f_log2_size(g_max_oob_size + 1);
  
  function f_fast_div_pagesize
    (x : unsigned;
     y : integer) return unsigned is

    type t_div_factor is record
      adjust : integer range 0 to 15;
      mul    : integer range 0 to 4095;
      shift  : integer range 0 to 12;
    end record;

    type t_div_factor_array is array (1 to 16) of t_div_factor;

    constant c_div_factors : t_div_factor_array := (
      (0, 1, 0),                        -- ratio == 1
      (1, 1, 1),                        -- ratio == 2
      (3, 85, 8),                       -- ratio == 3
      (3, 1, 2),                        -- ratio == 4
      (5, 51, 8),                       -- ratio == 5
      (6, 341, 11),                     -- ratio == 6
      (7, 73, 9),                       -- ratio == 7
      (7, 1, 3),                        -- ratio == 8
      (9, 227, 11),                     -- ratio == 9
      (10, 409, 12),                    -- ratio == 10
      (11, 93, 10),                     -- ratio == 11
      (12, 341, 12),                    -- ratio == 12
      (13, 157, 11),                    -- ratio == 13
      (14, 73, 10),                     -- ratio == 14
      (15, 17, 8),                      -- ratio == 15
      (15, 1, 4));                      -- ratio == 16

    variable tmp    : unsigned(x'left + 12 downto 0);
    variable result : unsigned(c_page_lines_width-1 downto 0);

  begin

    tmp := (x+to_unsigned(c_div_factors(y).adjust, 4)) * to_unsigned(c_div_factors(y).mul, 12);

    return tmp(c_page_lines_width - 1 + c_div_factors(y).shift downto c_div_factors(y).shift);
  end f_fast_div_pagesize;


  type t_ll_entry is record
    valid     : std_logic;
    eof       : std_logic;
    next_page : std_logic_vector(g_page_addr_width-1 downto 0);
    dsel      : std_logic_vector(g_partial_select_width-1 downto 0);
    size      : std_logic_vector(f_log2_size(g_page_size + 1)-1 downto 0);
  end record;



  -- Page fetcher signals
  type   t_page_fetch_state is (FIRST_PAGE, NEXT_LINK, WAIT_LAST_ACK, WAIT_ACK, NASTY_WAIT);
  signal page_state : t_page_fetch_state;
  signal cur_page   : std_logic_vector(g_page_addr_width-1 downto 0);
  signal cur_ll     : t_ll_entry;
  signal fvalid_int : std_logic;

  -- Page fetch <> FIFO / output FSM signals

  -- Address of the current page
  signal fetch_pg_addr  : std_logic_vector(g_page_addr_width-1 downto 0);
  -- Number of words in the page (1 = 1 word...g_page_size-1 == full page)
  signal fetch_pg_words : unsigned(f_log2_size(g_page_size+1)-1 downto 0);
  -- Number of FBM lines used by this page (1 = 1 line, etc.)
  signal fetch_pg_lines : unsigned(c_page_lines_width-1 downto 0);
  -- Partial select bits for the last word of the packet
  signal fetch_dsel     : std_logic_vector(g_partial_select_width-1 downto 0);
  -- Is the page the last one in the current chain?
  signal fetch_last     : std_logic;
  -- Is the page the first one in the current chain?
  signal fetch_first    : std_logic;
  -- Acknowledge of the transfer on pg_addr/ast/valid/remaining/dsel lines. The
  -- fetcher will proceed with the next page/packet only after getting an ACK.
  signal fetch_ack      : std_logic;
  -- When HI, pg_addr/last/remaining/dsel contain a valid page entry.
  signal fetch_valid    : std_logic;
  -- When HI, fetcher aborts fetching the current page chain and proceeds to the
  -- next packet.
  signal fetch_abort    : std_logic;
  
  -- Datapath signals
  signal df_we_d0      : std_logic;
  signal last_page     : std_logic;
  signal words_total   : unsigned(c_word_count_width-1 downto 0);
  signal dsel_words_total   : unsigned(c_word_count_width-1 downto 0);
  signal words_xmitted : unsigned(c_word_count_width-1 downto 0);

  signal last_int, d_valid_int, df_rd_int : std_logic; --dsel--
  signal pf_we_int                          : std_logic;

  signal ll_req_int, ll_grant_d0, ll_grant_d1 : std_logic;
  signal counters_equal : std_logic;
  signal data_dsel_valid  : std_logic;
  signal wait_first_fetched : std_logic;
  signal wait_next_valid_ll_read : std_logic;
  signal rport_pg_req  : std_logic;
  
  signal start_cnt: unsigned(f_log2_size(g_page_size+1)-1 downto 0);
  signal min_pck_size_reached : std_logic;
  
  signal d_counter_equal : std_logic;
  signal pre_fetch       : std_logic;
  signal supress_pre_fetch       : std_logic;
  
  -- indicates the count (word number) from which the last page starts,
  -- this is to activate output req_page signal only on last page
  signal last_pg_start_ptr  : unsigned(c_word_count_width-1 downto 0);
  signal allow_rport_pg_req : std_logic;

  -- signals to make the abort
  signal abort_wait_cnt   : unsigned(4 downto 0);
  signal rport_abort_d : std_logic;
  signal long_rst_at_abort : std_logic;
  
  constant wait_at_abort : integer := 3; -- keeps the long_rst_at_abort HIGH for
                                         -- (2 + wait_at_abort) cycles
                                         -- the number (2) was derived experimentally (lowest 
                                         -- working)
  signal fetch_pg_words_new : std_logic;
  signal fetch_pg_words_used : std_logic;

begin  -- behavioral
  
  -- process to generate long abort signal. it is needed to make sure
  -- that all the other parts of MPM's read_path reset and clear properly
  -- 
  p_gen_abort_d : process(clk_io_i)
  begin
    if rising_edge(clk_io_i) then
      if rst_n_io_i = '0' then
        rport_abort_d <= '0';
        abort_wait_cnt<= (others =>'0');
      else
        if(rport_abort_i = '1') then
          rport_abort_d <= '1';
          abort_wait_cnt <= to_unsigned(wait_at_abort, abort_wait_cnt'length);
        elsif(abort_wait_cnt = to_unsigned(0, abort_wait_cnt'length)) then
          rport_abort_d  <= '0';
        else
          abort_wait_cnt <= abort_wait_cnt - 1;
        end if;
      end if;
    end if;
  end process;

  -- this signal resets all the process (async) on abort
  long_rst_at_abort <= '1' when (rport_abort_i = '1' or rport_abort_d ='1') else '0';

  p_gen_page_ack : process(clk_io_i)
  begin
    if rising_edge(clk_io_i) then
      if rst_n_io_i = '0' or long_rst_at_abort = '1' then
        fetch_ack <= '0';
      else
        fetch_ack <= pf_we_int;
      end if;
    end if;
  end process;

  pf_we_int     <= fetch_valid and not pf_full_i;
  pf_we_o       <= pf_we_int;
  pf_fbm_addr_o <= std_logic_vector(resize(unsigned(fetch_pg_addr) * to_unsigned(c_lines_per_page, c_page_lines_width), pf_fbm_addr_o'length));
  pf_pg_lines_o <= std_logic_vector(fetch_pg_lines);

  -- ML (bugfix: dreq=LOW on one but last word caused readout problem and dlast to be HIGH
  --             when dvalid=LOW and not yet the last word)
  --counters_equal <= '1' when (words_total = words_xmitted) else '0';
  counters_equal <= '1' when (words_total = words_xmitted and rport_dreq_i = '1') else '0';

  wait_next_valid_ll_read <= '1' when ((words_total <  words_xmitted+2) and 
                                       last_int   = '0'               and 
                                       page_state  /= FIRST_PAGE        and
                                       pre_fetch  = '0'               and
                                       fetch_first  = '0' )             else '0';
  min_pck_size_reached  <= '0' when (start_cnt < to_unsigned(g_min_packet_size, start_cnt'length ) ) else '1';
  
  p_count_words : process(clk_io_i)
  begin
    if rising_edge(clk_io_i) then
      if rst_n_io_i = '0' or (last_int = '1' and d_valid_int = '1') 
                                 or long_rst_at_abort = '1' then  -- ML: abort by reset
        fetch_pg_words_used <= '0';
        -- ML : pre-fetching
        if(pre_fetch = '1' and fetch_pg_words_new='1') then
          words_total      <= resize(fetch_pg_words, words_total'length);
          fetch_pg_words_used <= '1';
        else
          words_total     <= (others => '0');
        end if;
        -----
        words_xmitted   <= to_unsigned(1, words_xmitted'length);
        d_counter_equal <= '0';
      else
        fetch_pg_words_used <= '0';
        if(df_rd_int = '1') then
          words_xmitted <= words_xmitted + 1;
        end if;

        if(fetch_ack = '1' and pre_fetch = '0') then
          if(fetch_first = '1' ) then
            words_total      <= resize(fetch_pg_words, words_total'length);
            fetch_pg_words_used <= '1';
          else
            words_total      <= words_total      + fetch_pg_words;
            fetch_pg_words_used <= '1';
          end if;
        end if;

        d_counter_equal    <= counters_equal;
      end if;
    end if;
  end process;
  
  -- ML: this is for the case when we got empty_i HIGH on the very last word
  last_int <= d_counter_equal and not counters_equal;
  ---------

  df_rd_int <= rport_dreq_i and not (df_empty_i or last_int or wait_first_fetched or wait_next_valid_ll_read);
  
  df_rd_o   <= df_rd_int;

  p_gen_d_valid : process(clk_io_i)
  begin
    if rising_edge(clk_io_i) then
      if rst_n_io_i = '0' or long_rst_at_abort = '1' then  -- ML: abort by reset
        d_valid_int <= '0';
      else
        
        d_valid_int       <= df_rd_int;

      end if;
    end if;
  end process;

  p_gen_pre_fetch : process(clk_io_i)
  begin
    if rising_edge(clk_io_i) then
      if rst_n_io_i = '0'  or long_rst_at_abort = '1' then -- ML: abort by reset
        pre_fetch         <= '0';
        supress_pre_fetch <= '0';
      else
        
        if(fetch_last = '1' and rport_pg_valid_i = '1' and  last_int = '0' and supress_pre_fetch = '0') then
          pre_fetch <= '1';
        elsif(pre_fetch='1' and last_int = '1') then
          pre_fetch <= '0';
        end if;
        
        if(page_state  = FIRST_PAGE and last_int = '1' and pre_fetch = '0' and rport_pg_valid_i = '0') then
          supress_pre_fetch <= '1';
        elsif(rport_pg_valid_i = '1') then
          supress_pre_fetch <= '0';
        end if;

      end if;
    end if;
  end process;

  df_flush_o <= last_int or long_rst_at_abort;-- counters_equal;
  
  rport_dvalid_o <= d_valid_int;

  rport_dlast_o  <= last_int;
  rport_d_o      <= df_d_i;
  rport_dsel_o   <= (others =>'1'); --dsel--
  rport_pg_req_o <= rport_pg_req;
-------------------------------------------------------------------------------
-- Page fetcher logic
-------------------------------------------------------------------------------  

  -- pointer to the next page (shared with page size and partial select)
  cur_ll.next_page <= ll_data_i(g_page_addr_width-1 downto 0);
  -- 1: last page in the chain
  cur_ll.eof       <= ll_data_i(g_ll_data_width-2);
  -- 1: page is valid
  cur_ll.valid     <= ll_data_i(g_ll_data_width-1);
  -- 1: number of the words in page (1 = 1 word .. g_page_size-1 = full page)
  cur_ll.size      <= ll_data_i(c_page_size_width-1 downto 0);

  fetch_valid <= fvalid_int and not fetch_ack;

  p_count_down_start : process(clk_io_i)
  begin
    if rising_edge(clk_io_i) then
      if rst_n_io_i = '0' or rport_pg_req = '1' or long_rst_at_abort = '1' then -- ML: abort by reset
        start_cnt <= to_unsigned(0, start_cnt'length);
      else
        if(fetch_first = '1' ) then
          start_cnt <= start_cnt + 1;
        end if;
      end if;
    end if;  
  end process;
  
  p_page_fsm : process(clk_io_i)
  begin
    if rising_edge(clk_io_i) then
      if rst_n_io_i = '0' or long_rst_at_abort = '1' then -- ML: abort by reset
        page_state <= FIRST_PAGE;

        fvalid_int     <= '0';
        rport_pg_req <= '0';
        ll_req_int       <= '0';
        ll_grant_d0 <= '0';
        ll_grant_d1 <= '0';
        wait_first_fetched <='1';
        fetch_first     <= '0';
        last_pg_start_ptr <= (others => '0');
        fetch_last     <= '0';
        fetch_pg_words_new <= '0';
      else

        ll_grant_d0 <= ll_grant_i;
        ll_grant_d1 <= ll_grant_d0;

        if((cur_ll.valid = '1' or min_pck_size_reached = '1' or page_state = WAIT_ACK or page_state = WAIT_LAST_ACK) and fetch_first = '1') then
          wait_first_fetched <='0';
        elsif(fetch_first = '1' and (df_empty_i = '0' or min_pck_size_reached = '0') and  pre_fetch = '0') then
          wait_first_fetched <='1';
        end if;

        if(fetch_pg_words_used = '1') then
          fetch_pg_words_new <= '0';
        end if;

        case page_state is
-- request the 1st page of the packet from the Read port interface. Once got
-- the 1st address, go to FIRST_LL state
          when FIRST_PAGE =>

            if(rport_pg_valid_i = '1') then
              rport_pg_req <= '0';
              cur_page       <= rport_pg_addr_i;
              ll_req_int       <= '1';
              ll_addr_o      <= rport_pg_addr_i;
              page_state     <= NEXT_LINK;
              fetch_first    <= '1';
--          ML:  start pre-fetching well in advance even if the payload is more-or-less equal to 
--               page-size-multiple (always starts in the middle of pre-last page)
            elsif(words_xmitted + to_unsigned(g_page_size/2, words_total'length) >= last_pg_start_ptr and
                  pre_fetch = '0' ) then  --ML not to start prefatching next page one already done so
              rport_pg_req <= '1';
            end if;

-- fetch the length (or the link to the next packet) from the LL for the
-- current page
          when NEXT_LINK =>
            
            if(ll_grant_d1 = '1' and cur_ll.valid = '1') then
              cur_page  <= cur_ll.next_page;
              ll_addr_o <= cur_ll.next_page;

              if(cur_ll.eof = '1') then
                page_state     <= WAIT_LAST_ACK;
                fetch_pg_words <= unsigned(cur_ll.size);
                fetch_pg_words_new <= '1';
                fetch_pg_lines <= f_fast_div_pagesize(unsigned(cur_ll.size), g_ratio);
                fetch_pg_addr  <= cur_page;
                fvalid_int     <= '1';
                fetch_last     <= '1';
                
                -- remember the total up to before the last page starts
                if(fetch_first = '1') then -- this is first and last page
                  last_pg_start_ptr <= resize(unsigned(cur_ll.size), words_total'length );
                else
                  last_pg_start_ptr <= words_total;
                end if;
                
              else
              
                last_pg_start_ptr <= (others =>'0');
                
                page_state <= WAIT_ACK;
                
                fetch_pg_words <= to_unsigned(g_page_size, fetch_pg_words'length);
                fetch_pg_words_new <= '1';
                fetch_pg_lines <= to_unsigned(c_lines_per_page, fetch_pg_lines'length);
                fetch_pg_addr  <= cur_page;
                fetch_pg_addr  <= cur_page;
                fvalid_int     <= '1';
                if(fetch_first = '1') then -- prefetching conditin
                  fetch_last     <= '1';
                else                       -- normal condition
                  fetch_last     <= '0';
                end if;
              end if;
              ll_req_int <= '0';
            else
              ll_req_int <= '1';
            end if;

          when WAIT_ACK =>
            if(fetch_ack = '1') then
              fetch_first <= '0';
              fvalid_int  <= '0';
              if(pre_fetch = '1' and last_int = '0') then
                -- this is the situation when we passed first page to FBM, but
                -- the previous frame is still being transmitted to OB
                ll_req_int    <= '0';
                page_state     <= NASTY_WAIT;
              else
                ll_req_int    <= '1';
                page_state <= NEXT_LINK;
              end if;
            end if;

          when WAIT_LAST_ACK =>
            if(fetch_ack = '1') then
              fetch_first    <= '0';
              fvalid_int     <= '0';
              page_state     <= FIRST_PAGE;
            end if;
          when NASTY_WAIT =>
            if(last_int = '1') then
              page_state <= NEXT_LINK;
            end if;
            
        end case;
      end if;
    end if;
  end process;

  ll_req_o <= ll_req_int and not (ll_grant_i or ll_grant_d0 or ll_grant_d1);
  
end behavioral;
