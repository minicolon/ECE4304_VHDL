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
    Port(
        i_sseg_en  : in  std_logic;                    -- Input the enable bit for the ssegs
        i_sseg_bcd : in  std_logic_vector(3 downto 0); -- Input the bcd data
        o_sseg     : out std_logic_vector(6 downto 0)  -- Output the selected data sseg data
        );
end BCD_To_Sseg;

architecture Behavioral of BCD_To_Sseg is

begin
    -- Process that assigns the output based on the BCD input
    p_SSEG:process (i_sseg_en, i_sseg_bcd)
    begin
        if(i_sseg_en = '1') then -- If enable is high, allow for the change and use of the sseg
            case i_sseg_bcd is
            when "0000" => o_sseg <= "1000000";
            when "0001" => o_sseg <= "1111001";
            when "0010" => o_sseg <= "0100100";
            when "0011" => o_sseg <= "0110000";
            when "0100" => o_sseg <= "0011001";
            when "0101" => o_sseg <= "0010010";
            when "0110" => o_sseg <= "0000010";
            when "0111" => o_sseg <= "1111000";
            when "1000" => o_sseg <= "0000000";
            when "1001" => o_sseg <= "0010000";
            when others => o_sseg <= (others => '1');
            end case;
        else -- When the enable is low turn the Sseg off
            o_sseg <= (others => '1');
        end if;
    end process;
end Behavioral;
