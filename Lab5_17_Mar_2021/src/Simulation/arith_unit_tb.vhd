----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/15/2021 01:06:56 PM
-- Design Name: 
-- Module Name: arith_unit_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity arith_unit_tb is
  generic(g_WIDTH_AU_TB: integer := 4);
--  Port ( );
end arith_unit_tb;

architecture Behavioral of arith_unit_tb is
  
component arith_unit is
  generic (g_WIDTH_AU: integer := 4);
  port (
    i_arith_clk  : in  std_logic;
    i_arith_inst : in  std_logic_vector(1 downto 0);
    i_arith_a    : in  std_logic_vector(g_WIDTH_AU - 1 downto 0);
    i_arith_b    : in  std_logic_vector(g_WIDTH_AU - 1 downto 0);
    o_arith_data : out std_logic_vector((2*g_WIDTH_AU) - 1 downto 0)
    );
end component;

-- Testbench clock instantiation
constant clk_period: time := 10 ns; 

signal i_arith_clk_tb  : std_logic;
signal i_arith_inst_tb : std_logic_vector(1 downto 0);
signal i_arith_a_tb    : std_logic_vector(g_WIDTH_AU_TB - 1 downto 0);
signal i_arith_b_tb    : std_logic_vector(g_WIDTH_AU_TB - 1 downto 0);
signal o_arith_data_tb : std_logic_vector((2*g_WIDTH_AU_TB) - 1 downto 0);

begin
  p_CLOCK_GEN: process
  begin
    i_arith_clk_tb <= '1';
    wait for clk_period/2;
    i_arith_clk_tb <= '0';
    wait for clk_period/2;
  end process;
  
  AU_COMP: arith_unit
    generic map(g_WIDTH_AU => g_WIDTH_AU_TB)
    port map(
      i_arith_clk => i_arith_clk_tb,
      i_arith_inst => i_arith_inst_tb,
      i_arith_a => i_arith_a_tb,
      i_arith_b => i_arith_b_tb,
      o_arith_data => o_arith_data_tb
      );

  p_TEST_CASE: process
  begin
    i_arith_inst_tb <= "00";
    i_arith_a_tb <= "1000";
    i_arith_b_tb <= "0111";
    wait for 9*clk_period;
    i_arith_inst_tb <= "01";
    wait for 9*clk_period;
    i_arith_inst_tb <= "10";
    wait for 9*clk_period;
    i_arith_a_tb <= "1001";
    i_arith_b_tb <= "1001";
    wait for 9*clk_period;
    i_arith_inst_tb <= "01";
    wait for 9*clk_period;
    i_arith_inst_tb <= "00";
--    wait for 9*clk_period;
    wait;
  end process;
  
end Behavioral;
