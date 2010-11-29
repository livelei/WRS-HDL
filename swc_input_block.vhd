-------------------------------------------------------------------------------
-- Title      : Input block
-- Project    : WhiteRabbit switch
-------------------------------------------------------------------------------
-- File       : swc_input_block.vhd
-- Author     : Maciej Lipinski
-- Company    : CERN BE-Co-HT
-- Created    : 2010-10-28
-- Last update: 2010-11-01
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This block controls input to SW Core. It consists of few 
-- processes:
-- 1) PCK_FSM - the most important, it controls interaction between 
--    Fabric Interface and Multiport Memory
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-------------------------------------------------------------------------------
--
-- Copyright (c) 2010 Maciej Lipinski / CERN
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
-- Revisions  :
-- Date        Version  Author   Description
-- 2010-11-01  2.0      mlipinsk created

-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.swc_swcore_pkg.all;


entity swc_input_block is

  port (
    clk_i   : in std_logic;
    rst_n_i : in std_logic;

-------------------------------------------------------------------------------
-- Fabric I/F  
-------------------------------------------------------------------------------

    tx_sof_p1_i    : in  std_logic;
    tx_eof_p1_i    : in  std_logic;
    tx_data_i      : in  std_logic_vector(c_swc_data_width - 1 downto 0);
    tx_ctrl_i      : in  std_logic_vector(c_swc_ctrl_width - 1 downto 0);
    tx_valid_i     : in  std_logic;
    tx_bytesel_i   : in  std_logic;
    tx_dreq_o      : out std_logic;
    tx_abort_p1_i  : in  std_logic;
    tx_rerror_p1_i : in  std_logic;
-------------------------------------------------------------------------------
-- I/F with Page allocator (MMU)
-------------------------------------------------------------------------------    

    -- indicates that a port X wants to write page address of the "write" access
    mmu_page_alloc_req_o  : out  std_logic;
    
    
    mmu_page_alloc_done_i : in std_logic;

    -- array of pages' addresses to which ports want to write
    mmu_pageaddr_i : in  std_logic_vector(c_swc_page_addr_width - 1 downto 0);
    
    mmu_pageaddr_o : out  std_logic_vector(c_swc_page_addr_width - 1 downto 0);
    
    -- force freeing package starting with page outputed on mmu_pageaddr_o
    mmu_force_free_o   : out std_logic;
    
    mmu_force_free_done_i : in std_logic;
    
    mmu_force_free_addr_o : out std_logic_vector(c_swc_page_addr_width - 1 downto 0);
    
    -- set user count to the already allocated page (on mmu_pageaddr_o)
    mmu_set_usecnt_o   : out std_logic;
    
    mmu_set_usecnt_done_i  : in  std_logic;
    
    -- user count to be set (associated with an allocated page) in two cases:
    -- * mmu_pagereq_o    is HIGH - normal allocation
    -- * mmu_set_usecnt_o is HIGH - force user count to existing page alloc
    mmu_usecnt_o       : out  std_logic_vector(c_swc_usecount_width - 1 downto 0);
    
    -- memory full
    mmu_nomem_i : in std_logic;     
-------------------------------------------------------------------------------
-- I/F with Routing Table Unit (RTU)
-------------------------------------------------------------------------------      
    
    rtu_rsp_valid_i     : in std_logic;
    rtu_rsp_ack_o       : out std_logic;
    rtu_dst_port_mask_i : in std_logic_vector(c_swc_num_ports  - 1 downto 0);
    rtu_drop_i          : in std_logic;
    rtu_prio_i          : in std_logic_vector(c_swc_prio_width - 1 downto 0);
  
    
-------------------------------------------------------------------------------
-- I/F with Multiport Memory (MPU)
-------------------------------------------------------------------------------    
    
    -- indicates the beginning of the package
    mpm_pckstart_o : out  std_logic;
       
    -- array of pages' addresses to which ports want to write
    mpm_pageaddr_o : out  std_logic_vector(c_swc_page_addr_width - 1 downto 0);
    
    
    mpm_pagereq_o : out std_logic;
    -- indicator that the current page is about to be full (the last FB SRAM word
    -- is being pumped in currently), after ~c_swc_packet_mem_multiply cycles 
    -- from the rising edge of this signal this page will finish
    mpm_pageend_i  : in std_logic;

    mpm_data_o  : out  std_logic_vector(c_swc_data_width - 1 downto 0);

    mpm_ctrl_o  : out  std_logic_vector(c_swc_ctrl_width - 1 downto 0);    
    
    -- data ready - request from each port to write data to port's pump
    mpm_drdy_o  : out  std_logic;
    
    -- the input register of a pump is full, this means that the pump cannot
    -- be written by the port. As soon as the data which is in the input registet
    -- is written to FB SRAM memory, the signal goes LOW and writing is possible
    mpm_full_i  : in std_logic;

    -- request to write the content of pump's input register to FB SRAM memory, 
    -- thus flash/clean input register of the pump
    mpm_flush_o : out  std_logic;    
    


-------------------------------------------------------------------------------
-- I/F with Page Transfer Arbiter (PTA)
-------------------------------------------------------------------------------     
    -- indicates the beginning of the package, strobe
    pta_transfer_pck_o : out  std_logic;
    
    pta_transfer_ack_i : in std_logic;
       
    -- array of pages' addresses to which ports want to write
    pta_pageaddr_o : out  std_logic_vector(c_swc_page_addr_width - 1 downto 0);
    
    -- destination mask - indicates to which ports the packet should be
    -- forwarded
    pta_mask_o     : out  std_logic_vector(c_swc_num_ports - 1 downto 0);
    
    pta_pck_size_o : out  std_logic_vector(c_swc_max_pck_size_width - 1 downto 0);

    pta_prio_o     : out  std_logic_vector(c_swc_prio_width - 1 downto 0)
    
    );
end swc_input_block;
    
architecture syn of swc_input_block is    


-------------------------------------------------------------------------------
-- Function which calculates number of 1's in a vector
------------------------------------------------------------------------------- 
  function cnt (a:std_logic_vector) return integer is
    variable nmb : integer range 0 to a'LENGTH;
    variable ai : std_logic_vector(a'LENGTH-1 downto 0);
    constant middle : integer := a'LENGTH/2;
  begin
    ai := a;
    if ai'length>=2 then
      nmb := cnt(ai(ai'length-1 downto middle)) + cnt(ai(middle-1 downto 0));
    else
      if ai(0)='1' then 
        nmb:=1; 
      else 
        nmb:=0; 
      end if;
    end if;
    return nmb;
  end cnt;

  
  -- this is a page which is used for pck start
  signal pckstart_page_in_advance  : std_logic;
  signal pckstart_pageaddr         : std_logic_vector(c_swc_page_addr_width - 1 downto 0);
  signal pckstart_page_alloc_req   : std_logic;
  signal pckstart_usecnt_req       : std_logic;
  signal pckstart_usecnt_in_advance: std_logic_vector(c_swc_usecount_width - 1 downto 0);  
  signal current_pckstart_pageaddr : std_logic_vector(c_swc_page_addr_width - 1 downto 0);
    
  -- this is a page which used within the pck
  signal interpck_page_in_advance  : std_logic;  
  signal interpck_pageaddr         : std_logic_vector(c_swc_page_addr_width - 1 downto 0);
  signal interpck_page_alloc_req   : std_logic;  
  signal interpck_usecnt_req       : std_logic;  

  signal interpck_usecnt_in_advance: std_logic_vector(c_swc_usecount_width - 1 downto 0);  
  signal usecnt_d0                 : std_logic_vector(c_swc_usecount_width - 1 downto 0);    
  -- WHY two separate page's for inter and start pck allocated in advance:
  -- in the case in which one pck has just finished, we need new page addr for the new pck
  -- very soon after writing the last page of previous pck, 

  signal tx_dreq                   : std_logic;
  signal mpm_pckstart              : std_logic;
  signal mpm_pagereq               : std_logic;  
  signal transfering_pck           : std_logic;
  signal rtu_dst_port_mask         : std_logic_vector(c_swc_num_ports  - 1 downto 0);
  signal rtu_prio                  : std_logic_vector(c_swc_prio_width - 1 downto 0);
  signal rtu_rsp_ack               : std_logic;
  signal usecnt                    : std_logic_vector(c_swc_usecount_width - 1 downto 0);
  signal mmu_force_free            : std_logic; 
  signal pta_pageaddr              : std_logic_vector(c_swc_page_addr_width - 1 downto 0);
  signal pta_mask                  : std_logic_vector(c_swc_num_ports  - 1 downto 0);
  signal pta_prio                  : std_logic_vector(c_swc_prio_width - 1 downto 0);
  signal pta_pck_size              : std_logic_vector(c_swc_max_pck_size_width - 1 downto 0);
  
  type t_pck_state is (S_IDLE,                   -- we wait for other processes (page fsm and 
                                                 -- transfer) to be ready
                       S_READY_FOR_PCK,          -- this is introduced to diminish optimization 
                                                 -- (optimized design did not work) in this state, 
                       S_WAIT_FOR_SOF,           -- we've got RTU response, but there is no SOF
                       S_WAIT_FOR_RTU_RSP,       -- we've got SOF (request from previous pck) but
                                                 -- there is no RTU valid signal (quite improbable)
                       S_PCK_START_1,            -- first mode of PCK start: we have the page ready,
                                                 -- so we can set the page
                       S_SET_NEXT_PAGE,          -- setting next page address (allocated previously)
                       S_SET_LAST_NEXT_PAGE,     -- setting the last page address of the pck(only in
                                                 -- case, the last word to be written (after flush)
                                                 -- needs allocation of a new page
                       S_WAIT_FOR_PAGE_END,      -- waiting for the end of new page (should be most
                                                 -- of the time during pck transfer, in this state)
                       S_WAIT_FOR_LAST_PAGE_SET, -- waits for the last page to be allocated so it can be 
                                                 -- written 
                       S_DROP_PCK);              -- droping pck
                                                           

  type t_page_state is (S_IDLE,                  -- waiting for some work :)
                        S_PCKSTART_SET_USECNT,   -- setting usecnt to a page which was allocated 
                                                 -- in advance to be used for the first page of 
                                                 -- the pck
                                                 -- (only in case of the initially allocated usecnt
                                                 -- is different than required)
                        S_INTERPCK_SET_USECNT,   -- setting usecnt to a page which was allocated 
                                                 -- in advance to be used for the page which is 
                                                 -- not first
                                                 -- in the pck, this is needed, only if the page
                                                 -- was allocated during transfer of previous pck 
                                                 -- but was not used in the previous pck, 
                                                 -- only if usecnt of both pcks are different
                        S_PCKSTART_PAGE_REQ,     -- allocating in advnace first page of the pck
                        S_INTERPCK_PAGE_REQ);    -- allocating in advance page to be used by 
                                                 -- all but first page of the pck

  type t_rerror_state is (S_IDLE,                -- waiting for some work :)
                          S_WAIT_TO_FREE_PCK,    -- 
                          S_ONE_PERROR,
                          S_TWO_PERRORS); -- droping pck                   
                   
  signal pck_state       : t_pck_state;
  signal page_state      : t_page_state;  
  signal rerror_state    : t_rerror_state;  
  
  -- this goes HIGH for one cycle when all the
  -- initial staff related to starting new packet 
  -- transfer was finished, so when exiting S_SET_USECNT state
  
  signal mmu_force_free_addr : std_logic_vector(c_swc_page_addr_width - 1 downto 0);
  
  signal pck_size      : std_logic_vector(c_swc_max_pck_size_width - 1 downto 0);
  
  signal need_pckstart_usecnt_set : std_logic;
  signal need_interpck_usecnt_set : std_logic; 
  
  signal transfering_pck_on_wait  : std_logic;
  
  signal tmp_cnt : std_logic_vector(7 downto 0);
  
  signal tx_rerror_reg : std_logic;
  
  signal tx_rerror_or : std_logic;
  
begin --arch

 -- here we calculate pck size: we increment when
 -- the valid_i is HIGH
 pck_size_cnt : process(clk_i, rst_n_i)
 begin
   if rising_edge(clk_i) then
     if(rst_n_i = '0') then
       
       pck_size <= (others =>'0');
       
     else
       
       if(tx_sof_p1_i = '1') then
       
         pck_size <= (others =>'0');
         
       elsif(tx_valid_i = '1' and tx_eof_p1_i = '0') then
       
         pck_size <= std_logic_vector(unsigned(pck_size) + 1);
         
       end if;
       
     end if;
   end if;
   
 end process;
     
     
     
 -- Main Finite State Machine which controls communication
 -- between Fabric Interface and Mutiport Memory
 fsm_pck : process(clk_i, rst_n_i)
  begin
    if rising_edge(clk_i) then
      if(rst_n_i = '0') then
        --================================================
        pck_state                <= S_IDLE;
        
        tx_dreq                  <= '0';
        
        mpm_pckstart             <= '0';
        mpm_pagereq              <= '0';

        rtu_rsp_ack              <= '0';
        rtu_dst_port_mask        <= (others => '0');
        rtu_prio                 <= (others => '0');
        
        current_pckstart_pageaddr<= (others => '0');
        usecnt                   <= (others => '0');
        
        tmp_cnt                  <=  (others => '0');

        --================================================
      else

        -- main finite state machine
        case pck_state is


          when S_IDLE =>
          
            tmp_cnt      <=  (others => '0');
            tx_dreq      <= '0';
            
            if(page_state               = S_IDLE and      -- all allocations in advnaced finished
               pckstart_page_in_advance = '1'    and
               transfering_pck          = '0'    and      -- last package transferred
               tx_rerror_reg            = '0'    and      -- if error of pck was detected when
                                                       -- another one is being handled, wait !!!
               mmu_nomem_i              = '0' ) then   -- there is place in memory
                
               -- prepared to be accepting new package
               pck_state <= S_READY_FOR_PCK;
               tx_dreq   <= '1';
            
              
            end if;
           
          when S_READY_FOR_PCK =>
            
            
            
            -- we need decision from RTU, but also we want the transfer
            -- of the fram eto be finished, the transfer in normal case should
            -- take 2 cycles
            
            tx_dreq                  <= '0';
            
            if(rtu_rsp_valid_i = '1'  and rtu_drop_i = '1') then
            
               -- if we've got RTU decision to drop, we don't give a damn about 
               -- anything else, just pretend to be receiving the msg
               tx_dreq                  <= '1';
               rtu_rsp_ack              <= '1';
               pck_state                <= S_DROP_PCK;
            
            elsif(rtu_rsp_valid_i = '1' and tx_sof_p1_i = '1' and mpm_full_i = '0' and pckstart_page_in_advance = '1' ) then

               -- beutifull, everything that is needed, is there:
               --  * RTU decision
               --  * SOF
               --  * adress for the first page allocated
               --  * memory not full
               
               tx_dreq                  <= '1';
               mpm_pckstart             <= '1';
               mpm_pagereq              <= '1';
               rtu_dst_port_mask        <= rtu_dst_port_mask_i;
               rtu_prio                 <= rtu_prio_i;
               usecnt                   <= std_logic_vector(to_signed(cnt(rtu_dst_port_mask_i),usecnt'length));
               rtu_rsp_ack              <= '1';               
               pck_state                <= S_PCK_START_1;


             elsif(rtu_rsp_valid_i = '1' and tx_sof_p1_i = '0') then
             
               -- so we've got RTU decision, but no SOF, let's wait for SOF
               -- but remember RTU RSP and ack it, so RTU is free 
               rtu_rsp_ack              <= '1';
               pck_state                <= S_WAIT_FOR_SOF;
               tx_dreq                  <= '1';
               rtu_dst_port_mask        <= rtu_dst_port_mask_i;
               rtu_prio                 <= rtu_prio_i;
               usecnt                   <= std_logic_vector(to_signed(cnt(rtu_dst_port_mask_i),usecnt'length));
             
             elsif(rtu_rsp_valid_i = '0' and tx_sof_p1_i = '1') then
             
               -- we've got SOF because it was requested at the end of the last PCK
               -- but the RTU is still processing
               rtu_rsp_ack              <= '0';
               pck_state                <= S_WAIT_FOR_RTU_RSP;
               tx_dreq                  <= '0';

             end if;
        
          when S_WAIT_FOR_SOF =>
              
              rtu_rsp_ack             <= '0';
              
              if(tx_sof_p1_i = '1' and mpm_full_i = '0' and pckstart_page_in_advance = '1' ) then
              
                -- very nicely, everything is in place, we can go ahead
                tx_dreq               <= '1';
                mpm_pckstart          <= '1';
                mpm_pagereq           <= '1';
                pck_state             <=  S_PCK_START_1;   
                
              end if;
                
          when S_WAIT_FOR_RTU_RSP => 
            
            
            if(tx_rerror_p1_i = '1' ) then
            
              pck_state                <= S_IDLE;
              tx_dreq                  <= '0';
              
            elsif(rtu_rsp_valid_i = '1' and mpm_full_i = '0' and pckstart_page_in_advance = '1') then

              tx_dreq                  <= '1';
              mpm_pckstart             <= '1';
              mpm_pagereq              <= '1';
            
              rtu_dst_port_mask        <= rtu_dst_port_mask_i;
              rtu_prio                 <= rtu_prio_i;
              usecnt                   <= std_logic_vector(to_signed(cnt(rtu_dst_port_mask_i),usecnt'length));
              rtu_rsp_ack              <= '1'; 
              pck_state                <=  S_PCK_START_1; 
                            
            end if;
           
          when S_PCK_START_1 =>
              
               rtu_rsp_ack              <= '0';
               mpm_pckstart             <= '0';
               mpm_pagereq              <= '0';
               current_pckstart_pageaddr<=pckstart_pageaddr;
               pck_state                <= S_WAIT_FOR_PAGE_END;
               
          when S_WAIT_FOR_PAGE_END =>
           
            if(tx_rerror_p1_i = '1')then
           
              -- error, screw everything else
              pck_state               <= S_IDLE;
              tx_dreq                 <= '0';
              
           
            elsif(tx_eof_p1_i = '0' and mpm_pageend_i = '1' and interpck_page_in_advance = '1') then
              
              -- this is normal case, we load next page within pck transfer   
              pck_state               <=  S_SET_NEXT_PAGE;
              mpm_pagereq             <= '1';
          
            elsif(tx_eof_p1_i = '0' and mpm_pageend_i = '1' and interpck_page_in_advance = '0') then
          
              -- we wait in the same state, write_pump should do the work
              -- of stopping writing by asserting full_o to HIGH when we 
              -- run out of space (after the "end page" is finished)
              pck_state               <=  S_WAIT_FOR_PAGE_END;
                
                 
            elsif( tx_eof_p1_i = '1' ) then
              
              -- ============= now comes fun ..... =====================
           
              -- transfering_pck will be set to HIGH by another process
              if(transfering_pck = '0' and mpm_pageend_i = '0') then
  
                -- normal finish of the pck,             
                pck_state               <= S_IDLE;
                tx_dreq                 <= '0'; 
              
              elsif(transfering_pck = '0' and mpm_pageend_i = '1' and interpck_page_in_advance = '1') then
              
                -- we need to set new page to which the last bytes are written
                mpm_pagereq             <= '1';
                pck_state               <= S_SET_LAST_NEXT_PAGE;
                tx_dreq                 <= '0'; 
             
              elsif(transfering_pck = '0' and mpm_pageend_i = '1' and interpck_page_in_advance = '0') then 
            
                -- here nothing changes, we just go to different state
                -- to know that when the new interpck page is allocated
                -- we need to go to SET_LAST_NEXT_PAGE, in order to 
                -- finish the transfer after setting the page
                pck_state               <=  S_WAIT_FOR_LAST_PAGE_SET;

              end if;  
            end if;     

          when S_WAIT_FOR_LAST_PAGE_SET =>
            
            if(interpck_page_in_advance = '1') then 
              mpm_pagereq              <= '1';
              pck_state               <= S_SET_LAST_NEXT_PAGE;
              tx_dreq                 <= '0'; 
            end if;
            
          when S_SET_NEXT_PAGE =>

            mpm_pagereq                <= '0';
              
            if(tx_rerror_p1_i = '1' ) then

              pck_state                <= S_IDLE;
              tx_dreq                  <= '0';
           
            elsif( tx_eof_p1_i = '1' ) then

              pck_state               <= S_IDLE;
              tx_dreq                 <= '0'; 
              
            else

              pck_state                <=  S_WAIT_FOR_PAGE_END;
                         
            end if;        
          
          when S_SET_LAST_NEXT_PAGE =>
    
            -- used only in the case that pck finishes when pageend is HIGH,
            -- which means that the data being written has no page allocated    
            
            mpm_pagereq              <= '0';
            pck_state                <= S_IDLE;
            tx_dreq                  <= '0';
        
          when S_DROP_PCK => 
             
            rtu_rsp_ack               <= '0';
             
            if(tx_eof_p1_i = '1' or tx_rerror_p1_i = '1' ) then 
              
              pck_state               <= S_IDLE;
              tx_dreq                 <= '0';
              
            end if;

          when others =>
            
              pck_state               <= S_IDLE;
              tx_dreq                 <= '0';
            
        end case;
        
      end if;
    end if;
    
  end process;
  


 -- Auxiliary Finite State Machine which talks with
 -- Memory Management Unit, it controls:
 -- * page allocation
 -- * usecnt setting
 fsm_page : process(clk_i, rst_n_i)
 begin
   if rising_edge(clk_i) then
     if(rst_n_i = '0') then
       --========================================
       page_state                 <= S_IDLE;
       
       interpck_pageaddr          <= (others => '0');
       interpck_page_alloc_req    <= '0';
       interpck_usecnt_in_advance <= (others => '0');
       interpck_usecnt_req        <= '0';
       
       pckstart_pageaddr          <= (others => '0');
       pckstart_page_alloc_req    <= '0';
       pckstart_usecnt_req        <= '0';
       pckstart_usecnt_in_advance <= (others => '0');
       --========================================
     else

       -- main finite state machine
       case page_state is

        when S_IDLE =>
           
           interpck_page_alloc_req   <= '0';
           interpck_usecnt_req       <= '0';
           pckstart_page_alloc_req   <= '0';
           pckstart_usecnt_req       <= '0';
           
           
           if((need_pckstart_usecnt_set = '1' and need_interpck_usecnt_set = '1') or
              (need_pckstart_usecnt_set = '1' and need_interpck_usecnt_set = '0') ) then
             
             page_state               <= S_PCKSTART_SET_USECNT;
             pckstart_usecnt_req      <= '1';
            
           elsif(pckstart_page_in_advance = '0') then
           
             pckstart_page_alloc_req  <= '1';
             page_state               <= S_PCKSTART_PAGE_REQ;
             
             
           elsif(interpck_page_in_advance = '0') then 
             
             interpck_page_alloc_req  <= '1';
             page_state               <= S_INTERPCK_PAGE_REQ;

           elsif(need_interpck_usecnt_set = '1') then 
             
             page_state               <= S_INTERPCK_SET_USECNT;
             interpck_usecnt_req      <= '1';
           
           end if;
                      

        when S_PCKSTART_SET_USECNT =>
        
           if(mmu_set_usecnt_done_i = '1') then
          
             pckstart_usecnt_req        <= '0';   
             pckstart_usecnt_in_advance<= usecnt_d0;
             
             if(need_interpck_usecnt_set = '1') then 
               
               page_state               <= S_INTERPCK_SET_USECNT;
               interpck_usecnt_req      <= '1';
             
             elsif(interpck_page_in_advance = '0') then 
               
               interpck_page_alloc_req  <= '1';
               page_state               <= S_INTERPCK_PAGE_REQ;
  
               
             elsif(pckstart_page_in_advance = '0') then
             
               pckstart_page_alloc_req  <= '1';
               page_state               <= S_PCKSTART_PAGE_REQ;
             
             else
             
               page_state               <=  S_IDLE;  
               
             end if;
           
           end if;

        
        when S_INTERPCK_SET_USECNT =>

           if(mmu_set_usecnt_done_i = '1') then
          
             interpck_usecnt_req        <= '0';   
             interpck_usecnt_in_advance <= usecnt_d0;
             
             if(interpck_page_in_advance = '0') then 
             
               interpck_page_alloc_req  <= '1';
               page_state               <= S_INTERPCK_PAGE_REQ;

             elsif(need_pckstart_usecnt_set = '1') then
             
               page_state               <= S_PCKSTART_SET_USECNT;
               pckstart_usecnt_req      <= '1';
           
             elsif(pckstart_page_in_advance = '0') then
           
               pckstart_page_alloc_req  <= '1';
               page_state               <= S_PCKSTART_PAGE_REQ;
               
             else
               
               page_state               <=  S_IDLE;
             
             end if;
           
           end if;          
          
          
        when S_PCKSTART_PAGE_REQ =>          
    
          if( mmu_page_alloc_done_i = '1') then

             pckstart_page_alloc_req  <= '0';
             -- remember the page start addr
             pckstart_pageaddr         <= mmu_pageaddr_i;
             pckstart_usecnt_in_advance<= usecnt_d0;
      
             if(need_interpck_usecnt_set = '1') then 
             
               page_state               <= S_INTERPCK_SET_USECNT;
               interpck_usecnt_req      <= '1';
           
             elsif(interpck_page_in_advance = '0') then 
             
               interpck_page_alloc_req  <= '1';
               page_state               <= S_INTERPCK_PAGE_REQ;

             
             elsif(need_pckstart_usecnt_set = '1') then
             
               page_state               <= S_PCKSTART_SET_USECNT;
               pckstart_usecnt_req      <= '1';
           
             else
               
               page_state               <= S_IDLE;
               
             end if;
           end if;

        when S_INTERPCK_PAGE_REQ =>          
    
          if( mmu_page_alloc_done_i = '1') then
    
             interpck_page_alloc_req   <= '0';
             interpck_pageaddr         <= mmu_pageaddr_i;
             --remember the usecnt which was at the time of
             -- page allocation, this is in case that the page
             -- is used to store another pck then the current one.
             -- therefore we compare this stored value with the
             -- current usecnt
             interpck_usecnt_in_advance <= usecnt_d0;
             interpck_page_alloc_req    <= '0';
      
             if(need_interpck_usecnt_set = '1') then 
             
               page_state               <= S_INTERPCK_SET_USECNT;
               interpck_usecnt_req      <= '1';
           
             elsif(need_pckstart_usecnt_set = '1') then
               
               page_state               <= S_PCKSTART_SET_USECNT;
               pckstart_usecnt_req      <= '1';
           
             elsif(pckstart_page_in_advance = '0') then
             
               pckstart_page_alloc_req  <= '1';
               page_state               <= S_PCKSTART_PAGE_REQ;
               
             else
               
               page_state                 <= S_IDLE;
               
             end if;
      
           end if;

         when others =>
           
             page_state                   <= S_IDLE;
           
       end case;
       
       usecnt_d0 <= usecnt;

     end if;
   end if;
   
 end process;
  
  tx_rerror_or <= tx_rerror_reg or tx_rerror_p1_i;
 
 -- Auxiliary Finite State Machine which controls
 -- error handling
 fsm_perror : process(clk_i, rst_n_i)
 variable cnt : integer := 0;
 begin
   if rising_edge(clk_i) then
     if(rst_n_i = '0') then
       --========================================
       mmu_force_free_addr <= (others => '0');
       mmu_force_free      <= '0';
       cnt                 := 0;
       tx_rerror_reg       <= '0';
       --========================================
     else

       
       -- here is some magic which foresees a case in which
       -- an rerror occures when a previous rerror case is being
       -- handled, in such case, we remmeber another signal
       -- which will be handled next time
       -- simultaneously, the pck_fsm will wait with
       -- the transfer of another pck since we cannot stand
       -- more pck tropped
       
       if(tx_rerror_p1_i = '1' and rerror_state /=S_IDLE) then
       
         -- when previous error is being handled, remember
         -- the error signal
         tx_rerror_reg <= '1';
         
       elsif(tx_rerror_reg = '1' and rerror_state = S_IDLE) then
       
         -- remembered signal is now detected so we can
         -- stop remembering
         tx_rerror_reg <= '0';
         
       end if;
       
       
       case rerror_state is

        when S_IDLE =>
          
          mmu_force_free      <= '0';
          
          if(tx_rerror_or = '1' and pck_state /=S_DROP_PCK) then 
          
            rerror_state                <= S_WAIT_TO_FREE_PCK;
            mmu_force_free_addr         <= current_pckstart_pageaddr;
            
          end if;

        -- why this state ?
        -- most probably, the pck that is tropped, will be immediately
        -- followed by another pck, we don't want to perform pck forced
        -- deallocation at the beginning of transmitting new pck, since
        -- these two operations interface the same block (MMU), thus
        -- both of them will work two times slower, so we wait
        -- until the pck transfer is in "less busy state" 
        -- (i.e. S_WAIT_FOR_PAGE_END) or there is no pcks being
        -- transfered for some arbitrar time (10 cycles)
        -- it may be not the best solutions
        
        when S_WAIT_TO_FREE_PCK =>          
                       
            
            if(pck_state =  S_WAIT_FOR_PAGE_END) then

              rerror_state              <= S_ONE_PERROR;--S_TWO_PERRORS;
              mmu_force_free            <= '1';
              
            elsif(cnt > 10 and pck_state = S_IDLE) then
            
              rerror_state              <= S_ONE_PERROR;
              mmu_force_free            <= '1';
              cnt                       :=  0;
            
            elsif(pck_state = S_IDLE) then
            
              cnt := cnt + 1;
            
            end if;
               

        when S_ONE_PERROR => 
          
          if(mmu_force_free_done_i = '1' ) then
            
            mmu_force_free            <= '0';
            rerror_state              <= S_IDLE;
            
          end if;

         when others =>
           
             rerror_state        <= S_IDLE;
             mmu_force_free      <= '0';
       end case;
       
       --

     end if;
   end if;
   
 end process;

  -- this proces controls Package Transfer Arbiter
  pta_if: process(clk_i, rst_n_i)
  begin
    if rising_edge(clk_i) then
      if(rst_n_i = '0') then
      --===================================================
      transfering_pck           <= '0';
      pta_pageaddr              <=(others => '0');
      pta_mask                  <=(others => '0');
      pta_prio                  <=(others => '0');
      pta_pck_size              <=(others => '0');
      transfering_pck_on_wait   <= '0';
      --===================================================
      else

        
        if(tx_eof_p1_i = '1' and pck_state /=S_DROP_PCK ) then 
           
           -- transfer pck when end of frame

          if(transfering_pck = '0') then

            -- normal case, transfer arbiter free                      
            transfering_pck <= '1';
          
            pta_pageaddr    <= current_pckstart_pageaddr;
            pta_mask        <= rtu_dst_port_mask;
            pta_prio        <= rtu_prio;
            pta_pck_size    <= pck_size;
            
          else
             
            -- transfer arbiter not free (should not
            -- get here in non-optimal implementation)
            -- anyway, we set the special flag           
            transfering_pck_on_wait <= '1';
            
          end if;
          
        elsif(transfering_pck = '0' and transfering_pck_on_wait = '1') then
          
          -- if the transfer is finished, but another 
          -- transfer is in the queue, go for it
          
          transfering_pck_on_wait <= '0';
          
          transfering_pck <= '1';
          
          pta_pageaddr     <= current_pckstart_pageaddr;
          pta_mask         <= rtu_dst_port_mask;
          pta_prio         <= rtu_prio;
          pta_pck_size     <= pck_size;
                    
        elsif(pta_transfer_ack_i = '1' and transfering_pck = '1') then
        
          --transfer finished
          transfering_pck   <= '0';
          pta_pageaddr      <=(others => '0');
          pta_mask          <=(others => '0');
          pta_prio          <=(others => '0');
          pta_pck_size      <=(others => '0');
          

        end if;
      end if;
    end if;
  end process;

  -- for page allocation
  page_if: process(clk_i, rst_n_i)
  begin
    if rising_edge(clk_i) then
      if(rst_n_i = '0') then
      --===================================================
      pckstart_page_in_advance  <= '0';
      interpck_page_in_advance  <= '0';
      need_pckstart_usecnt_set  <= '0';
      need_interpck_usecnt_set  <= '0'; 
      --===================================================
      else        
      
        if(pck_state = S_PCK_START_1) then
        
          if(usecnt = pckstart_usecnt_in_advance) then
            need_pckstart_usecnt_set  <= '0';
            pckstart_page_in_advance  <= '0';            
          else
            need_pckstart_usecnt_set  <= '1';

          end if;
        
          if(usecnt = interpck_usecnt_in_advance) then 
            need_interpck_usecnt_set  <= '0';
          else
            need_interpck_usecnt_set  <= '1';
          end if;
          
        elsif(page_state = S_INTERPCK_SET_USECNT and mmu_set_usecnt_done_i = '1') then
          need_interpck_usecnt_set  <= '0';
        elsif(page_state = S_PCKSTART_SET_USECNT and mmu_set_usecnt_done_i = '1')then
          need_pckstart_usecnt_set  <= '0';
        end if;
        
        if(pck_state = S_SET_NEXT_PAGE or pck_state = S_SET_LAST_NEXT_PAGE) then 
          interpck_page_in_advance <= '0';
        elsif(mmu_page_alloc_done_i = '1' and interpck_page_alloc_req = '1') then
          interpck_page_in_advance <= '1';
        end if;
          

        if(mmu_set_usecnt_done_i = '1' and page_state = S_PCKSTART_SET_USECNT) then 
          pckstart_page_in_advance <= '0';
        elsif(mmu_page_alloc_done_i = '1' and pckstart_page_alloc_req = '1') then
          pckstart_page_in_advance <= '1';
        end if;

     end if;
    end if;
  end process;

  tx_dreq_o              <= '0'    when (pck_state = S_IDLE)     else
                            '1'    when (pck_state = S_DROP_PCK) else   
                            tx_dreq and not mpm_full_i    ;
                            
  rtu_rsp_ack_o          <= rtu_rsp_ack;

  mmu_force_free_addr_o  <= mmu_force_free_addr;
  mmu_set_usecnt_o       <= pckstart_usecnt_req or interpck_usecnt_req;
  mmu_usecnt_o           <= usecnt;
  mmu_page_alloc_req_o   <= interpck_page_alloc_req or pckstart_page_alloc_req;
  mmu_force_free_o       <= mmu_force_free;                            
  mmu_pageaddr_o         <= interpck_pageaddr when (page_state = S_INTERPCK_SET_USECNT)  else
                            pckstart_pageaddr when (page_state = S_PCKSTART_SET_USECNT)  else (others => '0') ;

  mpm_pckstart_o         <= mpm_pckstart;                            
  mpm_drdy_o             <= '0' when (pck_state = S_DROP_PCK) else tx_valid_i;
  mpm_pagereq_o          <= mpm_pagereq;
  mpm_data_o             <= tx_data_i;
  -- TODO: need info from TOMEK
  mpm_ctrl_o(3)          <= tx_bytesel_i;
  mpm_ctrl_o(2 downto 0) <= tx_ctrl_i(2 downto 0);
  mpm_pageaddr_o         <= pckstart_pageaddr when (pck_state = S_PCK_START_1) else interpck_pageaddr ;                                           
  mpm_flush_o            <= tx_eof_p1_i when (pck_state = S_WAIT_FOR_PAGE_END or 
                                              pck_state = S_SET_NEXT_PAGE     ) else '0'; --mpm_flush;
                                                    
  pta_transfer_pck_o     <= transfering_pck;
  pta_pageaddr_o         <= pta_pageaddr;
  pta_mask_o             <= pta_mask;
  pta_prio_o             <= pta_prio;
  pta_pck_size_o         <= pta_pck_size;
  
  
end syn; -- arch