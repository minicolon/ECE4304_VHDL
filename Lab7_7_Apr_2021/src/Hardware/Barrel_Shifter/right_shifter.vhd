----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/22/2021 04:40:11 PM
-- Design Name: 
-- Module Name: right_shifter - Behavioral
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
use IEEE.math_real."log2";
use IEEE.math_real."ceil";
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- Right shifter entity
entity right_shifter is
  generic (g_WIDTH_RIGHT:integer := 8);                                                           -- Right shifter generic parameter
  port (
    i_right_value : in  std_logic_vector(g_WIDTH_RIGHT - 1 downto 0);                             -- Input value for shifting
    i_right_shift : in  std_logic_vector(integer(ceil(log2(real(g_WIDTH_RIGHT)))) - 1 downto 0);  -- Input shifting amount
    o_right_new   : out std_logic_vector(g_WIDTH_RIGHT - 1 downto 0)                              -- Output new shifted value
    );
end right_shifter;

architecture rs_arch of right_shifter is

-- Constant for amount of shift bits
constant shift_bits: integer := integer(ceil(log2(real(g_WIDTH_RIGHT))));
  
-- 2D array for shifting stages
type shift_type is array (shift_bits downto 0) of std_logic_vector(g_WIDTH_RIGHT - 1 downto 0);
signal temp_shift_right: shift_type;

-- Temp signal instantiation
signal temp_shift: std_logic_vector(shift_bits - 1 downto 0) := (others => '0');

begin
  temp_shift_right(0) <= i_right_value;                 -- Set the first stage to the input value
  temp_shift          <= i_right_shift;                 -- Assign the shift amount
  o_right_new         <= temp_shift_right(shift_bits);  -- Output the final shifted stage
  
  -- Generate the stages for the desired word width
  GEN_STAGES_RIGHT: for i in 0 to shift_bits - 1 generate
    -- Process for each stage of muxes
    p_RIGHT_SHIFT: process(temp_shift, temp_shift_right)
      begin
        if(temp_shift(i) = '0') then -- When the current shift bit is 0 pass the previous value
          temp_shift_right(i + 1) <= temp_shift_right(i);
        else -- If the the current shift bit is 1 shift to the right by 2**shift_bit amount
          temp_shift_right(i + 1) <= temp_shift_right(i)(2**i - 1 downto 0) & temp_shift_right(i)(g_WIDTH_RIGHT - 1 downto 2**i);
        end if;
    end process;
  end generate;
end rs_arch;
