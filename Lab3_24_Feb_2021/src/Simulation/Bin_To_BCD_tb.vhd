----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2021 03:13:06 PM
-- Design Name: 
-- Module Name: Bin_To_BCD_tb - Behavioral
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

entity Bin_To_BCD_tb is
--  Port ( );
end Bin_To_BCD_tb;

architecture Behavioral of Bin_To_BCD_tb is

component Bin_To_BCD is
    Port(
        i_Binary: in std_logic_vector(3 downto 0);
        o_BCD: out std_logic_vector(3 downto 0)
        );
end component;

signal i_Binary_tb: std_logic_vector(3 downto 0);
signal o_BCD_tb: std_logic_vector(3 downto 0);

constant clk_period: time := 10 ns;

begin
    CONVERT_COMP: Bin_To_BCD port map(
        i_Binary => i_Binary_tb,
        o_BCD => o_BCD_tb
        );
        
    TEST_CASE: process
    begin
        i_Binary_tb <= x"0";
        wait for clk_period;
        i_Binary_tb <= x"1";
        wait for clk_period;
        i_Binary_tb <= x"2";
        wait for clk_period;
        i_Binary_tb <= x"3";
        wait for clk_period;
        i_Binary_tb <= x"4";
        wait for clk_period;
        i_Binary_tb <= x"5";
        wait for clk_period;
        i_Binary_tb <= x"6";
        wait for clk_period;
        i_Binary_tb <= x"7";
        wait for clk_period;
        i_Binary_tb <= x"8";
        wait for clk_period;
        i_Binary_tb <= x"9";
        wait for clk_period;
        i_Binary_tb <= x"A";
        wait for clk_period;
        i_Binary_tb <= x"B";
        wait for clk_period;
        i_Binary_tb <= x"C";
        wait for clk_period;
        i_Binary_tb <= x"D";
        wait for clk_period;
        i_Binary_tb <= x"E";
        wait for clk_period;
        i_Binary_tb <= x"F";
        wait;  
    end process;
    
end Behavioral;
