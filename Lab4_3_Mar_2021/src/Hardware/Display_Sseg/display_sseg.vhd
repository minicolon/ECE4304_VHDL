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
    Port(
        i_disp_clk : in  std_logic;                    -- Input clock for the internal bcd counters
        i_disp_rst : in  std_logic;                    -- Input reset for the internal counters
        i_disp_sel : in  std_logic_vector(2 downto 0); -- Input selector for the internal 8x1 mux
        i_disp_ud  : in  std_logic;                    -- Input up/down signal
        o_disp_sseg: out std_logic_vector(6 downto 0)  -- Output selected sseg data
        );
end display_sseg;

architecture display_arch of display_sseg is

component generic_mux_Nx1 is
    generic(g_WIDTH_MUX_DATA: integer := 16; g_MUX_INPUTS: integer := 4);                       -- Parameter for data width size, and amount of inputs desired
    Port(
        i_mux_sel : in  std_logic_vector(integer(ceil(log2(real(g_MUX_INPUTS)))) - 1 downto 0); -- Input select for multiplexer
        i_mux_data: in  std_logic_vector((g_WIDTH_MUX_DATA*g_MUX_INPUTS) - 1 downto 0);         -- Input data as single vector for multiplexer
        o_mux_data: out std_logic_vector(g_WIDTH_MUX_DATA - 1 downto 0)                         -- output selected data for multiplexer
        );
end component ;

component BCD_To_Sseg is
    Port(
        i_sseg_en  : in  std_logic;                    -- Input the enable bit for the ssegs
        i_sseg_bcd : in  std_logic_vector(3 downto 0); -- Input the bcd data
        o_sseg     : out std_logic_vector(6 downto 0)  -- Output the selected data sseg data
        );
end component;

component bcd_counter is
    Port(
        i_bcd_clk: in  std_logic;                    -- Input clock for the bcd counter
        i_bcd_rst: in  std_logic;                    -- Input reset for the bcd counter
        i_bcd_ud : in  std_logic;                    -- Input up/down signal for bcd counter
        o_bcd_val: out std_logic_vector(3 downto 0); -- Output current bcd count value
        o_bcd_en : out std_logic                     -- output an enable bit set when either at 0 or 9 based on counting direction
        );
end component;

signal temp_en     : std_logic_vector(8 downto 0); -- Each bcd_counter/sseg gets an enable value
signal temp_bcd_val: std_logic_vector(31 downto 0); -- 1D array to map bcd value for all 8 ssegs
signal temp_mux_in     : std_logic_vector(55 downto 0); -- Size of total bits for 8 ssegs

-- Create an array of arrays (2D array) for the ssegs
type sseg_type is array (0 to 7) of std_logic_vector(6 downto 0);
signal temp_sseg: sseg_type;


begin
    temp_en(0) <= i_disp_clk; -- tie the top clock to the first enable
    GEN_BCD_TO_SSEG: for i in 0 to 7 generate -- For loop that generates 8 counters, and 8 sseg outputs for each counter 
        BCD_COUNTER_COMP: bcd_counter
            port map(
                i_bcd_clk => temp_en(i),
                i_bcd_rst => i_disp_rst,
                i_bcd_ud  => i_disp_ud,
                o_bcd_val => temp_bcd_val((4*i)+3 downto 4*i),
                o_bcd_en  => temp_en(i+1)
                );
        TO_SSEG_COMP: BCD_To_Sseg
            port map(
                i_sseg_en  => '1',
                i_sseg_bcd => temp_bcd_val((4*i)+3 downto 4*i),
                o_sseg     => temp_sseg(i)
                );
    end generate;
    
    -- Format all the sseg outputs of each counter so it can be sent to the 8x1 multiplexer
    temp_mux_in <= temp_sseg(7) & temp_sseg(6) & temp_sseg(5) & temp_sseg(4) & temp_sseg(3) & temp_sseg(2) & temp_sseg(1) & temp_sseg(0);
    
    -- Create an 8x1 mux with each data set being 7 bits wide
    MUX_8x1: generic_mux_Nx1
        generic map(g_WIDTH_MUX_DATA => 7, g_MUX_INPUTS => 8)
        port map(
            i_mux_sel  => i_disp_sel,
            i_mux_data => temp_mux_in,
            o_mux_data => o_disp_sseg
            );    
end display_arch;
