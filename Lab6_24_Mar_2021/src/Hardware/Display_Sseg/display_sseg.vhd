----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/02/2021 07:02:26 AM
-- Design Name: 
-- Module Name: display_sseg - display_arch
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

entity display_sseg is
  port(
    i_disp_clk     : in  std_logic;                     -- Input clock
    i_disp_rst     : in  std_logic;                     -- Input reset
    i_disp_bs_val  : in  std_logic_vector(7 downto 0);  -- Input value before shifting
    i_disp_bs_new  : in  std_logic_vector(7 downto 0);  -- Input value after shifting
    i_disp_bs_shft : in  std_logic_vector(3 downto 0);  -- Input shifting amount
    o_disp_sseg    : out std_logic_vector(6 downto 0);  -- Output sseg value
    o_disp_an      : out std_logic_vector(7 downto 0)   -- Output selected anode
    );
end display_sseg;

architecture display_arch of display_sseg is

component generic_counter is
  generic(g_WIDTH_COUNTER: integer := 7);
  port(
    i_count_clk : in std_logic;                                       -- Input a clock for the counter
    i_count_rst : in std_logic;                                       -- Input a reset of the counter
    o_count     : out std_logic_vector(g_WIDTH_COUNTER - 1 downto 0)  -- Output the current counter value
    );
end component;

component generic_decoder is
  generic (g_WIDTH_DECODER: integer := 3);
  port(
    i_Din_gen  : in  std_logic_vector(g_WIDTH_DECODER - 1 downto 0);    -- Input the data based on the generic parameter
    o_Dout_gen : out std_logic_vector(2**g_WIDTH_DECODER - 1 downto 0)  -- Output the new decoded data
    );
end component;

component generic_mux_Nx1 is
  generic(g_WIDTH_MUX_DATA: integer := 16; g_MUX_INPUTS: integer := 4);                       -- Parameter for data width size, and amount of inputs desired
  port(
    i_mux_sel  : in  std_logic_vector(integer(ceil(log2(real(g_MUX_INPUTS)))) - 1 downto 0);  -- Input select for multiplexer
    i_mux_data : in  std_logic_vector((g_WIDTH_MUX_DATA*g_MUX_INPUTS) - 1 downto 0);          -- Input data as single vector for multiplexer
    o_mux_data : out std_logic_vector(g_WIDTH_MUX_DATA - 1 downto 0)                          -- Output selected data for multiplexer
    );
end component;

component hex_to_sseg is
  port(
    i_hex  : in  std_logic_vector(3 downto 0); -- Input hex value
    i_en   : in  std_logic;                    -- Input enable
    o_sseg : out std_logic_vector(6 downto 0)  -- Output sseg hex equivalent
    );
end component;

constant slow_bits: integer := 17;  -- Sets the speed to cycle through each sseg

signal temp_en        : std_logic_vector(8 downto 0);              -- Each bcd_counter/sseg gets an enable value
signal temp_shift_val : std_logic_vector(31 downto 0);             -- 1D array to map bcd value for all 8 ssegs
signal temp_mux_in    : std_logic_vector(55 downto 0);             -- Size of total bits for 8 ssegs
signal temp_count     : std_logic_vector(slow_bits - 1 downto 0);  -- Holds the count value
signal temp_sseg_value: std_logic_vector(13 downto 0);             -- Sseg signal for the input value
signal temp_sseg_new  : std_logic_vector(13 downto 0);             -- Sseg signal for the shifted value
signal temp_sseg_shft : std_logic_vector(6 downto 0);              -- Sseg signal for the shift amount value
signal temp_anode     : std_logic_vector(7 downto 0);              -- Holds decoder output before inverting

begin
  -- Counter to slow down clock to allow sseg data to display properly
  COUNTER_COMP: generic_counter    
    generic map (g_WIDTH_COUNTER => slow_bits)
    port map(
      i_count_clk => i_disp_clk,
      i_count_rst => i_disp_rst,
      o_count     => temp_count
      );
  
  -- Sseg conversion for shift amount value
  SHIFT_AMT_SSEG: hex_to_sseg
    port map (
      i_hex  => i_disp_bs_shft,
      i_en   => '1',
      o_sseg => temp_sseg_shft
      );

  -- Sseg conversion for lower half of the input value
  VALUE_LOW_SSEG: hex_to_sseg
    port map (
      i_hex  => i_disp_bs_val(3 downto 0),
      i_en   => '1',
      o_sseg => temp_sseg_value(6 downto 0)
      );
  
  -- Sseg conversion for upper half of the input value
  VALUE_HIGH_SSEG: hex_to_sseg
    port map (
      i_hex  => i_disp_bs_val(7 downto 4),
      i_en   => '1',
      o_sseg => temp_sseg_value(13 downto 7)
      );

  -- Sseg conversion for lower half of the shifted value
  BS_NEW_LOW_SSEG: hex_to_sseg
    port map (
      i_hex  => i_disp_bs_new(3 downto 0),
      i_en   => '1',
      o_sseg => temp_sseg_new(6 downto 0)
      );
      
  -- Sseg conversion for lower half of the shifted value
  BS_NEW_HIGH_SSEG: hex_to_sseg
    port map (
      i_hex  => i_disp_bs_new(7 downto 4),
      i_en   => '1',
      o_sseg => temp_sseg_new(13 downto 7)
      );
  
  -- Format all ssegs for the mux
  temp_mux_in <= temp_sseg_new(13 downto 7) & temp_sseg_new(6 downto 0) & "1111111" & "1111111" & temp_sseg_value(13 downto 7) & temp_sseg_value(6 downto 0) & "1111111" & temp_sseg_shft;
  
  -- Mux for sseg data passing
  MUX_8x1: generic_mux_Nx1
    generic map(g_WIDTH_MUX_DATA => 7, g_MUX_INPUTS => 8)
    port map(
      i_mux_sel  => temp_count(slow_bits - 1 downto slow_bits - 3),
      i_mux_data => temp_mux_in,
      o_mux_data => o_disp_sseg
      );  
  
  -- Decoder for the anodes
  DECODER_COMP: generic_decoder
    generic map(g_WIDTH_DECODER => 3)
    port map(
      i_Din_gen  => temp_count(slow_bits - 1 downto slow_bits - 3),
      o_Dout_gen => temp_anode
      );
  
  -- The output for the anodes
  o_disp_an <= (not temp_anode(7 downto 6)) & "11" & (not temp_anode(3 downto 2)) & '1' & (not temp_anode(0));  
end display_arch;
