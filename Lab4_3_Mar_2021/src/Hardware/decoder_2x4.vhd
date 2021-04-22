----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2021 05:51:24 AM
-- Design Name: 
-- Module Name: decoder_2x4 - decoder_2x4_arch
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

-- Base 2x4 decoder with 2 bit input and a 4 bit output, which operates based on an enable
entity decoder_2x4 is
    Port(
        i_En  : in   std_logic;                    -- Input enable bit
        i_Din : in   std_logic_vector(1 downto 0); -- Input data 
        o_Dout: out  std_logic_vector(3 downto 0)  -- Output decoded data
        );
end decoder_2x4;

architecture decoder_2x4_arch of decoder_2x4 is

begin
    -- Process that takes in enable and a single input
    p_DECODER: process (i_En, i_Din)
    begin
        if(i_En = '1') then -- When enable is high determine output based on Din
            case i_Din is
            when "00"   => o_Dout <= "0001";
            when "01"   => o_Dout <= "0010";
            when "10"   => o_Dout <= "0100";
            when "11"   => o_Dout <= "1000";
            when others => o_Dout <= (others => '0');
            end case;
        else -- When enable is low tie the output to 0
            o_Dout <= (others => '0');
        end if;
    end process;

end decoder_2x4_arch;
