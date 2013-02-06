---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for Topology Resolution Unit (TRU)
---------------------------------------------------------------------------------------
-- File           : tru_wbgen2_pkg.vhd
-- Author         : auto-generated by wbgen2 from tru_wishbone_slave.wb
-- Created        : Wed Feb  6 16:23:27 2013
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE tru_wishbone_slave.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tru_wbgen2_pkg is
  
  
  -- Input registers (user design -> WB slave)
  
  type t_tru_in_registers is record
    gsr0_stat_bank_i                         : std_logic;
    gsr0_stat_stb_up_i                       : std_logic_vector(23 downto 0);
    gsr1_stat_up_i                           : std_logic_vector(31 downto 0);
    tsr_trans_stat_active_i                  : std_logic;
    tsr_trans_stat_finished_i                : std_logic;
    pidr_iready_i                            : std_logic;
    pfdr_class_i                             : std_logic_vector(7 downto 0);
    pfdr_cnt_i                               : std_logic_vector(15 downto 0);
    ptrdr_ging_mask_i                        : std_logic_vector(31 downto 0);
    end record;
  
  constant c_tru_in_registers_init_value: t_tru_in_registers := (
    gsr0_stat_bank_i => '0',
    gsr0_stat_stb_up_i => (others => '0'),
    gsr1_stat_up_i => (others => '0'),
    tsr_trans_stat_active_i => '0',
    tsr_trans_stat_finished_i => '0',
    pidr_iready_i => '0',
    pfdr_class_i => (others => '0'),
    pfdr_cnt_i => (others => '0'),
    ptrdr_ging_mask_i => (others => '0')
    );
    
    -- Output registers (WB slave -> user design)
    
    type t_tru_out_registers is record
      gcr_g_ena_o                              : std_logic;
      gcr_tru_bank_o                           : std_logic;
      gcr_rx_frame_reset_o                     : std_logic_vector(23 downto 0);
      mcr_pattern_mode_rep_o                   : std_logic_vector(3 downto 0);
      mcr_pattern_mode_add_o                   : std_logic_vector(3 downto 0);
      lacr_agg_df_hp_id_o                      : std_logic_vector(3 downto 0);
      lacr_agg_df_br_id_o                      : std_logic_vector(3 downto 0);
      lacr_agg_df_un_id_o                      : std_logic_vector(3 downto 0);
      tcgr_trans_ena_o                         : std_logic;
      tcgr_trans_clear_o                       : std_logic;
      tcgr_trans_mode_o                        : std_logic_vector(2 downto 0);
      tcgr_trans_rx_id_o                       : std_logic_vector(2 downto 0);
      tcgr_trans_prio_o                        : std_logic_vector(2 downto 0);
      tcgr_trans_prio_mode_o                   : std_logic;
      tcgr_trans_time_diff_o                   : std_logic_vector(15 downto 0);
      tcpr_trans_port_a_id_o                   : std_logic_vector(5 downto 0);
      tcpr_trans_port_a_valid_o                : std_logic;
      tcpr_trans_port_b_id_o                   : std_logic_vector(5 downto 0);
      tcpr_trans_port_b_valid_o                : std_logic;
      rtrcr_rtr_ena_o                          : std_logic;
      rtrcr_rtr_reset_o                        : std_logic;
      rtrcr_rtr_mode_o                         : std_logic_vector(3 downto 0);
      rtrcr_rtr_rx_o                           : std_logic_vector(3 downto 0);
      rtrcr_rtr_tx_o                           : std_logic_vector(3 downto 0);
      ttr0_fid_o                               : std_logic_vector(7 downto 0);
      ttr0_sub_fid_o                           : std_logic_vector(7 downto 0);
      ttr0_update_o                            : std_logic;
      ttr0_mask_valid_o                        : std_logic;
      ttr0_patrn_mode_o                        : std_logic_vector(3 downto 0);
      ttr1_ports_ingress_o                     : std_logic_vector(31 downto 0);
      ttr2_ports_egress_o                      : std_logic_vector(31 downto 0);
      ttr3_ports_mask_o                        : std_logic_vector(31 downto 0);
      ttr4_patrn_match_o                       : std_logic_vector(31 downto 0);
      ttr5_patrn_mask_o                        : std_logic_vector(31 downto 0);
      dps_pid_o                                : std_logic_vector(7 downto 0);
      pidr_inject_o                            : std_logic;
      pidr_psel_o                              : std_logic_vector(2 downto 0);
      pidr_uval_o                              : std_logic_vector(15 downto 0);
      pfdr_clr_o                               : std_logic;
      end record;
    
    constant c_tru_out_registers_init_value: t_tru_out_registers := (
      gcr_g_ena_o => '0',
      gcr_tru_bank_o => '0',
      gcr_rx_frame_reset_o => (others => '0'),
      mcr_pattern_mode_rep_o => (others => '0'),
      mcr_pattern_mode_add_o => (others => '0'),
      lacr_agg_df_hp_id_o => (others => '0'),
      lacr_agg_df_br_id_o => (others => '0'),
      lacr_agg_df_un_id_o => (others => '0'),
      tcgr_trans_ena_o => '0',
      tcgr_trans_clear_o => '0',
      tcgr_trans_mode_o => (others => '0'),
      tcgr_trans_rx_id_o => (others => '0'),
      tcgr_trans_prio_o => (others => '0'),
      tcgr_trans_prio_mode_o => '0',
      tcgr_trans_time_diff_o => (others => '0'),
      tcpr_trans_port_a_id_o => (others => '0'),
      tcpr_trans_port_a_valid_o => '0',
      tcpr_trans_port_b_id_o => (others => '0'),
      tcpr_trans_port_b_valid_o => '0',
      rtrcr_rtr_ena_o => '0',
      rtrcr_rtr_reset_o => '0',
      rtrcr_rtr_mode_o => (others => '0'),
      rtrcr_rtr_rx_o => (others => '0'),
      rtrcr_rtr_tx_o => (others => '0'),
      ttr0_fid_o => (others => '0'),
      ttr0_sub_fid_o => (others => '0'),
      ttr0_update_o => '0',
      ttr0_mask_valid_o => '0',
      ttr0_patrn_mode_o => (others => '0'),
      ttr1_ports_ingress_o => (others => '0'),
      ttr2_ports_egress_o => (others => '0'),
      ttr3_ports_mask_o => (others => '0'),
      ttr4_patrn_match_o => (others => '0'),
      ttr5_patrn_mask_o => (others => '0'),
      dps_pid_o => (others => '0'),
      pidr_inject_o => '0',
      pidr_psel_o => (others => '0'),
      pidr_uval_o => (others => '0'),
      pfdr_clr_o => '0'
      );
    function "or" (left, right: t_tru_in_registers) return t_tru_in_registers;
    function f_x_to_zero (x:std_logic) return std_logic;
end package;

package body tru_wbgen2_pkg is
function f_x_to_zero (x:std_logic) return std_logic is
begin
if(x = 'X' or x = 'U') then
return '0';
else
return x;
end if; 
end function;
function "or" (left, right: t_tru_in_registers) return t_tru_in_registers is
variable tmp: t_tru_in_registers;
begin
tmp.gsr0_stat_bank_i := left.gsr0_stat_bank_i or right.gsr0_stat_bank_i;
tmp.gsr0_stat_stb_up_i := left.gsr0_stat_stb_up_i or right.gsr0_stat_stb_up_i;
tmp.gsr1_stat_up_i := left.gsr1_stat_up_i or right.gsr1_stat_up_i;
tmp.tsr_trans_stat_active_i := left.tsr_trans_stat_active_i or right.tsr_trans_stat_active_i;
tmp.tsr_trans_stat_finished_i := left.tsr_trans_stat_finished_i or right.tsr_trans_stat_finished_i;
tmp.pidr_iready_i := left.pidr_iready_i or right.pidr_iready_i;
tmp.pfdr_class_i := left.pfdr_class_i or right.pfdr_class_i;
tmp.pfdr_cnt_i := left.pfdr_cnt_i or right.pfdr_cnt_i;
tmp.ptrdr_ging_mask_i := left.ptrdr_ging_mask_i or right.ptrdr_ging_mask_i;
return tmp;
end function;
end package body;
