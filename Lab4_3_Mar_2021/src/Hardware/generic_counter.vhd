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

-- Generic counter that takes in the bit width, and counts to the max value allowed, ex: 4 bits, the max count is 1111
entity generic_counter is
    generic(g_WIDTH_COUNTER: integer := 4);
    Port(
        i_clk  : in std_logic;                                      -- Input a clock for the counter
        i_rst  : in std_logic;                                      -- Input a reset of the counter
        o_count: out std_logic_vector(g_WIDTH_COUNTER - 1 downto 0) -- Output the current counter value
        );
end generic_counter;

architecture Behavioral of generic_counter is

begin
    -- Process that counts upward by 1 each clock tick and contains an async reset
    p_GEN_COUNT: process(i_clk, i_rst)
    -- Variable that temporarily stores the count value
    variable v_count  : std_logic_vector(g_WIDTH_COUNTER - 1 downto 0);
    begin
        if(i_rst ='1') then -- If reset is high set counter to 0
            v_count := (others => '0');        
        elsif(rising_edge(i_clk)) then -- When clock is rising, count by 1
            v_count := v_count + 1;
        end if;    
        o_count <= v_count; -- Output the current count value
    end process;
end Behavioral;
