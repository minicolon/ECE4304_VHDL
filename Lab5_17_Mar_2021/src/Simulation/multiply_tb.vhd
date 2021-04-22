----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2021 11:07:28 AM
-- Design Name: 
-- Module Name: multiply_tb - Behavioral
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

entity multiply_tb is
    generic (g_WIDTH_TB: integer := 4);
--  Port ( );
end multiply_tb;

architecture Behavioral of multiply_tb is

component multiply is
  generic (g_WIDTH_MULT: integer := 4);
  port (
    i_mult_clk  : in  std_logic;
    i_mult_a    : in  std_logic_vector(g_WIDTH_MULT - 1 downto 0);
    i_mult_b    : in  std_logic_vector(g_WIDTH_MULT - 1 downto 0);
    o_mult_prod : out std_logic_vector((g_WIDTH_MULT*2) - 1 downto 0)
    );
end component;

constant time_step: time := 10 ns;

signal temp_mult_clk_tb : std_logic;
signal temp_mult_a_tb   : std_logic_vector(g_WIDTH_TB - 1 downto 0);
signal temp_mult_b_tb   : std_logic_vector(g_WIDTH_TB - 1 downto 0);
signal temp_mult_prod_tb: std_logic_vector((g_WIDTH_TB*2) - 1 downto 0);

begin
  -- Generate a clock signal
  p_GEN_CLK: process
  begin
    temp_mult_clk_tb <= '1';
    wait for time_step/2;
    temp_mult_clk_tb <= '0';
    wait for time_step/2;    
  end process;
    
  -- Map the testbench signals with the component
  MULT_COMP: multiply
    generic map (g_WIDTH_MULT => g_WIDTH_TB)
    port map (
      i_mult_clk  => temp_mult_clk_tb,
      i_mult_a    => temp_mult_a_tb,
      i_mult_b    => temp_mult_b_tb,
      o_mult_prod => temp_mult_prod_tb
      );
 
  -- Process for testing the multiplier unit     
  p_TEST_CASE:process
  begin 
    -- Output should be 11100001 == 225
    temp_mult_a_tb <= "1111"; -- 15
    temp_mult_b_tb <= "1111"; -- 15
    wait for 10*time_step;
    
    -- Output should be 10001111 == 143
    temp_mult_a_tb <= "1011"; -- 11
    temp_mult_b_tb <= "1101"; -- 13
    wait for 10*time_step;
   
    -- Output should be 00000000 == 0
    temp_mult_a_tb <= "1000"; -- 8
    temp_mult_b_tb <= "0000"; -- 0
    wait for 10*time_step;
    
    -- Output should be 00001111 == 15   
    temp_mult_a_tb <= "0101"; -- 5
    temp_mult_b_tb <= "0011"; -- 3
    wait for 10*time_step;
    
    -- Output should be 00000000 == 0
    temp_mult_a_tb <= "0000"; -- 0
    temp_mult_b_tb <= "0000"; -- 0 
    wait;    
  end process;
end Behavioral;
