----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2021 05:43:29 AM
-- Design Name: 
-- Module Name: sel_sseg - Behavioral
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

-- Entity that holds the logic for the slow clock generator and the decoder for the anodes
entity sel_sseg is
    generic(g_SLOW_BITS: integer := 18); -- generic parameter to decide how many bits to slow down the clock by
    Port(-- Port instantiation
        i_clk: in  std_logic;
        i_rst: in  std_logic;
        o_An : out std_logic_vector(7 downto 0)
        );
end sel_sseg;

architecture Behavioral of sel_sseg is

component generic_decoder is
    generic (g_WIDTH: integer := 5);
    Port(-- Port instantiation
        i_Din_gen : in  std_logic_vector(g_WIDTH - 1 downto 0);
        o_Dout_gen: out std_logic_vector(2**g_WIDTH - 1 downto 0)
        );
end component;

component generic_counter is
    generic(g_WIDTH: integer := 4);
    Port(-- Port instantiation
        i_clk  : in  std_logic;
        i_rst  : in  std_logic;
        o_count: out std_logic_vector(g_WIDTH - 1 downto 0)
        );
end component;

-- Constants that determine how many anodes to decode
constant total_Anode_Bits: integer := 3;

-- Temp signals to route components together
signal temp_count        : std_logic_vector(g_SLOW_BITS - 1 downto 0);
signal temp_anode        : std_logic_vector(2**total_Anode_Bits - 1 downto 0);

begin
    COUNTER_SLOW_CLK: generic_counter
        generic map(g_WIDTH => g_SLOW_BITS)
        port map(-- Takes in the default clock and outputs a count value
            i_clk   => i_clk,
            i_rst   => i_rst,
            o_count => temp_count
            );    
            
    DECODER_COMP: generic_decoder
        generic map(g_WIDTH => total_Anode_Bits)
        port map(-- Takes in the upper 3 bits of the output counter and uses that as the decoding logic
            i_Din_gen  => temp_count(g_SLOW_BITS - 1 downto g_SLOW_BITS - total_Anode_Bits),
            o_Dout_gen => o_An
            );
end Behavioral;
