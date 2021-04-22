----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/08/2021 07:13:15 PM
-- Design Name: 
-- Module Name: generic_counter - Behavioral
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Basic up counter with async reset
entity generic_counter is
    generic(g_WIDTH: integer := 4);
    Port( 
        i_clk  : in STD_LOGIC;
        i_rst  : in STD_LOGIC;
        o_count: out std_logic_vector(g_WIDTH - 1 downto 0)
        );
end generic_counter;

architecture Behavioral of generic_counter is

begin

GEN_COUNT: process(i_clk, i_rst)
    variable v_count  : std_logic_vector(g_WIDTH - 1 downto 0);
    variable temp_tick: std_logic;
    begin
        if(i_rst ='1') then
            v_count := (others => '0');
        elsif(rising_edge(i_clk)) then    
            v_count := v_count + 1;    
        end if;
        
        o_count <= v_count;
    end process;
end Behavioral;
