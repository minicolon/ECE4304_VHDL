----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2021 09:16:44 AM
-- Design Name: 
-- Module Name: arith_unit - arith_arch
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Arithmetic unit that can add, subtract, multiply, and divide two digits
entity arith_unit is
  generic (g_WIDTH_AU: integer := 4);  -- Generic data width parameter
  port (
    i_arith_clk  : in  std_logic;  -- input clock for AU
    i_arith_inst : in  std_logic_vector(1 downto 0); -- Input instructions to decide what arithmetic to output
    i_arith_a    : in  std_logic_vector(g_WIDTH_AU - 1 downto 0); -- Input port A
    i_arith_b    : in  std_logic_vector(g_WIDTH_AU - 1 downto 0); -- Input port B
    o_arith_data : out std_logic_vector((2*g_WIDTH_AU) - 1 downto 0) -- Output the data based on the inst
    );
end arith_unit;

architecture arith_arch of arith_unit is

component generic_mux_Nx1 is
  generic(g_WIDTH_MUX_DATA: integer := 16; g_MUX_INPUTS: integer := 4);                     -- Parameter for data width size, and amount of inputs desired
  port(
    i_mux_sel : in  std_logic_vector(integer(ceil(log2(real(g_MUX_INPUTS)))) - 1 downto 0); -- Input select for multiplexer
    i_mux_data: in  std_logic_vector((g_WIDTH_MUX_DATA*g_MUX_INPUTS) - 1 downto 0);         -- Input data as single vector for multiplexer
    o_mux_data: out std_logic_vector(g_WIDTH_MUX_DATA - 1 downto 0)                         -- output selected data for multiplexer
    );
end component;
  
component add_sub is
  generic (g_WIDTH_AS: integer := 4);
  port (
    i_add_sub_sel   : in  std_logic;                                 -- Enable determines whether to add or subtract
    i_add_sub_a     : in  std_logic_vector(g_WIDTH_AS - 1 downto 0); -- Input A port value
    i_add_sub_b     : in  std_logic_vector(g_WIDTH_AS - 1 downto 0); -- Input B port value
    o_add_sub_sum   : out std_logic_vector(g_WIDTH_AS - 1 downto 0); -- Output sum value
    o_add_sub_carry : out std_logic                                  -- Output the carry value
    );
end component;

component multiply is
  generic (g_WIDTH_MULT: integer := 4);                               -- Parameter to set input bit size
  port (
    i_mult_clk  : in  std_logic;                                      -- Input clock for multipler unit
    i_mult_a    : in  std_logic_vector(g_WIDTH_MULT - 1 downto 0);    -- Input value A
    i_mult_b    : in  std_logic_vector(g_WIDTH_MULT - 1 downto 0);    -- Input value B
    o_mult_prod : out std_logic_vector((g_WIDTH_MULT*2) - 1 downto 0) -- Output product value
    );
end component;

component divide is
  generic (g_WIDTH_DIV : integer := 4);                              -- Generic data width parameter
  port (
    i_div_clk : in  std_logic;                                       -- Input clock
    i_div_a   : in  std_logic_vector(g_WIDTH_DIV - 1 downto 0);      -- Input port A
    i_div_b   : in  std_logic_vector(g_WIDTH_DIV - 1 downto 0);      -- input port B
    o_div_remain:   out std_logic_vector(g_WIDTH_DIV - 1 downto 0);
    o_div_qt  : out std_logic_vector((g_WIDTH_DIV) - 1 downto 0)   -- Output the quotient
    );
end component;

constant mux_inputs: integer := 4; -- Constant for the amount of inputs to the mux
constant zeros_add: std_logic_vector(g_WIDTH_AU - 2 downto 0) := (others => '0');
constant zeros_sub: std_logic_vector(g_WIDTH_AU - 1 downto 0) := (others => '0');

-- Temp signals to connect each arithmetic segment together
signal temp_mux_data      : std_logic_vector(mux_inputs*(g_WIDTH_AU*2) - 1 downto 0);
signal temp_add_sub_sum   : std_logic_vector(g_WIDTH_AU - 1 downto 0);
signal temp_add_sub_carry : std_logic;
signal temp_add_data      : std_logic_vector((g_WIDTH_AU*2) - 1 downto 0) := (others => '0');
signal temp_sub_data      : std_logic_vector((g_WIDTH_AU*2) - 1 downto 0) := (others => '0');
signal temp_mult_data     : std_logic_vector((g_WIDTH_AU*2) - 1 downto 0) := (others => '0');
signal temp_div_data      : std_logic_vector((g_WIDTH_AU*2) - 1 downto 0) := (others => '0');

begin
  -- Format the input data for the mux
  temp_mux_data <= temp_div_data & temp_mult_data & temp_sub_data & temp_add_data;
  INST_MUX_COMP: generic_mux_Nx1
    generic map(g_WIDTH_MUX_DATA => (g_WIDTH_AU*2), g_MUX_INPUTS => mux_inputs)
    port map(
      i_mux_sel => i_arith_inst,
      i_mux_data => temp_mux_data,
      o_mux_data => o_arith_data
      );
 
  ADD_SUB_COMP: add_sub
    generic map (g_WIDTH_AS => g_WIDTH_AU)
    port map(
      i_add_sub_sel   => i_arith_inst(0), -- If 0 then add, but if 1 then subtract
      i_add_sub_a     => i_arith_a,
      i_add_sub_b     => i_arith_b,
      o_add_sub_sum   => temp_add_sub_sum,
      o_add_sub_carry => temp_add_sub_carry
      );
      
  -- Format the output for both addition and subtraction
  temp_add_data <= zeros_add & temp_add_sub_carry & temp_add_sub_sum;
  temp_sub_data <= zeros_sub & temp_add_sub_sum;
  
  MULT_COMP: multiply
    generic map(g_WIDTH_MULT => g_WIDTH_AU)
    port map(
      i_mult_clk  => i_arith_clk,
      i_mult_a    => i_arith_a,
      i_mult_b    => i_arith_b,
      o_mult_prod => temp_mult_data
      );
  
 DIV_COMP: divide
    generic map(g_WIDTH_DIV => g_WIDTH_AU)
    port map(
      i_div_clk => i_arith_clk,
      i_div_a => i_arith_a,
      i_div_b => i_arith_b,
      o_div_remain => temp_div_data((g_WIDTH_AU*2)-1 downto g_WIDTH_AU),
      o_div_qt => temp_div_data(g_WIDTH_AU - 1 downto 0)
      );
end arith_arch;
