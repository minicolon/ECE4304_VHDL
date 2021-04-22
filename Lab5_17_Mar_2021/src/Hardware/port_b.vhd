----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2021 11:44:46 AM
-- Design Name: 
-- Module Name: port_b - Behavioral
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

-- B port that takes in data and outputs both valid BCD data and sseg equivalent
entity port_b is
  generic (g_WIDTH_B: integer := 4); -- Generic parameter to specify data size
  port (
    i_port_b_clk  : in  std_logic;  -- Input port clock for register
    i_port_b_sel  : in  std_logic;  -- Input select for sseg data format output
    i_port_b_data : in  std_logic_vector(g_WIDTH_B - 1 downto 0);  -- Input data
    o_port_b_data : out std_logic_vector(g_WIDTH_B - 1 downto 0);  -- Output data
    o_port_b_sseg : out std_logic_vector(6 downto 0)               -- Output sseg representation
    );
end port_b;

architecture port_b_arch of port_b is

component Bin_To_BCD is
  port(
    i_Binary : in  std_logic_vector(3 downto 0);  -- Input binary data
    o_BCD    : out std_logic_vector(3 downto 0)   -- Output of valid BCD
    );
end component;

component hex_to_sseg is
  port(
    i_hex  : in  std_logic_vector(3 downto 0);  -- Input hex value
    i_en   : in  std_logic;                     -- Input enable
    o_sseg : out std_logic_vector(6 downto 0)   -- Output sseg hex equivalent
    );
end component;

component data_register is
  generic (g_WIDTH_REG: integer := 4);  -- Generic parameter for data width
  port (
    i_reg_clk  : in  std_logic;         -- Input clock for the reg
    i_reg_data : in  std_logic_vector(g_WIDTH_REG - 1 downto 0);  -- Input data for the reg
    o_reg_data : out std_logic_vector(g_WIDTH_REG - 1 downto 0)   -- Output data of the reg
    );
end component;

component generic_mux_2x1 is
    generic(g_WIDTH_DATA: integer := 16);   -- Generic Parameter for data width
    port(
        i_mux_sel    : in  std_logic;       -- Input single select bit
        i_mux_data_0 : in  std_logic_vector(g_WIDTH_DATA - 1 downto 0);  -- Input first data set
        i_mux_data_1 : in  std_logic_vector(g_WIDTH_DATA - 1 downto 0);  -- Input second data set
        o_mux_data   : out std_logic_vector(g_WIDTH_DATA - 1 downto 0)   -- Output selected data
        );
end component;

-- Temp signals for proper data flow
signal temp_BCD  : std_logic_vector(3 downto 0);
signal temp_data : std_logic_vector(g_WIDTH_B - 1 downto 0);

begin
  BCD_COMP: Bin_To_BCD
    port map(
      i_Binary => i_port_b_data,
      o_BCD    => temp_BCD
      );

  MUX_COMP: generic_mux_2x1
    generic map(g_WIDTH_DATA => g_WIDTH_B)
    port map(
      i_mux_sel    => i_port_b_sel,
      i_mux_data_0 => temp_BCD,
      i_mux_data_1 => i_port_b_data,
      o_mux_data   => temp_data
      );
  
  HEX_SSEG_COMP: hex_to_sseg
    port map(
      i_hex  => temp_data,
      i_en   => '1',
      o_sseg => o_port_b_sseg
      );
  
  REG_COMP: data_register
    generic map (g_WIDTH_REG => g_WIDTH_B)
    port map (
      i_reg_clk  => i_port_b_clk,
      i_reg_data => temp_BCD,
      o_reg_data => o_port_b_data
      );
  
end port_b_arch;
