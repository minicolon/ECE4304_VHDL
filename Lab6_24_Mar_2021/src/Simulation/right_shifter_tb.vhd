----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2021 09:24:46 AM
-- Design Name: 
-- Module Name: right_shifter_tb - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity right_shifter_tb is
  generic(g_WIDTH_TB: integer := 8);
--  Port ( );
end right_shifter_tb;

architecture Behavioral of right_shifter_tb is

component right_shifter is
  generic (g_WIDTH_RIGHT: integer := 8);
  port (
    i_right_value : in  std_logic_vector(g_WIDTH_RIGHT - 1 downto 0);
    i_right_shift : in  std_logic_vector(integer(ceil(log2(real(g_WIDTH_RIGHT)))) - 1 downto 0);
    o_right_new   : out std_logic_vector(g_WIDTH_RIGHT - 1 downto 0)
    );
end component;

signal i_right_value_tb : std_logic_vector(g_WIDTH_TB - 1 downto 0);
signal i_right_shift_tb : std_logic_vector(integer(ceil(log2(real(g_WIDTH_TB)))) - 1 downto 0);
signal o_right_new_tb   : std_logic_vector(g_WIDTH_TB - 1 downto 0);

constant time_step: time := 10 ns;

begin
  RIGHT_COMP: right_shifter
    generic map(g_WIDTH_RIGHT => g_WIDTH_TB)
    port map(
      i_right_value => i_right_value_tb,
      i_right_shift => i_right_shift_tb,
      o_right_new   => o_right_new_tb
      );

  p_TEST_CASE: process
  begin
    i_right_value_tb <= x"E0";
    i_right_shift_tb <= "000";
    wait for time_step;
    
    -- Loop 0-7, 4 times 
    for i in 0 to 31 loop
      i_right_shift_tb <= i_right_shift_tb + "001";
      wait for time_step;
    end loop;
    
    wait;
  end process;

end Behavioral;
