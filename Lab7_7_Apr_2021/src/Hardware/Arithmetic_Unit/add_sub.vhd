----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2021 07:54:26 AM
-- Design Name: 
-- Module Name: add - add_arch
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Simple N-bit adder/subtractor circuit for the arithmetic unit
entity add_sub is
  generic (g_WIDTH_AS: integer := 4);
  port (
    i_add_sub_sel   : in  std_logic;                                 -- Select determines whether to add or subtract
    i_add_sub_a     : in  std_logic_vector(g_WIDTH_AS - 1 downto 0); -- Input A port value
    i_add_sub_b     : in  std_logic_vector(g_WIDTH_AS - 1 downto 0); -- Input B port value
    o_add_sub_sum   : out std_logic_vector(g_WIDTH_AS - 1 downto 0); -- Output sum value
    o_add_sub_carry : out std_logic                                  -- Output the carry value
    );
end add_sub;

architecture add_sub_arch of add_sub is

-- Instantiate single bit full adder
component FA is
  port (
    i_a     : in  std_logic; -- Input A
    i_b     : in  std_logic; -- Input B
    i_carry : in  std_logic; -- Input carry bit
    i_sel   : in  std_logic; -- Input select whether to add/subtract 
    o_sum   : out std_logic; -- Output the sum value
    o_carry : out std_logic  -- Output the carry bit
    );
end component;

-- Temp variable for carry logic
signal temp_carry: std_logic_vector(g_WIDTH_AS downto 0); 

begin
  temp_carry(0) <= i_add_sub_sel; -- Assign the input carry to the first temp bit
    
  -- Generates the desired amount of full adders based on the generic bit parameter
  GEN_WRAPPER: for i in 0 to g_WIDTH_AS-1 generate
    SINGFA: FA 
      port map(
        i_sel   => temp_carry(0), -- Carry bit also determines if adding or subtracting
        i_carry => temp_carry(i),
        i_a     => i_add_sub_a(i),
        i_b     => i_add_sub_b(i),
        o_sum   => o_add_sub_sum(i),
        o_carry => temp_carry(i+1)
        );
  end generate;
    
  -- Output the final carry based on the last temp_carry value
  o_add_sub_carry <= temp_carry(g_WIDTH_AS);
  
  
end add_sub_arch;
