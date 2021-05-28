----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2021 02:32:17 PM
-- Design Name: 
-- Module Name: counter_tb - Behavioral
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

entity counter_tb is
  generic(g_WIDTH_TB: integer := 4);
--  Port ( );
end counter_tb;

architecture Behavioral of counter_tb is

component generic_counter is
  generic(g_WIDTH_COUNTER: integer := 7);
  port(
    i_count_clk : in std_logic;                                       -- Input a clock for the counter
    i_count_rst : in std_logic;                                       -- Input a reset of the counter
    o_count_tick: out std_logic
    );
end component;

constant clk_period: time := 10 ns;

signal i_count_clk_tb: std_logic;
signal i_count_rst_tb: std_logic;
signal o_count_tick_tb: std_logic;

begin
  COUNT_COMP: generic_counter
    generic map(g_WIDTH_COUNTER => g_WIDTH_TB)
    port map(
      i_count_clk  => i_count_clk_tb,
      i_count_rst  => i_count_rst_tb,
      o_count_tick => o_count_tick_tb
      );
  
  p_CLOCK_GEN: process
  begin
    i_count_clk_tb <= '1';
    wait for clk_period/2;
    i_count_clk_tb <= '0';
    wait for clk_period/2;
  end process;
  
  p_TEST_CASE: process
  begin
    i_count_rst_tb <= '1';
    wait for clk_period;
    i_count_rst_tb <= '0';
    wait;
  end process;
end Behavioral;
