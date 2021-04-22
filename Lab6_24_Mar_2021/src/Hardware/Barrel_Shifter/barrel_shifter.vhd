----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/22/2021 12:42:29 PM
-- Design Name: 
-- Module Name: barrel_shifter - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Left/Right barrel shifter entity
entity barrel_shifter is
  generic (g_WIDTH_BS: integer := 32);                                                           -- Barrel shifter word size generic parameter
  port (
    i_barrel_lr    : in  std_logic;                                                             -- Input left/right shift selector: '1' = right shift, '0' = left shift
    i_barrel_value : in  std_logic_vector(g_WIDTH_BS - 1 downto 0);                             -- Input value
    i_barrel_shift : in  std_logic_vector(integer(ceil(log2(real(g_WIDTH_BS)))) - 1 downto 0);  -- Input desired shift amount
    o_barrel_new   : out std_logic_vector(g_WIDTH_BS - 1 downto 0)                              -- Output newly shifted value
    );
end barrel_shifter;

architecture bs_arch of barrel_shifter is

-- Instantiate the right shifter component
component right_shifter is
  generic (g_WIDTH_RIGHT:integer := 8);                                                           -- Right shifter generic parameter
  port (
    i_right_value : in  std_logic_vector(g_WIDTH_RIGHT - 1 downto 0);                             -- Input value for shifting
    i_right_shift : in  std_logic_vector(integer(ceil(log2(real(g_WIDTH_RIGHT)))) - 1 downto 0);  -- Input shifting amount
    o_right_new   : out std_logic_vector(g_WIDTH_RIGHT - 1 downto 0)                              -- Output new shifted value
    );
end component;

-- Instantiate the left shifter component
component left_shifter is
  generic (g_WIDTH_LEFT:integer := 8);                                                          -- Right shifter generic parameter
  port (
    i_left_value : in  std_logic_vector(g_WIDTH_LEFT - 1 downto 0);                             -- Input value for shifting
    i_left_shift : in  std_logic_vector(integer(ceil(log2(real(g_WIDTH_LEFT)))) - 1 downto 0);  -- Input shifting amount
    o_left_new   : out std_logic_vector(g_WIDTH_LEFT - 1 downto 0)                              -- Output new shifted value
    );
end component;

-- Temp signal instantiation
signal temp_right_new : std_logic_vector(g_WIDTH_BS - 1 downto 0);
signal temp_left_new  : std_logic_vector(g_WIDTH_BS - 1 downto 0);

begin 
  RIGHT_COMP: right_shifter
  generic map(g_WIDTH_RIGHT => g_WIDTH_BS)
  port map(
    i_right_value => i_barrel_value,
    i_right_shift => i_barrel_shift,
    o_right_new   => temp_right_new
    );
    
  LEFT_COMP: left_shifter
  generic map(g_WIDTH_LEFT => g_WIDTH_BS)
  port map(
    i_left_value => i_barrel_value,
    i_left_shift => i_barrel_shift,
    o_left_new   => temp_left_new
    );  
  
  -- 2x1 mux process to decide which shifted vlaue is sent to the output
  p_LR_OUT: process(i_barrel_lr, temp_right_new, temp_left_new)
  begin
    if(i_barrel_lr = '1') then -- If the lr select is high output the right shift
      o_barrel_new <= temp_right_new;
    else  -- If the lr select is low output the left shift
      o_barrel_new <= temp_left_new;
    end if;
  end process;
  
end bs_arch;
