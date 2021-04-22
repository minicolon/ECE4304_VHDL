----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2021 03:26:29 PM
-- Design Name: 
-- Module Name: top - Behavioral
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

-- Top entity that combines all logic together
entity top is
     generic(g_SLOW_BITS_TOP: integer := 18);
    Port(-- Port instantiation
        i_clk_top : in  std_logic;
        i_rst_top : in  std_logic;
        i_SW_top  : in  std_logic_vector(7 downto 0);
        o_Sseg_top: out std_logic_vector(6 downto 0);
        o_An_top  : out std_logic_vector(7 downto 0);
        o_DP_top  : out std_logic
        );
end top;

architecture Behavioral of top is

-- Add in binary to sseg converter component
component Bin_To_Sseg is
    Port(
        i_En_Sseg  : in  std_logic;
        i_Binary_SW: in  std_logic_vector(3 downto 0);
        o_Sseg_Disp: out std_logic_vector(6 downto 0)
        );
end component;

-- Add in sseg selector component
component sel_sseg is
    generic(g_SLOW_BITS: integer := 18);
    Port(
        i_clk: in  std_logic;
        i_rst: in  std_logic;
        o_An : out std_logic_vector(7 downto 0)
        );
end component;

-- Add in a 2x1 mux component
component generic_mux_2x1 is
    generic(g_WIDTH: integer := 16);
    Port( -- Port instantiation
        i_Sel : in  std_logic;
        i_D0  : in  std_logic_vector(g_WIDTH - 1 downto 0);
        i_D1  : in  std_logic_vector(g_WIDTH - 1 downto 0);
        o_Dout: out std_logic_vector(g_WIDTH - 1 downto 0)
        );
end component;

-- Temp intermediate variables between components
constant total_Anode_Bits: integer := 3;
signal   temp_Anode     : std_logic_vector(2**total_Anode_Bits - 1 downto 0);
signal   temp_Sseg0     : std_logic_vector(6 downto 0);
signal   temp_Sseg4     : std_logic_vector(6 downto 0);

begin
    SEL_COMP: sel_sseg
        generic map(g_SLOW_BITS => g_SLOW_BITS_TOP)
        port map(
            i_clk => i_clk_top,
            i_rst => i_rst_top,
            o_An  => temp_Anode
            );        

    SSEG_COMP_0:Bin_To_Sseg -- Instantiate first sseg
        port map(
            i_En_Sseg   => temp_Anode(0),
            i_Binary_SW => i_SW_top(3 downto 0),
            o_Sseg_Disp => temp_Sseg0
            );
        
    SSEG_COMP_1:Bin_To_Sseg -- Instantiate second sseg
        port map(
            i_En_Sseg   => temp_Anode(4),
            i_Binary_SW => i_SW_top(7 downto 4),
            o_Sseg_Disp => temp_Sseg4
            );   

    MUX_COMP: generic_mux_2x1
        generic map(g_WIDTH => 7)
        port map(
            i_Sel  => temp_Anode(4),
            i_D0   => temp_Sseg0,
            i_D1   => temp_Sseg4,
            o_Dout => o_Sseg_top
            );
    
    -- Concatenate '1' with with the anodes I want to use. Then drive all decimal points high (off)        
    o_An_top   <= "111" & not temp_Anode(4) & "111" & not temp_Anode(0);
    o_DP_top   <= '1';
end Behavioral;
