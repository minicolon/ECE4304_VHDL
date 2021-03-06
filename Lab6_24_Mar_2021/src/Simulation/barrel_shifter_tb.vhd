----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/22/2021 03:25:18 PM
-- Design Name: 
-- Module Name: barrel_shifter_tb - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.math_real."log2";
use IEEE.math_real."ceil";
use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity barrel_shifter_tb is
  generic(g_WIDTH_TB: integer := 16);
--  Port ( );
end barrel_shifter_tb;

architecture Behavioral of barrel_shifter_tb is
  
component barrel_shifter is
  generic (g_WIDTH_BS: integer := 8);
  port (
    i_barrel_lr    : in  std_logic;
    i_barrel_value : in  std_logic_vector(g_WIDTH_BS - 1 downto 0);
    i_barrel_shift : in  std_logic_vector(integer(ceil(log2(real(g_WIDTH_BS)))) - 1 downto 0);
    o_barrel_new   : out std_logic_vector(g_WIDTH_BS - 1 downto 0)
    );
end component;

signal i_barrel_lr_tb    : std_logic;
signal i_barrel_value_tb : std_logic_vector(g_WIDTH_TB - 1 downto 0);
signal i_barrel_shift_tb : std_logic_vector(integer(ceil(log2(real(g_WIDTH_TB)))) - 1 downto 0);
signal o_barrel_new_tb   : std_logic_vector(g_WIDTH_TB - 1 downto 0);

constant time_step: time := 10 ns;

begin
  BS_COMP: barrel_shifter
    generic map(g_WIDTH_BS => g_WIDTH_TB)
    port map(
      i_barrel_lr    => i_barrel_lr_tb,
      i_barrel_value => i_barrel_value_tb,
      i_barrel_shift => i_barrel_shift_tb,
      o_barrel_new   => o_barrel_new_tb
      );

  p_TEST_CASE: process
  begin
    -- Test Left Shift
    i_barrel_lr_tb <= '0';
    i_barrel_value_tb <= x"F000";
    i_barrel_shift_tb <= "0000";
    wait for time_step;
    
    for i in 0 to 15 loop
      i_barrel_shift_tb <= i_barrel_shift_tb + "0001";
      wait for time_step;
    end loop;

    -- Test Right Shift
    i_barrel_lr_tb <= '1';
--    i_barrel_value_tb <= x"F0";
    i_barrel_shift_tb <= "0000";
    wait for time_step;
    
    for i in 0 to 15 loop
      i_barrel_shift_tb <= i_barrel_shift_tb + "0001";
      wait for time_step;
    end loop;
            
    wait;
  end process;
end Behavioral;
