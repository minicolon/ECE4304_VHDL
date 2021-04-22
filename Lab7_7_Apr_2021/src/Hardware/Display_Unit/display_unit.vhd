----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/31/2021 11:12:11 AM
-- Design Name: 
-- Module Name: display_unit - disp_arch
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

-- Entity that displays the AU, fifo A, and fifo B data
entity display_unit is
  port (
    i_disp_clk  : in  std_logic;                      -- Input clock signal
    i_disp_rst  : in  std_logic;                      -- Input reset signal
    i_disp_bs_a : in  std_logic_vector(7 downto 0);   -- Input Barrel Shifted A value for 2 ssegs
    i_disp_bs_b : in  std_logic_vector(7 downto 0);   -- Input Barrel Shifted B value for 2 ssegs
    i_disp_au   : in  std_logic_vector(15 downto 0);  -- Input AU value to display over 4 ssegs
    o_disp_sseg : out std_logic_vector(6 downto 0);   -- Output selected sseg 
    o_disp_an   : out std_logic_vector(7 downto 0);   -- Output current selected anode
    o_disp_dp   : out std_logic                       -- Output the decimal point signal, set to off = '1'
    );
end display_unit;

architecture disp_arch of display_unit is

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

signal temp_mux_in    : std_logic_vector(55 downto 0);             -- Size of total bits for 8 ssegs
signal temp_count     : std_logic_vector(slow_bits - 1 downto 0);  -- Holds the count value
signal temp_sseg_bs_a : std_logic_vector(13 downto 0);             -- Sseg signal for the a-shifted value
signal temp_sseg_bs_b : std_logic_vector(13 downto 0);             -- Sseg signal for the b-shifted value
signal temp_sseg_au   : std_logic_vector(27 downto 0);             -- Sseg signal for the arithmetic unit value
signal temp_anode     : std_logic_vector(7 downto 0);              -- Holds decoder output before inverting

begin
  o_disp_dp <= '1'; -- Turn off all decimal points
  
  -- Sseg for the 8 bit barrel shifter
  GEN_BS_A_SSEG: for i in 0 to 1 generate
    FIFO_A_SSEG: hex_to_sseg
    port map (
      i_hex  => i_disp_bs_a((4*(i+1)) - 1 downto 4*i),
      i_en   => '1',
      o_sseg => temp_sseg_bs_a((7*(i+1)) - 1 downto 7*i)
      );
  end generate;
  
  -- Sseg for the 8 bit barrel shifter
  GEN_BS_B_SSEG: for i in 0 to 1 generate
    FIFO_B_SSEG: hex_to_sseg
    port map (
      i_hex  => i_disp_bs_b((4*(i+1)) - 1 downto 4*i),
      i_en   => '1',
      o_sseg => temp_sseg_bs_b((7*(i+1)) - 1 downto 7*i)
      );
  end generate;
  
  -- Sseg for all 16 bits of the AU
  GEN_AU_SSEG: for i in 0 to 3 generate
    ARITH_UNIT_SSEG: hex_to_sseg
    port map (
      i_hex  => i_disp_au((4*(i+1)) - 1 downto 4*i),
      i_en   => '1',
      o_sseg => temp_sseg_au((7*(i+1)) - 1 downto 7*i)
      );
  end generate;

  -- Counter to slow down clock to allow sseg data to display properly
  COUNTER_COMP: generic_counter    
    generic map (g_WIDTH_COUNTER => slow_bits)
    port map(
      i_count_clk => i_disp_clk,
      i_count_rst => i_disp_rst,
      o_count     => temp_count
      );
  
  -- Format all ssegs for the mux
  temp_mux_in <= temp_sseg_au(27 downto 0) & temp_sseg_bs_a(13 downto 0) & temp_sseg_bs_b(13 downto 0);
  
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
  o_disp_an <= not temp_anode;    
end disp_arch;
