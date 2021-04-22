----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2021 02:41:19 PM
-- Design Name: 
-- Module Name: left_shifter - ls_arch
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

entity left_shifter is
  generic (g_WIDTH_LEFT:integer := 8);                                                          -- Right shifter generic parameter
  port (
    i_left_value : in  std_logic_vector(g_WIDTH_LEFT - 1 downto 0);                             -- Input value for shifting
    i_left_shift : in  std_logic_vector(integer(ceil(log2(real(g_WIDTH_LEFT)))) - 1 downto 0);  -- Input shifting amount
    o_left_new   : out std_logic_vector(g_WIDTH_LEFT - 1 downto 0)                              -- Output new shifted value
    );
end left_shifter;

architecture ls_arch of left_shifter is

-- Constant for amount of shift bits
constant shift_bits: integer := integer(ceil(log2(real(g_WIDTH_LEFT))));
  
-- 2D array for shifting stages
type shift_type is array (shift_bits downto 0) of std_logic_vector(g_WIDTH_LEFT - 1 downto 0);
signal temp_left_value: shift_type;

-- Temp signal instantiation
signal temp_shift: std_logic_vector(shift_bits - 1 downto 0) := (others => '0');

begin
  temp_left_value(0) <= i_left_value;                 -- Set the first stage to the input value
  temp_shift         <= i_left_shift;                 -- Assign the shift amount
  o_left_new         <= temp_left_value(shift_bits);  -- Output the final shifted stage
  
  -- Generate the stages for the desired word width
  GEN_STAGES_LEFT: for i in 0 to shift_bits - 1 generate
    -- Process for each stage of muxes
    p_LEFT_SHIFT: process(temp_shift, temp_left_value)
      begin
        if(temp_shift(i) = '0') then -- When the current shift bit is 0 pass the previous value
          temp_left_value(i + 1) <= temp_left_value(i);
        else -- If the the current shift bit is 1 shift to the left by 2**shift_bit amount
          temp_left_value(i + 1) <= temp_left_value(i)((g_WIDTH_LEFT - 2**i - 1) downto 0) & temp_left_value(i)(g_WIDTH_LEFT - 1 downto (g_WIDTH_LEFT - 2**i));
        end if;
    end process;
  end generate;
end ls_arch;
