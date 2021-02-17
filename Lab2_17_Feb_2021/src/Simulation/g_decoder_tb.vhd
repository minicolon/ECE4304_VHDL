----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2021 12:30:31 PM
-- Design Name: 
-- Module Name: g_decoder_tb - Behavioral
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

-- Testbench to determine if decoder network works properly
entity g_decoder_tb is
    generic (g_WIDTH_tb: integer := 5);
--  Port ( );
end g_decoder_tb;

architecture Behavioral of g_decoder_tb is

-- Instantiate generic decoder component
component generic_decoder is
    generic (g_WIDTH: integer := 5);
    Port (
        i_Din_gen: in std_logic_vector(g_WIDTH - 1 downto 0);
        o_Dout_gen: out std_logic_vector(2**g_WIDTH - 1 downto 0)
    );
end component;

-- Create custom testbench signals
signal i_Din_tb : std_logic_vector(g_WIDTH_tb - 1 downto 0);
signal o_Dout_tb: std_logic_vector(2**g_WIDTH_tb - 1 downto 0);

-- Generate a clock period that simulates 100MHz
constant clock_period:time := 10 ns;

begin
-- Map decoder to testbench signals
DECODER_COMP: generic_decoder 
    generic map(g_WIDTH => g_WIDTH_tb)
    port map(
    i_Din_gen => i_Din_tb,
    o_Dout_gen => o_Dout_tb
    );

-- process to test the generic decoder by varying the input 
TEST_CASE_1: process
begin
    i_Din_tb <= "11111";
    wait for clock_period;
    i_Din_tb <= "11110";
    wait for clock_period;    
    i_Din_tb <= "11101";
    wait for clock_period;
    i_Din_tb <= "11100";
    wait for clock_period;
    i_Din_tb <= "11011";
    wait for clock_period;
    i_Din_tb <= "11010";
    wait for clock_period;
    i_Din_tb <= "10000";
    wait for clock_period;
    i_Din_tb <= "01111";
    wait for clock_period;
    i_Din_tb <= "00000";
    wait for clock_period;
    wait;
end process;


end Behavioral;
