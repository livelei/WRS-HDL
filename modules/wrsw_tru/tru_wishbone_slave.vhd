---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for Topology Resolution Unit (TRU)
---------------------------------------------------------------------------------------
-- File           : tru_wishbone_slave.vhd
-- Author         : auto-generated by wbgen2 from tru_wishbone_slave.wb
-- Created        : Wed Mar 13 18:49:56 2013
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE tru_wishbone_slave.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tru_wbgen2_pkg.all;


entity tru_wishbone_slave is
  port (
    rst_n_i                                  : in     std_logic;
    wb_clk_i                                 : in     std_logic;
    wb_addr_i                                : in     std_logic_vector(4 downto 0);
    wb_data_i                                : in     std_logic_vector(31 downto 0);
    wb_data_o                                : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    regs_i                                   : in     t_tru_in_registers;
    regs_o                                   : out    t_tru_out_registers
  );
end tru_wishbone_slave;

architecture syn of tru_wishbone_slave is

signal tru_gcr_g_ena_int                        : std_logic      ;
signal tru_gcr_tru_bank_dly0                    : std_logic      ;
signal tru_gcr_tru_bank_int                     : std_logic      ;
signal tru_gcr_rx_frame_reset_int               : std_logic_vector(23 downto 0);
signal tru_mcr_pattern_mode_rep_int             : std_logic_vector(3 downto 0);
signal tru_mcr_pattern_mode_add_int             : std_logic_vector(3 downto 0);
signal tru_mcr_pattern_mode_sub_int             : std_logic_vector(3 downto 0);
signal tru_lacr_agg_df_hp_id_int                : std_logic_vector(3 downto 0);
signal tru_lacr_agg_df_br_id_int                : std_logic_vector(3 downto 0);
signal tru_lacr_agg_df_un_id_int                : std_logic_vector(3 downto 0);
signal tru_tcgr_trans_ena_int                   : std_logic      ;
signal tru_tcgr_trans_clear_int                 : std_logic      ;
signal tru_tcgr_trans_mode_int                  : std_logic_vector(2 downto 0);
signal tru_tcgr_trans_rx_id_int                 : std_logic_vector(2 downto 0);
signal tru_tcgr_trans_prio_int                  : std_logic_vector(2 downto 0);
signal tru_tcgr_trans_prio_mode_int             : std_logic      ;
signal tru_tcpbr_trans_pause_time_int           : std_logic_vector(15 downto 0);
signal tru_tcpbr_trans_block_time_int           : std_logic_vector(15 downto 0);
signal tru_tcpr_trans_port_a_id_int             : std_logic_vector(5 downto 0);
signal tru_tcpr_trans_port_a_valid_int          : std_logic      ;
signal tru_tcpr_trans_port_b_id_int             : std_logic_vector(5 downto 0);
signal tru_tcpr_trans_port_b_valid_int          : std_logic      ;
signal tru_rtrcr_rtr_ena_int                    : std_logic      ;
signal tru_rtrcr_rtr_reset_int                  : std_logic      ;
signal tru_rtrcr_rtr_mode_int                   : std_logic_vector(3 downto 0);
signal tru_rtrcr_rtr_rx_int                     : std_logic_vector(3 downto 0);
signal tru_rtrcr_rtr_tx_int                     : std_logic_vector(3 downto 0);
signal tru_hwfc_rx_fwd_id_int                   : std_logic_vector(3 downto 0);
signal tru_hwfc_rx_blk_id_int                   : std_logic_vector(3 downto 0);
signal tru_hwfc_tx_fwd_id_int                   : std_logic_vector(3 downto 0);
signal tru_hwfc_tx_blk_id_int                   : std_logic_vector(3 downto 0);
signal tru_hwfc_tx_fwd_ub_int                   : std_logic_vector(7 downto 0);
signal tru_hwfc_tx_blk_ub_int                   : std_logic_vector(7 downto 0);
signal tru_ttr0_fid_int                         : std_logic_vector(7 downto 0);
signal tru_ttr0_sub_fid_int                     : std_logic_vector(7 downto 0);
signal tru_ttr0_update_dly0                     : std_logic      ;
signal tru_ttr0_update_int                      : std_logic      ;
signal tru_ttr0_mask_valid_int                  : std_logic      ;
signal tru_ttr0_patrn_mode_int                  : std_logic_vector(3 downto 0);
signal tru_ttr1_ports_ingress_int               : std_logic_vector(31 downto 0);
signal tru_ttr2_ports_egress_int                : std_logic_vector(31 downto 0);
signal tru_ttr3_ports_mask_int                  : std_logic_vector(31 downto 0);
signal tru_ttr4_patrn_match_int                 : std_logic_vector(31 downto 0);
signal tru_ttr5_patrn_mask_int                  : std_logic_vector(31 downto 0);
signal tru_dps_pid_int                          : std_logic_vector(7 downto 0);
signal tru_pidr_inject_dly0                     : std_logic      ;
signal tru_pidr_inject_int                      : std_logic      ;
signal tru_pidr_psel_int                        : std_logic_vector(2 downto 0);
signal tru_pidr_uval_int                        : std_logic_vector(15 downto 0);
signal tru_pfdr_clr_dly0                        : std_logic      ;
signal tru_pfdr_clr_int                         : std_logic      ;
signal ack_sreg                                 : std_logic_vector(9 downto 0);
signal rddata_reg                               : std_logic_vector(31 downto 0);
signal wrdata_reg                               : std_logic_vector(31 downto 0);
signal bwsel_reg                                : std_logic_vector(3 downto 0);
signal rwaddr_reg                               : std_logic_vector(4 downto 0);
signal ack_in_progress                          : std_logic      ;
signal wr_int                                   : std_logic      ;
signal rd_int                                   : std_logic      ;
signal bus_clock_int                            : std_logic      ;
signal allones                                  : std_logic_vector(31 downto 0);
signal allzeros                                 : std_logic_vector(31 downto 0);

begin
-- Some internal signals assignments. For (foreseen) compatibility with other bus standards.
  wrdata_reg <= wb_data_i;
  bwsel_reg <= wb_sel_i;
  bus_clock_int <= wb_clk_i;
  rd_int <= wb_cyc_i and (wb_stb_i and (not wb_we_i));
  wr_int <= wb_cyc_i and (wb_stb_i and wb_we_i);
  allones <= (others => '1');
  allzeros <= (others => '0');
-- 
-- Main register bank access process.
  process (bus_clock_int, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      ack_sreg <= "0000000000";
      ack_in_progress <= '0';
      rddata_reg <= "00000000000000000000000000000000";
      tru_gcr_g_ena_int <= '0';
      tru_gcr_tru_bank_int <= '0';
      tru_gcr_rx_frame_reset_int <= "000000000000000000000000";
      tru_mcr_pattern_mode_rep_int <= "0000";
      tru_mcr_pattern_mode_add_int <= "0000";
      tru_mcr_pattern_mode_sub_int <= "0000";
      tru_lacr_agg_df_hp_id_int <= "0000";
      tru_lacr_agg_df_br_id_int <= "0000";
      tru_lacr_agg_df_un_id_int <= "0000";
      tru_tcgr_trans_ena_int <= '0';
      tru_tcgr_trans_clear_int <= '0';
      tru_tcgr_trans_mode_int <= "000";
      tru_tcgr_trans_rx_id_int <= "000";
      tru_tcgr_trans_prio_int <= "000";
      tru_tcgr_trans_prio_mode_int <= '0';
      tru_tcpbr_trans_pause_time_int <= "0000000000000000";
      tru_tcpbr_trans_block_time_int <= "0000000000000000";
      tru_tcpr_trans_port_a_id_int <= "000000";
      tru_tcpr_trans_port_a_valid_int <= '0';
      tru_tcpr_trans_port_b_id_int <= "000000";
      tru_tcpr_trans_port_b_valid_int <= '0';
      tru_rtrcr_rtr_ena_int <= '0';
      tru_rtrcr_rtr_reset_int <= '0';
      tru_rtrcr_rtr_mode_int <= "0000";
      tru_rtrcr_rtr_rx_int <= "0000";
      tru_rtrcr_rtr_tx_int <= "0000";
      tru_hwfc_rx_fwd_id_int <= "0000";
      tru_hwfc_rx_blk_id_int <= "0000";
      tru_hwfc_tx_fwd_id_int <= "0000";
      tru_hwfc_tx_blk_id_int <= "0000";
      tru_hwfc_tx_fwd_ub_int <= "00000000";
      tru_hwfc_tx_blk_ub_int <= "00000000";
      tru_ttr0_fid_int <= "00000000";
      tru_ttr0_sub_fid_int <= "00000000";
      tru_ttr0_update_int <= '0';
      tru_ttr0_mask_valid_int <= '0';
      tru_ttr0_patrn_mode_int <= "0000";
      tru_ttr1_ports_ingress_int <= "00000000000000000000000000000000";
      tru_ttr2_ports_egress_int <= "00000000000000000000000000000000";
      tru_ttr3_ports_mask_int <= "00000000000000000000000000000000";
      tru_ttr4_patrn_match_int <= "00000000000000000000000000000000";
      tru_ttr5_patrn_mask_int <= "00000000000000000000000000000000";
      tru_dps_pid_int <= "00000000";
      tru_pidr_inject_int <= '0';
      tru_pidr_psel_int <= "000";
      tru_pidr_uval_int <= "0000000000000000";
      tru_pfdr_clr_int <= '0';
    elsif rising_edge(bus_clock_int) then
-- advance the ACK generator shift register
      ack_sreg(8 downto 0) <= ack_sreg(9 downto 1);
      ack_sreg(9) <= '0';
      if (ack_in_progress = '1') then
        if (ack_sreg(0) = '1') then
          tru_gcr_tru_bank_int <= '0';
          tru_ttr0_update_int <= '0';
          tru_pidr_inject_int <= '0';
          tru_pfdr_clr_int <= '0';
          ack_in_progress <= '0';
        else
        end if;
      else
        if ((wb_cyc_i = '1') and (wb_stb_i = '1')) then
          case rwaddr_reg(4 downto 0) is
          when "00000" => 
            if (wb_we_i = '1') then
              rddata_reg(0) <= 'X';
              tru_gcr_g_ena_int <= wrdata_reg(0);
              tru_gcr_tru_bank_int <= wrdata_reg(1);
              rddata_reg(1) <= 'X';
              tru_gcr_rx_frame_reset_int <= wrdata_reg(31 downto 8);
            else
              rddata_reg(0) <= tru_gcr_g_ena_int;
              rddata_reg(1) <= 'X';
              rddata_reg(31 downto 8) <= tru_gcr_rx_frame_reset_int;
              rddata_reg(2) <= 'X';
              rddata_reg(3) <= 'X';
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
            end if;
            ack_sreg(2) <= '1';
            ack_in_progress <= '1';
          when "00001" => 
            if (wb_we_i = '1') then
              rddata_reg(0) <= 'X';
            else
              rddata_reg(0) <= regs_i.gsr0_stat_bank_i;
              rddata_reg(31 downto 8) <= regs_i.gsr0_stat_stb_up_i;
              rddata_reg(1) <= 'X';
              rddata_reg(2) <= 'X';
              rddata_reg(3) <= 'X';
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00010" => 
            if (wb_we_i = '1') then
            else
              rddata_reg(31 downto 0) <= regs_i.gsr1_stat_up_i;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00011" => 
            if (wb_we_i = '1') then
              tru_mcr_pattern_mode_rep_int <= wrdata_reg(3 downto 0);
              tru_mcr_pattern_mode_add_int <= wrdata_reg(11 downto 8);
              tru_mcr_pattern_mode_sub_int <= wrdata_reg(19 downto 16);
            else
              rddata_reg(3 downto 0) <= tru_mcr_pattern_mode_rep_int;
              rddata_reg(11 downto 8) <= tru_mcr_pattern_mode_add_int;
              rddata_reg(19 downto 16) <= tru_mcr_pattern_mode_sub_int;
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
              rddata_reg(12) <= 'X';
              rddata_reg(13) <= 'X';
              rddata_reg(14) <= 'X';
              rddata_reg(15) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(24) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00100" => 
            if (wb_we_i = '1') then
              tru_lacr_agg_df_hp_id_int <= wrdata_reg(3 downto 0);
              tru_lacr_agg_df_br_id_int <= wrdata_reg(11 downto 8);
              tru_lacr_agg_df_un_id_int <= wrdata_reg(19 downto 16);
            else
              rddata_reg(3 downto 0) <= tru_lacr_agg_df_hp_id_int;
              rddata_reg(11 downto 8) <= tru_lacr_agg_df_br_id_int;
              rddata_reg(19 downto 16) <= tru_lacr_agg_df_un_id_int;
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
              rddata_reg(12) <= 'X';
              rddata_reg(13) <= 'X';
              rddata_reg(14) <= 'X';
              rddata_reg(15) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(24) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00101" => 
            if (wb_we_i = '1') then
              rddata_reg(0) <= 'X';
              tru_tcgr_trans_ena_int <= wrdata_reg(0);
              rddata_reg(1) <= 'X';
              tru_tcgr_trans_clear_int <= wrdata_reg(1);
              tru_tcgr_trans_mode_int <= wrdata_reg(6 downto 4);
              tru_tcgr_trans_rx_id_int <= wrdata_reg(10 downto 8);
              tru_tcgr_trans_prio_int <= wrdata_reg(14 downto 12);
              rddata_reg(15) <= 'X';
              tru_tcgr_trans_prio_mode_int <= wrdata_reg(15);
            else
              rddata_reg(0) <= tru_tcgr_trans_ena_int;
              rddata_reg(1) <= tru_tcgr_trans_clear_int;
              rddata_reg(6 downto 4) <= tru_tcgr_trans_mode_int;
              rddata_reg(10 downto 8) <= tru_tcgr_trans_rx_id_int;
              rddata_reg(14 downto 12) <= tru_tcgr_trans_prio_int;
              rddata_reg(15) <= tru_tcgr_trans_prio_mode_int;
              rddata_reg(2) <= 'X';
              rddata_reg(3) <= 'X';
              rddata_reg(7) <= 'X';
              rddata_reg(11) <= 'X';
              rddata_reg(16) <= 'X';
              rddata_reg(17) <= 'X';
              rddata_reg(18) <= 'X';
              rddata_reg(19) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(24) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00110" => 
            if (wb_we_i = '1') then
              tru_tcpbr_trans_pause_time_int <= wrdata_reg(15 downto 0);
              tru_tcpbr_trans_block_time_int <= wrdata_reg(31 downto 16);
            else
              rddata_reg(15 downto 0) <= tru_tcpbr_trans_pause_time_int;
              rddata_reg(31 downto 16) <= tru_tcpbr_trans_block_time_int;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00111" => 
            if (wb_we_i = '1') then
              tru_tcpr_trans_port_a_id_int <= wrdata_reg(5 downto 0);
              rddata_reg(8) <= 'X';
              tru_tcpr_trans_port_a_valid_int <= wrdata_reg(8);
              tru_tcpr_trans_port_b_id_int <= wrdata_reg(21 downto 16);
              rddata_reg(24) <= 'X';
              tru_tcpr_trans_port_b_valid_int <= wrdata_reg(24);
            else
              rddata_reg(5 downto 0) <= tru_tcpr_trans_port_a_id_int;
              rddata_reg(8) <= tru_tcpr_trans_port_a_valid_int;
              rddata_reg(21 downto 16) <= tru_tcpr_trans_port_b_id_int;
              rddata_reg(24) <= tru_tcpr_trans_port_b_valid_int;
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
              rddata_reg(9) <= 'X';
              rddata_reg(10) <= 'X';
              rddata_reg(11) <= 'X';
              rddata_reg(12) <= 'X';
              rddata_reg(13) <= 'X';
              rddata_reg(14) <= 'X';
              rddata_reg(15) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "01000" => 
            if (wb_we_i = '1') then
              rddata_reg(0) <= 'X';
              rddata_reg(1) <= 'X';
            else
              rddata_reg(0) <= regs_i.tsr_trans_stat_active_i;
              rddata_reg(1) <= regs_i.tsr_trans_stat_finished_i;
              rddata_reg(2) <= 'X';
              rddata_reg(3) <= 'X';
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
              rddata_reg(8) <= 'X';
              rddata_reg(9) <= 'X';
              rddata_reg(10) <= 'X';
              rddata_reg(11) <= 'X';
              rddata_reg(12) <= 'X';
              rddata_reg(13) <= 'X';
              rddata_reg(14) <= 'X';
              rddata_reg(15) <= 'X';
              rddata_reg(16) <= 'X';
              rddata_reg(17) <= 'X';
              rddata_reg(18) <= 'X';
              rddata_reg(19) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(24) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "01001" => 
            if (wb_we_i = '1') then
              rddata_reg(0) <= 'X';
              tru_rtrcr_rtr_ena_int <= wrdata_reg(0);
              rddata_reg(1) <= 'X';
              tru_rtrcr_rtr_reset_int <= wrdata_reg(1);
              tru_rtrcr_rtr_mode_int <= wrdata_reg(11 downto 8);
              tru_rtrcr_rtr_rx_int <= wrdata_reg(19 downto 16);
              tru_rtrcr_rtr_tx_int <= wrdata_reg(27 downto 24);
            else
              rddata_reg(0) <= tru_rtrcr_rtr_ena_int;
              rddata_reg(1) <= tru_rtrcr_rtr_reset_int;
              rddata_reg(11 downto 8) <= tru_rtrcr_rtr_mode_int;
              rddata_reg(19 downto 16) <= tru_rtrcr_rtr_rx_int;
              rddata_reg(27 downto 24) <= tru_rtrcr_rtr_tx_int;
              rddata_reg(2) <= 'X';
              rddata_reg(3) <= 'X';
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
              rddata_reg(12) <= 'X';
              rddata_reg(13) <= 'X';
              rddata_reg(14) <= 'X';
              rddata_reg(15) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "01010" => 
            if (wb_we_i = '1') then
              tru_hwfc_rx_fwd_id_int <= wrdata_reg(3 downto 0);
              tru_hwfc_rx_blk_id_int <= wrdata_reg(7 downto 4);
              tru_hwfc_tx_fwd_id_int <= wrdata_reg(11 downto 8);
              tru_hwfc_tx_blk_id_int <= wrdata_reg(15 downto 12);
              tru_hwfc_tx_fwd_ub_int <= wrdata_reg(23 downto 16);
              tru_hwfc_tx_blk_ub_int <= wrdata_reg(31 downto 24);
            else
              rddata_reg(3 downto 0) <= tru_hwfc_rx_fwd_id_int;
              rddata_reg(7 downto 4) <= tru_hwfc_rx_blk_id_int;
              rddata_reg(11 downto 8) <= tru_hwfc_tx_fwd_id_int;
              rddata_reg(15 downto 12) <= tru_hwfc_tx_blk_id_int;
              rddata_reg(23 downto 16) <= tru_hwfc_tx_fwd_ub_int;
              rddata_reg(31 downto 24) <= tru_hwfc_tx_blk_ub_int;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "01011" => 
            if (wb_we_i = '1') then
              tru_ttr0_fid_int <= wrdata_reg(7 downto 0);
              tru_ttr0_sub_fid_int <= wrdata_reg(15 downto 8);
              tru_ttr0_update_int <= wrdata_reg(16);
              rddata_reg(16) <= 'X';
              rddata_reg(17) <= 'X';
              tru_ttr0_mask_valid_int <= wrdata_reg(17);
              tru_ttr0_patrn_mode_int <= wrdata_reg(27 downto 24);
            else
              rddata_reg(7 downto 0) <= tru_ttr0_fid_int;
              rddata_reg(15 downto 8) <= tru_ttr0_sub_fid_int;
              rddata_reg(16) <= 'X';
              rddata_reg(17) <= tru_ttr0_mask_valid_int;
              rddata_reg(27 downto 24) <= tru_ttr0_patrn_mode_int;
              rddata_reg(18) <= 'X';
              rddata_reg(19) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
            end if;
            ack_sreg(2) <= '1';
            ack_in_progress <= '1';
          when "01100" => 
            if (wb_we_i = '1') then
              tru_ttr1_ports_ingress_int <= wrdata_reg(31 downto 0);
            else
              rddata_reg(31 downto 0) <= tru_ttr1_ports_ingress_int;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "01101" => 
            if (wb_we_i = '1') then
              tru_ttr2_ports_egress_int <= wrdata_reg(31 downto 0);
            else
              rddata_reg(31 downto 0) <= tru_ttr2_ports_egress_int;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "01110" => 
            if (wb_we_i = '1') then
              tru_ttr3_ports_mask_int <= wrdata_reg(31 downto 0);
            else
              rddata_reg(31 downto 0) <= tru_ttr3_ports_mask_int;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "01111" => 
            if (wb_we_i = '1') then
              tru_ttr4_patrn_match_int <= wrdata_reg(31 downto 0);
            else
              rddata_reg(31 downto 0) <= tru_ttr4_patrn_match_int;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "10000" => 
            if (wb_we_i = '1') then
              tru_ttr5_patrn_mask_int <= wrdata_reg(31 downto 0);
            else
              rddata_reg(31 downto 0) <= tru_ttr5_patrn_mask_int;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "10001" => 
            if (wb_we_i = '1') then
              tru_dps_pid_int <= wrdata_reg(7 downto 0);
            else
              rddata_reg(7 downto 0) <= tru_dps_pid_int;
              rddata_reg(8) <= 'X';
              rddata_reg(9) <= 'X';
              rddata_reg(10) <= 'X';
              rddata_reg(11) <= 'X';
              rddata_reg(12) <= 'X';
              rddata_reg(13) <= 'X';
              rddata_reg(14) <= 'X';
              rddata_reg(15) <= 'X';
              rddata_reg(16) <= 'X';
              rddata_reg(17) <= 'X';
              rddata_reg(18) <= 'X';
              rddata_reg(19) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(24) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "10010" => 
            if (wb_we_i = '1') then
              tru_pidr_inject_int <= wrdata_reg(0);
              rddata_reg(0) <= 'X';
              tru_pidr_psel_int <= wrdata_reg(3 downto 1);
              tru_pidr_uval_int <= wrdata_reg(23 downto 8);
              rddata_reg(24) <= 'X';
            else
              rddata_reg(0) <= 'X';
              rddata_reg(3 downto 1) <= tru_pidr_psel_int;
              rddata_reg(23 downto 8) <= tru_pidr_uval_int;
              rddata_reg(24) <= regs_i.pidr_iready_i;
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
            end if;
            ack_sreg(2) <= '1';
            ack_in_progress <= '1';
          when "10011" => 
            if (wb_we_i = '1') then
              tru_pfdr_clr_int <= wrdata_reg(0);
              rddata_reg(0) <= 'X';
            else
              rddata_reg(0) <= 'X';
              rddata_reg(15 downto 8) <= regs_i.pfdr_class_i;
              rddata_reg(31 downto 16) <= regs_i.pfdr_cnt_i;
              rddata_reg(1) <= 'X';
              rddata_reg(2) <= 'X';
              rddata_reg(3) <= 'X';
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
            end if;
            ack_sreg(2) <= '1';
            ack_in_progress <= '1';
          when "10100" => 
            if (wb_we_i = '1') then
            else
              rddata_reg(31 downto 0) <= regs_i.ptrdr_ging_mask_i;
            end if;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when others =>
-- prevent the slave from hanging the bus on invalid address
            ack_in_progress <= '1';
            ack_sreg(0) <= '1';
          end case;
        end if;
      end if;
    end if;
  end process;
  
  
-- Drive the data output bus
  wb_data_o <= rddata_reg;
-- TRU Global Enable
  regs_o.gcr_g_ena_o <= tru_gcr_g_ena_int;
-- Swap TRU TAB bank
  process (bus_clock_int, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      tru_gcr_tru_bank_dly0 <= '0';
      regs_o.gcr_tru_bank_o <= '0';
    elsif rising_edge(bus_clock_int) then
      tru_gcr_tru_bank_dly0 <= tru_gcr_tru_bank_int;
      regs_o.gcr_tru_bank_o <= tru_gcr_tru_bank_int and (not tru_gcr_tru_bank_dly0);
    end if;
  end process;
  
  
-- Rx Frame Reset
  regs_o.gcr_rx_frame_reset_o <= tru_gcr_rx_frame_reset_int;
-- Active Bank
-- Stable Ports UP
-- Ports UP
-- Replace Pattern Mode
  regs_o.mcr_pattern_mode_rep_o <= tru_mcr_pattern_mode_rep_int;
-- Addition Pattern Mode
  regs_o.mcr_pattern_mode_add_o <= tru_mcr_pattern_mode_add_int;
-- Substraction Pattern Mode
  regs_o.mcr_pattern_mode_sub_o <= tru_mcr_pattern_mode_sub_int;
-- HP traffic Distribution Function ID
  regs_o.lacr_agg_df_hp_id_o <= tru_lacr_agg_df_hp_id_int;
-- Broadcast Distribution Function ID
  regs_o.lacr_agg_df_br_id_o <= tru_lacr_agg_df_br_id_int;
-- Unicast Distribution Function ID
  regs_o.lacr_agg_df_un_id_o <= tru_lacr_agg_df_un_id_int;
-- Transition Enabled
  regs_o.tcgr_trans_ena_o <= tru_tcgr_trans_ena_int;
-- Transition Clear
  regs_o.tcgr_trans_clear_o <= tru_tcgr_trans_clear_int;
-- Transition Mode
  regs_o.tcgr_trans_mode_o <= tru_tcgr_trans_mode_int;
-- Rx Detected Frame ID
  regs_o.tcgr_trans_rx_id_o <= tru_tcgr_trans_rx_id_int;
-- Priority
  regs_o.tcgr_trans_prio_o <= tru_tcgr_trans_prio_int;
-- Priority Mode
  regs_o.tcgr_trans_prio_mode_o <= tru_tcgr_trans_prio_mode_int;
-- PAUSE Time
  regs_o.tcpbr_trans_pause_time_o <= tru_tcpbr_trans_pause_time_int;
-- Output Block Time
  regs_o.tcpbr_trans_block_time_o <= tru_tcpbr_trans_block_time_int;
-- Port A ID
  regs_o.tcpr_trans_port_a_id_o <= tru_tcpr_trans_port_a_id_int;
-- Port A Valid
  regs_o.tcpr_trans_port_a_valid_o <= tru_tcpr_trans_port_a_valid_int;
-- Port B ID
  regs_o.tcpr_trans_port_b_id_o <= tru_tcpr_trans_port_b_id_int;
-- Port B Valid
  regs_o.tcpr_trans_port_b_valid_o <= tru_tcpr_trans_port_b_valid_int;
-- Transition Active
-- Transition Finished
-- RTR Enabled
  regs_o.rtrcr_rtr_ena_o <= tru_rtrcr_rtr_ena_int;
-- RTR Reset
  regs_o.rtrcr_rtr_reset_o <= tru_rtrcr_rtr_reset_int;
-- RTR Handler Mode
  regs_o.rtrcr_rtr_mode_o <= tru_rtrcr_rtr_mode_int;
-- RTR Rx Frame ID
  regs_o.rtrcr_rtr_rx_o <= tru_rtrcr_rtr_rx_int;
-- RTR Tx Frame ID
  regs_o.rtrcr_rtr_tx_o <= tru_rtrcr_rtr_tx_int;
-- HW Frame Rx Forward ID
  regs_o.hwfc_rx_fwd_id_o <= tru_hwfc_rx_fwd_id_int;
-- HW Frame Rx Block ID
  regs_o.hwfc_rx_blk_id_o <= tru_hwfc_rx_blk_id_int;
-- HW Frame Tx Forward ID
  regs_o.hwfc_tx_fwd_id_o <= tru_hwfc_tx_fwd_id_int;
-- HW Frame Tx Block ID
  regs_o.hwfc_tx_blk_id_o <= tru_hwfc_tx_blk_id_int;
-- HW Frame Tx Forward User Byte
  regs_o.hwfc_tx_fwd_ub_o <= tru_hwfc_tx_fwd_ub_int;
-- HW Frame Tx Block User Byte
  regs_o.hwfc_tx_blk_ub_o <= tru_hwfc_tx_blk_ub_int;
-- Filtering Database ID
  regs_o.ttr0_fid_o <= tru_ttr0_fid_int;
-- ID withing Filtering Database Entry
  regs_o.ttr0_sub_fid_o <= tru_ttr0_sub_fid_int;
-- Force TRU table sub-entry update
  process (bus_clock_int, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      tru_ttr0_update_dly0 <= '0';
      regs_o.ttr0_update_o <= '0';
    elsif rising_edge(bus_clock_int) then
      tru_ttr0_update_dly0 <= tru_ttr0_update_int;
      regs_o.ttr0_update_o <= tru_ttr0_update_int and (not tru_ttr0_update_dly0);
    end if;
  end process;
  
  
-- Entry Valid
  regs_o.ttr0_mask_valid_o <= tru_ttr0_mask_valid_int;
-- Pattern Mode
  regs_o.ttr0_patrn_mode_o <= tru_ttr0_patrn_mode_int;
-- Ingress Mask
  regs_o.ttr1_ports_ingress_o <= tru_ttr1_ports_ingress_int;
-- Egress Mask
  regs_o.ttr2_ports_egress_o <= tru_ttr2_ports_egress_int;
-- Egress Mask
  regs_o.ttr3_ports_mask_o <= tru_ttr3_ports_mask_int;
-- Pattern Match
  regs_o.ttr4_patrn_match_o <= tru_ttr4_patrn_match_int;
-- Patern Mask
  regs_o.ttr5_patrn_mask_o <= tru_ttr5_patrn_mask_int;
-- Port ID
  regs_o.dps_pid_o <= tru_dps_pid_int;
-- Injection Request
  process (bus_clock_int, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      tru_pidr_inject_dly0 <= '0';
      regs_o.pidr_inject_o <= '0';
    elsif rising_edge(bus_clock_int) then
      tru_pidr_inject_dly0 <= tru_pidr_inject_int;
      regs_o.pidr_inject_o <= tru_pidr_inject_int and (not tru_pidr_inject_dly0);
    end if;
  end process;
  
  
-- Packet Select
  regs_o.pidr_psel_o <= tru_pidr_psel_int;
-- USER VALUE
  regs_o.pidr_uval_o <= tru_pidr_uval_int;
-- Injection Ready
-- Clear register
  process (bus_clock_int, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      tru_pfdr_clr_dly0 <= '0';
      regs_o.pfdr_clr_o <= '0';
    elsif rising_edge(bus_clock_int) then
      tru_pfdr_clr_dly0 <= tru_pfdr_clr_int;
      regs_o.pfdr_clr_o <= tru_pfdr_clr_int and (not tru_pfdr_clr_dly0);
    end if;
  end process;
  
  
-- Filtered class
-- CNT
-- globalIngMask
  rwaddr_reg <= wb_addr_i;
-- ACK signal generation. Just pass the LSB of ACK counter.
  wb_ack_o <= ack_sreg(0);
end syn;
