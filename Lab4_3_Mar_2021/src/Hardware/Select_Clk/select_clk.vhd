----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/02/2021 07:45:54 AM
-- Design Name: 
-- Module Name: select_clk - sel_arch
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

entity select_clk is
    Port( -- Port instantiation
        i_sel_clk: in  std_logic;                    -- Input a clock for pll usage
        i_sel_rst: in  std_logic;                    -- Input a reset for selecting the clock
        i_sel_SW : in  std_logic_vector(1 downto 0); -- Input switches for selecting new output clock
        o_new_clk: out std_logic                     -- Output of new selected clock
        );
end select_clk;

architecture sel_arch of select_clk is

component clk_wiz_0 
    Port( -- Instantiation of the clock wizard from IP catalog
        i_clk_sys: in  std_logic; -- Input a common clock
        reset    : in  std_logic; -- Input a reset signal
        o_pll_10 : out std_logic; -- Output 10MHz clock
        o_pll_50 : out std_logic; -- Output 50MHz clock
        o_pll_100: out std_logic; -- Output 100MHz clock
        o_pll_200: out std_logic; -- Output 200MHz clock
        locked   : out std_logic  -- Locked signal output
        );
end component;

component generic_mux_Nx1 is
    generic(g_WIDTH_MUX_DATA: integer := 16; g_MUX_INPUTS: integer := 4);
    Port(
        i_mux_sel : in  std_logic_vector(integer(ceil(log2(real(g_MUX_INPUTS)))) - 1 downto 0); -- Input select for multiplexer
        i_mux_data: in  std_logic_vector((g_WIDTH_MUX_DATA*g_MUX_INPUTS) - 1 downto 0);         -- Input data as single vector for multiplexer
        o_mux_data: out std_logic_vector(g_WIDTH_MUX_DATA - 1 downto 0)                         -- output selected data for multiplexer
        );
end component ;

signal temp_clk_in     : std_logic_vector(3 downto 0); -- Temp signal to send as multiplexer input data
signal temp_current_clk: std_logic_vector(0 downto 0); -- Temp variable to hold new selected clock output

-- Temp signals that hold the respective pll output clock value
signal temp_pll_clk_10 : std_logic;
signal temp_pll_clk_50 : std_logic;
signal temp_pll_clk_100: std_logic;
signal temp_pll_clk_200: std_logic;

-- Temp signals that hold the stable respective pll output clock
signal stable_clk_10   : std_logic;
signal stable_clk_50   : std_logic;
signal stable_clk_100  : std_logic;
signal stable_clk_200  : std_logic;

-- Locked pll output temp signal
signal temp_pll_lock   : std_logic;

begin
    PLL_CLK_COMP: clk_wiz_0 
    port map(
        i_clk_sys  => i_sel_clk,        -- Map the top clock with the input for the pll
        reset      => i_sel_rst,        -- Map the top reset with the input for the pll
        o_pll_10   => temp_pll_clk_10,  -- Output the 10MHz clock
        o_pll_50   => temp_pll_clk_50,  -- Output the 50MHz clock
        o_pll_100  => temp_pll_clk_100, -- Output the 100MHz clock
        o_pll_200  => temp_pll_clk_200, -- Output the 200MHz clock
        locked     => temp_pll_lock     -- Output the current locked value
        );
        
    --  utilizes lock from pll clock to make sure only stable clocks are being used
    stable_clk_10  <= temp_pll_clk_10 and temp_pll_lock;
    stable_clk_50  <= temp_pll_clk_50 and temp_pll_lock;
    stable_clk_100 <= temp_pll_clk_100 and temp_pll_lock;
    stable_clk_200 <= temp_pll_clk_200 and temp_pll_lock;
    
    -- Concatenate all stable clocks so it can be formatted for the multiplexer
    temp_clk_in    <= stable_clk_10 & stable_clk_50 & stable_clk_100 & stable_clk_200;

    -- Creates a 4x1 multiplexer with each data set size of 1 bit
    MUX_4x1: generic_mux_Nx1
        generic map(g_WIDTH_MUX_DATA => 1, g_MUX_INPUTS => 4)
        port map(
            i_mux_sel  => i_sel_SW,        -- Map the top select switches for the multiplexer
            i_mux_data => temp_clk_in,     -- Input the newly formatted clock data
            o_mux_data => temp_current_clk -- output the selected clock
            );
    
    -- Assign the new clock to the output
    o_new_clk <= temp_current_clk(0);
end sel_arch;
