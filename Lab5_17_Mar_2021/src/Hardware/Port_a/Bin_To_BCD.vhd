----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2021 08:15:04 PM
-- Design Name: 
-- Module Name: Bin_To_BCD - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Entity that converts from binary to valid BCD values
entity Bin_To_BCD is
    Port(-- Port instantiation
        i_Binary: in std_logic_vector(3 downto 0);
        o_BCD: out std_logic_vector(3 downto 0)
        );
end Bin_To_BCD;

architecture Behavioral of Bin_To_BCD is

begin
    p_CONVERT: process(i_Binary)
    variable v_Binary: std_logic_vector(3 downto 0); -- Temp variable to hold the input value
    begin
        if i_Binary > x"9" then -- If the input value is higher than 9 add 6 to make the value valid
            v_Binary := i_Binary + 6;
        elsif i_Binary <= x"9" then --If the input is less than 9, then it is valid and can directly be assigned
            v_Binary := i_Binary;
        else -- If no condition is met then set the variable to 0
            v_Binary := (others => '0');
        end if;
        
        o_BCD <= v_Binary;
    end process;
    
end Behavioral;
