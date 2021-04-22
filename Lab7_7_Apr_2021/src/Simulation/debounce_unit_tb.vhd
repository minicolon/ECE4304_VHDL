----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2021 02:10:02 PM
-- Design Name: 
-- Module Name: debounce_unit_tb - Behavioral
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

entity debounce_unit_tb is
--  Port ( );
end debounce_unit_tb;

architecture Behavioral of debounce_unit_tb is

component debounce_unit is
  port (
    i_db_clk: in std_logic;  -- Input clock
    i_db_rst: in std_logic;  -- Input reset
    i_db_btn: in std_logic;  -- Input button to debounce
    o_db_new: out std_logic  -- Output Debounced signal
    );
end component;

constant clk_period: time := 0.01 ns; 

signal i_db_clk_tb: std_logic;
signal i_db_rst_tb: std_logic;
signal i_db_btn_tb: std_logic;
signal o_db_new_tb: std_logic;

begin
  p_CLOCK_GEN: process
  begin
    i_db_clk_tb <= '1';
    wait for clk_period/2;
    i_db_clk_tb <= '0';
    wait for clk_period/2;
  end process;

  DB_COMP: debounce_unit
    port map(
      i_db_clk => i_db_clk_tb,
      i_db_rst => i_db_rst_tb,
      i_db_btn => i_db_btn_tb,
      o_db_new => o_db_new_tb
      );

  p_TEST_CASE: process
  begin
    i_db_rst_tb <= '1';
    wait for clk_period;
    i_db_rst_tb <= '0';
    wait for clk_period;
    i_db_btn_tb <= '1';
    wait for 2*clk_period;
    i_db_btn_tb <= '0';
    wait for 3*clk_period;
    i_db_btn_tb <= '1';
    wait for 1*clk_period;
    i_db_btn_tb <= '0';
    wait for 1*clk_period;
    i_db_btn_tb <= '1';
    wait for 10 ns;
    i_db_btn_tb <= '0';
    
    wait for 200*clk_period;
    i_db_btn_tb <= '1';
    wait for 2*clk_period;
    i_db_btn_tb <= '0';
    wait for 3*clk_period;
    i_db_btn_tb <= '1';
    wait for 1*clk_period;
    i_db_btn_tb <= '0';
    wait for 1*clk_period;
    i_db_btn_tb <= '1';
    wait for 10 ns;
    i_db_btn_tb <= '0';
    wait;
  end process;
end Behavioral;
