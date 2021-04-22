----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/01/2021 12:18:43 PM
-- Design Name: 
-- Module Name: debounce_unit - db_arch
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Entity for debouncing a push button
entity debounce_unit is
  port (
    i_db_clk: in std_logic;  -- Input clock
    i_db_rst: in std_logic;  -- Input reset
    i_db_btn: in std_logic;  -- Input button to debounce
    o_db_new: out std_logic  -- Output Debounced signal
    );
end debounce_unit;

architecture db_arch of debounce_unit is

constant count_bits : integer := 10;                                                -- Sets the counter bit size
constant count_max  : std_logic_vector(count_bits - 1 downto 0) := (others => '1'); -- Creates a max value to count to

signal count       : std_logic_vector(count_bits - 1 downto 0) := (others => '0');  -- Signal used to count 
signal start_count : std_logic := '0';                                              -- Signal to determine when to count

begin
  -- Process that hold debouncing logic
  p_DB: process(i_db_clk, i_db_rst, i_db_btn)
  begin
    if(i_db_rst = '1') then -- Async reset for counter and output signal
      o_db_new <= '0';
      count <= (others => '0');
    elsif(rising_edge(i_db_clk)) then -- Creates a synchronous counter
      if((i_db_btn = '1') and (start_count = '0')) then -- When a button is pressed start the counter
        o_db_new <= '0';
        start_count <= '1';
        count <= (others => '0');
      elsif((start_count = '1') and (count >= count_max)) then -- Once the counter max value has been reached, drive the output high
        o_db_new <= '1';
        start_count <= '0';
        count <= (others => '0');
      else
        o_db_new <= '0';
        if((start_count = '1') and (count < count_max)) then -- As long as the max value has not been reached continue counting
          count <= count + 1;
        end if;
      end if;
    end if;
  end process;
end db_arch;