----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2021 07:13:27 AM
-- Design Name: 
-- Module Name: sel_sseg_tb - Behavioral
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

entity sel_sseg_tb is
--  Port ( );
end sel_sseg_tb;

architecture Behavioral of sel_sseg_tb is

component sel_sseg is
    Port(
        i_clk: in  std_logic;
        i_rst: in  std_logic;
        o_An : out std_logic_vector(7 downto 0)
        );
end component;

signal i_clk_tb: std_logic;
signal i_rst_tb: std_logic;
signal o_An_tb : std_logic_vector(7 downto 0);


constant clk_period: time := 10 ns;

begin

    CLOCK_GEN: process
        begin
            i_clk_tb <= '1';
            wait for clk_period/2;
            i_clk_tb <= '0';
            wait for clk_period/2;
        end process;
    
    SEL_COMP: sel_sseg
        port map(
            i_clk => i_clk_tb,
            i_rst => i_rst_tb,
            o_An => o_An_tb
            );
            
    TEST_CASE:process
        begin
            i_rst_tb <= '1';
            wait for clk_period;    
            i_rst_tb <= '0';
            wait for 5*clk_period;
            i_rst_tb <= '1';
            wait for 3*clk_period;
            i_rst_tb <= '0';
            wait;
        end process;    
end Behavioral;
