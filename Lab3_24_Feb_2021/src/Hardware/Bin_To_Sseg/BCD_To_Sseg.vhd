----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2021 08:26:18 PM
-- Design Name: 
-- Module Name: BCD_To_Sseg - Behavioral
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

-- Simple module that takes in a BCD value and outputs the same number in a format for a Sseg
entity BCD_To_Sseg is
    Port(-- Port instantiation
        i_En  : in  std_logic;
        i_BCD : in  std_logic_vector(3 downto 0);
        o_Sseg: out std_logic_vector(6 downto 0)
        );
end BCD_To_Sseg;

architecture Behavioral of BCD_To_Sseg is

begin
    -- Process that assigns the output based on the BCD input
    p_Sseg:process (i_En, i_BCD)
    begin
        if(i_En = '1') then -- If enable is high, allow for the change and use of the sseg
            case i_BCD is
            when "0000" => o_Sseg <= "1000000";
            when "0001" => o_Sseg <= "1111001";
            when "0010" => o_Sseg <= "0100100";
            when "0011" => o_Sseg <= "0110000";
            when "0100" => o_Sseg <= "0011001";
            when "0101" => o_Sseg <= "0010010";
            when "0110" => o_Sseg <= "0000010";
            when "0111" => o_Sseg <= "1111000";
            when "1000" => o_Sseg <= "0000000";
            when "1001" => o_Sseg <= "0010000";
            when others => o_Sseg <= (others => '1');
            end case;
        else -- When the enable is low turn the Sseg off
            o_Sseg <= (others => '1');
        end if;
    end process;
end Behavioral;
