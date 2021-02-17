----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2021 06:19:41 AM
-- Design Name: 
-- Module Name: g_mux_2x1_tb - Behavioral
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

-- Testbench to test the functionality of the 2x1 mux
entity g_mux_2x1_tb is
    generic(g_WIDTH_tb: integer := 16);
--  Port ( );
end g_mux_2x1_tb;

architecture Behavioral of g_mux_2x1_tb is

-- Instnatiate the component
component generic_mux_2x1 is
    generic(g_WIDTH: integer := 16);
    Port( -- Port instantiation
        i_Sel : in  std_logic;
        i_D0  : in  std_logic_vector(g_WIDTH - 1 downto 0);
        i_D1  : in  std_logic_vector(g_WIDTH - 1 downto 0);
        o_Dout: out std_logic_vector(g_WIDTH - 1 downto 0)
        );
end component;

-- Create custom testbench signals
signal i_Sel_tb : std_logic;
signal i_D0_tb  : std_logic_vector(g_WIDTH_tb - 1 downto 0);
signal i_D1_tb  : std_logic_vector(g_WIDTH_tb - 1 downto 0);
signal o_Dout_tb: std_logic_vector(g_WIDTH_tb - 1 downto 0);

-- Constant that simulates a custom 100MHz clocks
constant clock_period:time := 10 ns;

begin
    MUX_COMP: generic_mux_2x1 -- Map both the ports and generic parameter
        generic map (g_WIDTH => g_WIDTH_tb)
        port map(
            i_Sel  => i_Sel_tb,
            i_D0   => i_D0_tb,
            i_D1   => i_D1_tb,
            o_Dout => o_Dout_tb
            );
    -- Simple test to determine if mux works as intended
    TEST_CASE_1: process
        begin
            i_Sel_tb <= '0';
            i_D0_tb  <= x"0020";
            i_D1_tb  <= x"F000";
            wait for clock_period;
            i_Sel_tb <= '1';
            wait for clock_period;
            i_D0_tb  <= x"3000";
            i_D1_tb  <= x"0060";
            wait for clock_period;           
        end process;
end Behavioral;
