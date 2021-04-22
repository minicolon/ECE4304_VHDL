----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2021 07:07:41 PM
-- Design Name: 
-- Module Name: bcd_counter - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bcd_counter is
    Port(
        i_bcd_clk: in  std_logic;                    -- Input clock for the bcd counter
        i_bcd_rst: in  std_logic;                    -- Input reset for the bcd counter
        i_bcd_ud : in  std_logic;                    -- Input up/down signal for bcd counter
        o_bcd_val: out std_logic_vector(3 downto 0); -- Output current bcd count value
        o_bcd_en : out std_logic                     -- output an enable bit set when either at 0 or 9 based on counting direction
        );
end bcd_counter;

architecture Behavioral of bcd_counter is

signal temp_bcd   : std_logic_vector(3 downto 0); -- Temp signal for bcd value
signal rst_auto   : std_logic;                    -- Temp signal to hold reset signal
signal bcd_gen_rst: std_logic;                    -- Temp signal to hold generated reset signal

begin
    -- Reset on either input or auto generated reset
    rst_auto <= i_bcd_rst or bcd_gen_rst;
    
    p_BCD_GEN: process (i_bcd_clk, rst_auto)
    begin
        if(rst_auto = '1') then
            if(i_bcd_ud = '1') then -- When up/down signal and reset is high, set counter to 0
                temp_bcd <= (others => '0');
            else -- When up/down signal is low and reset is high, set counter to 9
                temp_bcd <= "1001";
            end if;
        elsif(rising_edge(i_bcd_clk)) then
                if(i_bcd_ud = '1') then -- At posedge of clock, if ud is high, count up
                    temp_bcd <= temp_bcd + 1;
                else -- At posedge of clock, if ud is low, count down
                    temp_bcd <= temp_bcd - 1;
                end if;  
        end if;
        o_bcd_val <= temp_bcd; -- Assign the output bcd value to the current count value    
    end process;
    
    -- Process to auto generate a reset signal whether high or low
    p_GEN_FLAG: process(i_bcd_clk, rst_auto)
    begin
        if(rst_auto = '1') then -- when reset is high set the auto reset to low
            bcd_gen_rst <= '0';
        elsif(rising_edge(i_bcd_clk)) then -- When (ud == '1' and bcd == '9') or (ud == '0' and bcd == '0'), set auto reset to high
            bcd_gen_rst <= (i_bcd_ud and temp_bcd(3) and (not temp_bcd(2)) and (not temp_bcd(1)) and (temp_bcd(0))) 
                           or ((not i_bcd_ud) and ((not temp_bcd(0)) and (not temp_bcd(1)) and (not temp_bcd(2)) and (not temp_bcd(3))));
        end if;
        o_bcd_en <= bcd_gen_rst; -- Assign output enable signal to high
    end process; 
end Behavioral;
