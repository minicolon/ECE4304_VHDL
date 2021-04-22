----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2021 06:48:47 AM
-- Design Name: 
-- Module Name: hex_to_sseg - to_sseg_arch
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

entity hex_to_sseg is
  Port(
    i_hex  : in  std_logic_vector(3 downto 0); -- Input hex value
    i_en   : in  std_logic;                    -- Input enable
    o_sseg : out std_logic_vector(6 downto 0)  -- Output sseg hex equivalent
    );
end hex_to_sseg;

architecture to_sseg_arch of hex_to_sseg is

begin
  CONVERT:process(i_hex, i_en)
  begin
    if(i_en = '1') then
      case i_hex is
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
        when "1010" => o_sseg <= "0001000";
        when "1011" => o_sseg <= "0000011";
        when "1100" => o_sseg <= "1000110";
        when "1101" => o_sseg <= "0100001";
        when "1110" => o_sseg <= "0000110";
        when "1111" => o_sseg <= "0001110";
        when others => o_sseg <= (others => '1');
        end case;
    else
      o_sseg <= (others => '1');
    end if;
  end process;

end to_sseg_arch;
