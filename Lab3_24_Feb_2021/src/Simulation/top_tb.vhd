----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2021 08:09:08 AM
-- Design Name: 
-- Module Name: top_tb - Behavioral
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

entity top_tb is
     generic(g_SLOW_BITS_TB: integer := 3);
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is
component top is
    generic(g_SLOW_BITS_TOP: integer := 18);
    Port(
        i_clk_top: in std_logic;
        i_rst_top: in std_logic;
        i_SW_top: in std_logic_vector(7 downto 0);
        o_Sseg_top: out std_logic_vector(6 downto 0);
        o_An_top: out std_logic_vector(7 downto 0);
        o_DP_top: out std_logic
        );
end component;
constant clk_period: time := 10 ns;
signal i_clk_tb: std_logic;
signal i_rst_tb: std_logic;
signal i_SW_tb : std_logic_vector(7 downto 0);
signal o_Sseg_tb: std_logic_vector(6 downto 0);
signal o_An_tb : std_logic_vector(7 downto 0);
signal o_DP_tb: std_logic;

begin
    CLOCK_GEN: process
        begin
            i_clk_tb <= '1';
            wait for clk_period/2;
            i_clk_tb <= '0';
            wait for clk_period/2;
        end process;
    
    TOP_COMP: top
        generic map(g_SLOW_BITS_TOP => g_SLOW_BITS_TB)
        port map(
            i_clk_top => i_clk_tb,
            i_rst_top => i_rst_tb,
            i_SW_top => i_SW_tb,
            o_Sseg_top => o_Sseg_tb,
            o_An_top => o_An_tb,
            o_DP_top => o_DP_tb
            );
            
    TEST_CASE:process
        begin
            i_rst_tb <= '1';
            wait for 6*clk_period;    
            
            
            i_SW_tb <= x"12";
            wait for clk_period;
            i_rst_tb <= '0';
            wait for 7*clk_period;
            i_SW_tb <= x"08";
            wait for 8*clk_period;
            i_SW_tb <= x"35";
            wait for 8*clk_period;
            i_SW_tb <= x"0F";
            wait for 8*clk_period;
            i_SW_tb <= x"A0";
            wait for 8*clk_period;
--            i_rst_tb <= '1';
--            wait for 3*clk_period;
--            i_rst_tb <= '0';
            wait;
        end process; 
end Behavioral;
