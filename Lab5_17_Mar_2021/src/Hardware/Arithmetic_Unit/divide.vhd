----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2021 07:54:26 AM
-- Design Name: 
-- Module Name: divide - divide_arch
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--Divider hardware circuit
entity divide is
  generic (g_WIDTH_DIV : integer := 4);                              -- Generic data width parameter
  port (
    i_div_clk : in  std_logic;                                       -- Input clock
    i_div_a   : in  std_logic_vector(g_WIDTH_DIV - 1 downto 0);      -- Input port A
    i_div_b   : in  std_logic_vector(g_WIDTH_DIV - 1 downto 0);      -- input port B
--    errorsig:     out std_logic := '0';
    o_div_remain:   out std_logic_vector(g_WIDTH_DIV - 1 downto 0);
    o_div_qt  : out std_logic_vector((g_WIDTH_DIV) - 1 downto 0)   -- Output the quotient
    );
end divide;

architecture divide_arch of divide is

begin
DIV: process(i_div_clk, i_div_a, i_div_b)
        variable quotient:  std_logic_vector(3 downto 0);
        variable remainder: std_logic_vector(3 downto 0);
    begin
--            errorsig <= '0';  
      if(rising_edge(i_div_clk)) then   
    -- allows successive operations
--        if i_div_b = "0000" then
--            assert  i_div_b /= "0000"
----                report "Division by Zero Exception"
--                severity ERROR;
--            errorsig <= '1';
--        else 
            quotient := (others => '0'); -- "0000"
            remainder := (others => '0');
           for i in 3 downto 0 loop  
               remainder := remainder (2 downto 0) & '0';   -- r << 1
               remainder(0) := i_div_a(i);       -- operanda is numerator
               if remainder >= i_div_b then  -- operandb denominator
                    remainder := remainder - i_div_b;
                    quotient(i) := '1';
               end if;
            end loop;
            o_div_qt <= std_logic_vector(quotient); -- for error keeps
            o_div_remain  <= std_logic_vector(remainder); -- last value (invalid)
--        end if;
        end if;
    end process;

end divide_arch;
