----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2021 06:34:58 PM
-- Design Name: 
-- Module Name: division_tb - Behavioral
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

entity divider_tb is
    generic(g_WIDTH_TB: integer:=4);
end entity;

architecture Behavioral of divider_tb is

component divide
    generic(g_WIDTH_DIV: integer:=4);
    port(
        i_div_clk  : in  std_logic;
        i_div_a:     in std_logic_vector(g_WIDTH_DIV - 1 downto 0);
        i_div_b:     in std_logic_vector(g_WIDTH_DIV - 1 downto 0);
        errorsig:     out std_logic := '0';
        o_div_remain:   out std_logic_vector(g_WIDTH_DIV - 1 downto 0);
        o_div_qt:  out std_logic_vector(g_WIDTH_DIV - 1 downto 0)
        );
end component;

constant time_step: time := 10 ns;

signal i_div_clk_tb : std_logic;
signal i_div_a_tb:    std_logic_vector (g_WIDTH_TB - 1 downto 0);
signal i_div_b_tb:    std_logic_vector (g_WIDTH_TB - 1 downto 0);
signal errorsig_tb:    std_logic;
signal o_Div_remain_tb:  std_logic_vector (g_WIDTH_TB - 1 downto 0);  -- remainder
signal o_Div_qt_tb: std_logic_vector (g_WIDTH_TB - 1 downto 0);  -- quotient

begin
    div_COMP: divide
        port map (
            i_div_clk => i_div_clk_tb,
            i_div_a => i_div_a_tb,
            i_div_b => i_div_b_tb,
            errorsig => errorsig_tb,
            o_div_remain => o_div_remain_tb,
            o_div_qt => o_div_qt_tb
        );
        
  p_GEN_CLK: process
  begin
    i_div_clk_tb <= '1';
    wait for time_step/2;
    i_div_clk_tb <= '0';
    wait for time_step/2;    
  end process;
    
TST_CASE1:
    process
    begin
        i_div_a_tb <= "1000";  -- 8
        i_div_b_tb <= "0010";  -- 2
        wait for 20 ns;
        i_div_b_tb <= "0100";  -- 4
        wait for 20 ns;    
        i_div_b_tb <= "1000";  -- 8
        wait for 20 ns;
        i_div_a_tb <= "1111";  -- 15
        i_div_b_tb <= "0011";  -- 3
        wait for 20 ns;
        i_div_b_tb <= (others => '0');
        wait for 20 ns;
        i_div_a_tb <= "1101";  -- 13
        i_div_b_tb <= "0111";  -- 7
        wait for 20 ns;
        wait;
    end process;
end Behavioral;