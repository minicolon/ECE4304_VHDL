----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2021 08:05:27 AM
-- Design Name: 
-- Module Name: decoder_2x4_tb - Behavioral
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

-- Testbench to test the 2x4 decoder's functionality
entity decoder_2x4_tb is
--  Port ( );
end decoder_2x4_tb;

architecture Behavioral of decoder_2x4_tb is

-- Instantiate component
component decoder_2x4 is
    Port (
        i_En  : in   std_logic;
        i_Din : in   std_logic_vector(1 downto 0);
        o_Dout: out  std_logic_vector(3 downto 0)
        );
end component;

-- Create custom testbench signals
signal i_En_tb  : std_logic;
signal i_Din_tb : std_logic_vector(1 downto 0);
signal o_Dout_tb: std_logic_vector(3 downto 0);

-- Constant tha simulates a 100MHz clock
constant clock_period:time := 10 ns;

begin

-- Map the base 2x4 decoder to testbench signals
DECODER_COMP: decoder_2x4 port map(
    i_En => i_En_tb,
    i_Din => i_Din_tb,
    o_Dout => o_Dout_tb
    );

-- Process to test all 4 output variants work as intended
TEST_CASE_1: process
begin
    i_En_tb <= '0';
    i_Din_tb <= "11";
    wait for clock_period;
    i_En_tb <= '1';
    wait for clock_period;
    i_Din_tb <= "10";
    wait for clock_period;    
    i_En_tb <= '0';
    i_Din_tb <= "01";
    wait for clock_period;
    i_Din_tb <= "00";
    wait for clock_period;
    i_En_tb <= '1';
    wait for clock_period;
end process;

end Behavioral;
