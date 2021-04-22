----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2021 01:41:57 PM
-- Design Name: 
-- Module Name: sel_sseg - sel_arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real."log2";
use IEEE.math_real."ceil";
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Selecter for the seven segment outputs
entity sel_sseg is
  port (
    i_sseg_clk  : in  std_logic;                     -- Input clock for sseg selector
    i_sseg_a    : in  std_logic_vector(6 downto 0);  -- Input sseg A value
    i_sseg_b    : in  std_logic_vector(6 downto 0);  -- Input sseg B value
    i_sseg_au_0 : in  std_logic_vector(6 downto 0);  -- Input Ones sseg value
    i_sseg_au_1 : in  std_logic_vector(6 downto 0);  -- Input tens sseg value
    o_sseg_sel  : out std_logic_vector(6 downto 0);  -- Output selected sseg
    o_sseg_an   : out std_logic_vector(7 downto 0)   -- Output sseg anode
    );
end sel_sseg;

architecture sel_arch of sel_sseg is

component generic_counter is
  generic(g_WIDTH_COUNTER: integer := 7);
  port(
    i_count_clk : in std_logic;                                       -- Input a clock for the counter
    i_count_rst : in std_logic;                                       -- Input a reset of the counter
    o_count     : out std_logic_vector(g_WIDTH_COUNTER - 1 downto 0)  -- Output the current counter value
    );
end component;

component generic_mux_Nx1 is
  generic(g_WIDTH_MUX_DATA: integer := 16; g_MUX_INPUTS: integer := 4);                     -- Parameter for data width size, and amount of inputs desired
  Port(
    i_mux_sel : in  std_logic_vector(integer(ceil(log2(real(g_MUX_INPUTS)))) - 1 downto 0); -- Input select for multiplexer
    i_mux_data: in  std_logic_vector((g_WIDTH_MUX_DATA*g_MUX_INPUTS) - 1 downto 0);         -- Input data as single vector for multiplexer
    o_mux_data: out std_logic_vector(g_WIDTH_MUX_DATA - 1 downto 0)                         -- output selected data for multiplexer
    );
end component;

component decoder_2x4 is
  port(
    i_En  : in   std_logic;                    -- Input enable bit
    i_Din : in   std_logic_vector(1 downto 0); -- Input data 
    o_Dout: out  std_logic_vector(3 downto 0)  -- Output decoded data
    );
end component;

constant slow_bits: integer := 20;  -- Sets the speed to cycle through each sseg

signal temp_count: std_logic_vector(slow_bits - 1 downto 0); -- Holds the count value
signal temp_mux_input: std_logic_vector(27 downto 0); -- 4 sseg inputs, 7 bits each
signal temp_anode: std_logic_vector(3 downto 0); -- Holds decoder output before inverting

begin
  SLOW_CLK_COMP: generic_counter
    generic map (g_WIDTH_COUNTER => slow_bits)
    port map(
      i_count_clk => i_sseg_clk,
      i_count_rst => '0',
      o_count     => temp_count
      );
  
  -- Format of the sseg mux data
  temp_mux_input <= i_sseg_au_1 & i_sseg_au_0 & i_sseg_a & i_sseg_b;
  
  SSEG_MUX_COMP: generic_mux_Nx1
    generic map(g_WIDTH_MUX_DATA => 7, g_MUX_INPUTS => 4)
    port map(
      i_mux_sel => temp_count(slow_bits - 1 downto slow_bits - 2),
      i_mux_data => temp_mux_input,
      o_mux_data => o_sseg_sel
      );

  AN_DECODER_COMP: decoder_2x4
    port map(
      i_En => '1',
      i_Din => temp_count(slow_bits - 1 downto slow_bits - 2),
      o_Dout => temp_anode
      );

  -- The output for the anodes
  o_sseg_an <= "11" & (not temp_anode(3 downto 2)) & "11" & (not temp_anode(1 downto 0));
end sel_arch;
