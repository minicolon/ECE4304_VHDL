----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2021 02:45:02 PM
-- Design Name: 
-- Module Name: generic_mux_Nx1 - mux_Nx1_arch
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

-- Generic Nx1 mux with a variable data size for each input
entity generic_mux_Nx1 is
  generic(g_WIDTH_MUX_DATA: integer := 16; g_MUX_INPUTS: integer := 4);                       -- Parameter for data width size, and amount of inputs desired
  port(
    i_mux_sel  : in  std_logic_vector(integer(ceil(log2(real(g_MUX_INPUTS)))) - 1 downto 0);  -- Input select for multiplexer
    i_mux_data : in  std_logic_vector((g_WIDTH_MUX_DATA*g_MUX_INPUTS) - 1 downto 0);  -- Input data as single vector for multiplexer
    o_mux_data : out std_logic_vector(g_WIDTH_MUX_DATA - 1 downto 0)  -- output selected data for multiplexer
    );
end generic_mux_Nx1;

architecture mux_Nx1_arch of generic_mux_Nx1 is

-- Component instatiation of smaller base 2x1 mux 
component generic_mux_2x1 is
  generic(g_WIDTH_DATA: integer := 16);                              -- Generic data width parameter
  port(
    i_mux_sel    : in  std_logic;                                    -- Input single select bit
    i_mux_data_0 : in  std_logic_vector(g_WIDTH_DATA - 1 downto 0);  -- Input first data set
    i_mux_data_1 : in  std_logic_vector(g_WIDTH_DATA - 1 downto 0);  -- Input second data set
    o_mux_data   : out std_logic_vector(g_WIDTH_DATA - 1 downto 0)   -- Output selected data
    );
end component;

-- A constant value to determine the amount of select bits
constant sel_bits: integer := integer(ceil(log2(real(g_MUX_INPUTS))));

-- Create an array of arrays (2D array) for the ssegs
type mux_type is array (0 to g_MUX_INPUTS) of std_logic_vector(g_WIDTH_MUX_DATA - 1 downto 0);
signal temp_data_in : mux_type;
signal temp_data_out: mux_type;

begin
  -- Break the single input data vector to a data set for each input 
  GEN_INPUTS: for k in 0 to g_MUX_INPUTS - 1 generate
    temp_data_in(k) <= i_mux_data((g_WIDTH_MUX_DATA*(k+1)) - 1 downto  g_WIDTH_MUX_DATA*k);
  end generate;
  
  GEN_LEVELS: for i in 0 to sel_bits - 1 generate -- Upper for loop to generate levels for select bits
    GENERATE_MUXES: for j in g_MUX_INPUTS - 2**(sel_bits - i) to g_MUX_INPUTS - 2**(sel_bits - i - 1) - 1 generate -- Generate the amount of muxes per level
      
      FIRST_LEVEL: if i = 0 generate -- First loop condition
        MUX_2x1_COMP: generic_mux_2x1
          generic map(g_WIDTH_DATA => g_WIDTH_MUX_DATA)
          port map(
            i_mux_sel    => i_mux_sel(i),
            i_mux_data_0 => temp_data_in(2*j),
            i_mux_data_1 => temp_data_in(2*j + 1),
            o_mux_data   => temp_data_out(j)
            );
      end generate;
      
      GEN_REMAINING_LEVELS: if i /= 0 generate -- Generate the remaining muxes
        MUX_2x1_COMP: generic_mux_2x1
          generic map(g_WIDTH_DATA => g_WIDTH_MUX_DATA)
          port map(
            i_mux_sel    => i_mux_sel(i),
            i_mux_data_0 => temp_data_out(2*j - g_MUX_INPUTS),
            i_mux_data_1 => temp_data_out(2*j - g_MUX_INPUTS + 1),
            o_mux_data   => temp_data_out(j)
            );
      end generate;
    end generate;
  end generate;
  
  -- assign final mux data to the output port
  o_mux_data <= temp_data_out(g_MUX_INPUTS - 2);
end mux_Nx1_arch;
