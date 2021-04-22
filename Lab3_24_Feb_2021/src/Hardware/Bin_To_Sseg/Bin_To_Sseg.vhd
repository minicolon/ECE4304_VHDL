----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2021 03:43:28 PM
-- Design Name: 
-- Module Name: Bin_To_Sseg - Behavioral
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

-- Entity that Takes in a binary value, converts it to BCD, and then outputs the appropriate Sseg representation
entity Bin_To_Sseg is
    Port(
        i_En_Sseg  : in  std_logic;
        i_Binary_SW: in  std_logic_vector(3 downto 0);
        o_Sseg_Disp: out std_logic_vector(6 downto 0)
        );
end Bin_To_Sseg;

architecture Behavioral of Bin_To_Sseg is

component Bin_To_BCD is
    Port( -- Port instantiation
        i_Binary: in  std_logic_vector(3 downto 0);
        o_BCD   : out std_logic_vector(3 downto 0)
        );
end component;

component BCD_To_Sseg is
    Port( -- Port instantiation
        i_En  : in  std_logic;
        i_BCD : in  std_logic_vector(3 downto 0);
        o_Sseg: out std_logic_vector(6 downto 0)
        );
end component;

-- Temp signal that takes the output BCD of one componenet and places it into the input of the other
signal temp_BCD: std_logic_vector(3 downto 0);

begin
    TO_BCD_COMP: Bin_To_BCD port map(
        i_Binary => i_Binary_SW,
        o_BCD    => temp_BCD
        );
        
    TO_SSEG_COMP: BCD_To_SSEG port map(
        i_En   => i_En_Sseg,
        i_BCD  => temp_BCD,
        o_Sseg => o_Sseg_Disp
        );   
end Behavioral;
