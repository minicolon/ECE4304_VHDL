----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2021 10:38:42 AM
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

entity top is
    Port(-- Port instantiation for board IO
        i_top_clk      : in  std_logic;                    -- System Clock
        i_top_rst_sseg : in  std_logic;                    -- Reset for ssegs
        i_top_rst_count: in  std_logic;                    -- Reset for the counter, 99999999 or 00000000
        i_top_SW_ud    : in  std_logic;                    -- determines whether counting up or down
        i_top_SW_speed : in  std_logic_vector(1 downto 0); -- determines which pll clock is passed to the counter
        o_top_sseg     : out std_logic_vector(6 downto 0); -- output sseg data
        o_top_anode    : out std_logic_vector(7 downto 0); -- output selected anode 
        o_top_dp       : out std_logic                     -- output for decimal point on ssegs
        );
end top;

architecture top_arch of top is

-- Component of clock selector
component select_clk is
    Port(  -- Port instantiation 
        i_sel_clk: in  std_logic;                    -- Input a clock for pll usage
        i_sel_rst: in  std_logic;                    -- Input a reset for selecting the clock
        i_sel_SW : in  std_logic_vector(1 downto 0); -- Input switches for selecting new output clock
        o_new_clk: out std_logic                     -- Output of new selected clock
        );
end component;

-- Component instantiation of logic for counting up/down and displaying
component display_sseg is
    Port(
        i_disp_clk : in  std_logic;                    -- Input clock for the internal bcd counters
        i_disp_rst : in  std_logic;                    -- Input reset for the internal counters
        i_disp_sel : in  std_logic_vector(2 downto 0); -- Input selector for the internal 8x1 mux
        i_disp_ud  : in  std_logic;                    -- Input up/down signal
        o_disp_sseg: out std_logic_vector(6 downto 0)  -- Output selected sseg data
        );
end component;

component generic_decoder is
    generic (g_WIDTH_DECODER: integer := 5);
    Port(
        i_Din_gen : in  std_logic_vector(g_WIDTH_DECODER - 1 downto 0);   -- Input the data based on the generic parameter
        o_Dout_gen: out std_logic_vector(2**g_WIDTH_DECODER - 1 downto 0) -- Output the new decoded data
        );
end component;

component generic_counter is
    generic(g_WIDTH_COUNTER: integer := 4);
    Port(
        i_clk  : in std_logic;                                      -- Input a clock for the counter
        i_rst  : in std_logic;                                      -- Input a reset of the counter
        o_count: out std_logic_vector(g_WIDTH_COUNTER - 1 downto 0) -- Output the current counter value
        );
end component;

-- Constants which determine counter size that slows down the clock
constant total_slow_an  : integer := 18;   
constant total_slow_sseg: integer := 20;

-- Temp signals to route components together
signal temp_count       : std_logic_vector(total_slow_an - 1 downto 0);
signal temp_sseg_counter: std_logic_vector(total_slow_sseg - 1 downto 0);
signal temp_anode       : std_logic_vector(7 downto 0);
signal temp_new_clk     : std_logic;

begin
    -- Takes in the default clock and outputs a count value used to slow down anode selection by 2**18 bits    
    COUNTER_SLOW_AN_DECODER: generic_counter
        generic map(g_WIDTH_COUNTER => total_slow_an)
        port map(
            i_clk   => i_top_clk,
            i_rst   => i_top_rst_sseg,
            o_count => temp_count
            );    
    
    -- Takes in the upper 3 bits of the output decoder counter and uses that as the decoding logic                     
    DECODER_COMP: generic_decoder
        generic map(g_WIDTH_DECODER => 3)
        port map(
            i_Din_gen  => temp_count(total_slow_an - 1 downto total_slow_an - 3),
            o_Dout_gen => temp_anode
            );
    
    -- Determines counting speed, the faster the speed, the less ssegs that can be seen counting
    SEL_CLK_COMP: select_clk
        port map(
            i_sel_clk => i_top_clk,
            i_sel_rst => i_top_rst_count,
            i_sel_SW => i_top_SW_speed,
            o_new_clk => temp_new_clk
            );
    
    -- Slow down the new clock value by 2**20, which roughly converts the input MHz to a slower Hz speed
    -- Not needed if displaying lower 6 ssegs as counting does not matter        
    COUNTER_SLOW_SSEG: generic_counter
        generic map(g_WIDTH_COUNTER => total_slow_sseg)
        port map(-- Takes in the default clock and outputs a count value
            i_clk   => temp_new_clk,
            i_rst   => i_top_rst_sseg,
            o_count => temp_sseg_counter
            );
    
    -- Take in decoder count value and uise it to select the sseg data that displays            
    DISP_COMP: display_sseg
        port map(
            i_disp_clk => temp_sseg_counter(total_slow_sseg - 1),
            i_disp_rst => i_top_rst_count,
            i_disp_sel => temp_count(total_slow_an - 1 downto total_slow_an - 3),
            i_disp_ud => i_top_SW_ud,
            o_disp_sseg => o_top_sseg
            );
        
    o_top_dp    <= '1'; -- Turn of all decimal points
    o_top_anode <= not temp_anode; -- invert decoder output to align with common anode
end top_arch;
