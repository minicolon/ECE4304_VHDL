----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2021 01:30:04 PM
-- Design Name: 
-- Module Name: add_sub_tb - Behavioral
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

entity add_sub_tb is
    generic (g_WIDTH_TB: integer := 4);
--  Port ( );
end add_sub_tb;

architecture Behavioral of add_sub_tb is

component add_sub is
  generic (g_WIDTH_AS: integer := 4);
  port (
    i_add_sub_sel    : in  std_logic; -- Enable determines whether to add or subtract
    i_add_sub_a     : in  std_logic_vector(g_WIDTH_AS - 1 downto 0);
    i_add_sub_b     : in  std_logic_vector(g_WIDTH_AS - 1 downto 0);
    o_add_sub_sum   : out std_logic_vector(g_WIDTH_AS - 1 downto 0);
    o_add_sub_carry : out std_logic
    );
end component;

constant time_step: time := 10 ns;

-- Testbench signals for add_shift component
signal i_add_sub_en_tb   : std_logic;
signal i_add_sub_a_tb    : std_logic_vector(g_WIDTH_TB - 1 downto 0);
signal i_add_sub_b_tb    : std_logic_vector(g_WIDTH_TB - 1 downto 0);
signal i_add_sub_sum_tb  : std_logic_vector(g_WIDTH_TB - 1 downto 0);
signal i_add_sub_carry_tb: std_logic;

begin
  ADD_SUB_COMP: add_sub
    generic map (g_WIDTH_AS => g_WIDTH_TB)
    port map (
      i_add_sub_sel    => i_add_sub_en_tb,
      i_add_sub_a     => i_add_sub_a_tb,
      i_add_sub_b     => i_add_sub_b_tb,
      o_add_sub_sum   => i_add_sub_sum_tb,
      o_add_sub_carry => i_add_sub_carry_tb
      );
  
  p_TEST_CASE: process
  begin
    i_add_sub_en_tb <= '0';
    i_add_sub_a_tb <= "0101";
    i_add_sub_b_tb <= "0011"; 
    wait for time_step;
    i_add_sub_a_tb <= "0000";
    i_add_sub_b_tb <= "0000";
    wait for time_step;
    i_add_sub_a_tb <= "1001";
    i_add_sub_b_tb <= "1001";
    wait for time_step;
    i_add_sub_a_tb <= "1111";
    i_add_sub_b_tb <= "1000";
    wait for time_step; 
    i_add_sub_a_tb <= "1111";
    i_add_sub_b_tb <= "0010";
    wait for time_step;
    i_add_sub_a_tb <= "1111";
    i_add_sub_b_tb <= "0000";
    wait for time_step;
    i_add_sub_a_tb <= "1111";
    i_add_sub_b_tb <= "1111";
    wait for time_step;
    i_add_sub_en_tb <= '1';
    i_add_sub_a_tb <= "0000";
    i_add_sub_b_tb <= "0000";
    wait for time_step;
    i_add_sub_a_tb <= "0101";
    i_add_sub_b_tb <= "0011"; 
    wait for time_step;
    i_add_sub_a_tb <= "1000";
    i_add_sub_b_tb <= "0100";
    wait for time_step;
    i_add_sub_a_tb <= "1001";
    i_add_sub_b_tb <= "0101"; 
    wait for time_step;
    i_add_sub_a_tb <= "1111";
    i_add_sub_b_tb <= "1000";
    wait for time_step; 
    i_add_sub_a_tb <= "1111";
    i_add_sub_b_tb <= "0010";
    wait for time_step;
    i_add_sub_a_tb <= "1111";
    i_add_sub_b_tb <= "0000";
    wait for time_step;
    i_add_sub_a_tb <= "1111";
    i_add_sub_b_tb <= "1111";
    wait;  
  end process;
end Behavioral;
