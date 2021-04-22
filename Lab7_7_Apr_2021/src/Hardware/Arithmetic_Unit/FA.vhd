----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/03/2021 06:17:47 PM
-- Design Name: 
-- Module Name: FA - SFA
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Single bit full adder/subtractor
entity FA is
  port (
    i_a    : in  std_logic; -- Input A
    i_b    : in  std_logic; -- Input B
    i_carry: in  std_logic; -- Input carry bit
    i_sel  : in  std_logic; -- Input select whether to add/subtract 
    o_sum  : out std_logic; -- Output the sum value
    o_carry: out std_logic  -- Output the carry bit
  );
end FA;

architecture SFA of FA is

-- Temp variable hold the original or 2's compliment of b
signal temp_b: std_logic;

begin
  temp_b <= i_b xor i_sel; -- Decide whether to add or subtract

  o_sum <= i_a xor temp_b xor i_carry; -- Output the sum bit between all inputs

  o_carry <= (i_a and temp_b) or (i_a and i_carry) or (temp_b and i_carry); -- Decide if there is an output carry or not based on the inputs

end SFA;
