----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2021 01:04:44 PM
-- Design Name: 
-- Module Name: top - top_arch
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

-- Top file to connect sub components
entity top is
    generic(g_WIDTH_top: integer := 5);
    Port( -- Top port instantiation
        i_Sel_top : in  std_logic;
        i_Din_top : in  std_logic_vector(g_WIDTH_top - 1 downto 0);
        o_Dout_top: out std_logic_vector(2**(g_WIDTH_top - 1) - 1 downto 0)
        );
end top;

architecture top_arch of top is
  
component generic_decoder is -- Generic Nx2**N decoder
    generic (g_WIDTH: integer := 5);
    Port( -- Port instantiation
        i_Din_gen : in  std_logic_vector(g_WIDTH - 1 downto 0);
        o_Dout_gen: out std_logic_vector(2**g_WIDTH - 1 downto 0)
        );
end component;

component generic_mux_2x1 is -- Generic 2x1 mux with each data port being 2**(N-1) bits
    generic(g_WIDTH: integer := 16);
    Port( -- Port instantiation
        i_Sel : in  std_logic;
        i_D0  : in  std_logic_vector(g_WIDTH - 1 downto 0);
        i_D1  : in  std_logic_vector(g_WIDTH - 1 downto 0);
        o_Dout: out std_logic_vector(g_WIDTH - 1 downto 0)
        );
end component;

-- Intermediate signals and constants to map components together
constant mux_bits       : integer := 2**(g_WIDTH_top - 1);
signal temp_Dout_Decoder: std_logic_vector((2**g_WIDTH_top) - 1 downto 0);
signal temp_D0_Mux      : std_logic_vector(mux_bits - 1 downto 0);
signal temp_D1_Mux      : std_logic_vector(mux_bits - 1 downto 0);
signal temp_Dout_Mux    : std_logic_vector(mux_bits - 1 downto 0);

begin
    -- Assign D0 to lower half of decoder data and D1 to upper half of decoder data
    temp_D1_Mux <= temp_Dout_Decoder((2**g_WIDTH_top) - 1 downto mux_bits);
    temp_D0_Mux <= temp_Dout_Decoder(mux_bits - 1 downto 0);
    
    MUX_COMP: generic_mux_2x1
    generic map (g_WIDTH => mux_bits)
    port map( -- Map ports to component
        i_Sel  => i_Sel_top,
        i_D0   => temp_D0_Mux,
        i_D1   => temp_D1_Mux,
        o_Dout => temp_Dout_Mux
        );
    
    DECODER_COMP: generic_decoder 
        generic map(g_WIDTH => g_WIDTH_top)
        port map( -- Map ports to component
        i_Din_gen  => i_Din_top,
        o_Dout_gen => temp_Dout_Decoder
        );
    
    -- Assign output value of mux to output port
    o_Dout_top <= temp_Dout_Mux;
end top_arch;
