----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2021 03:59:56 PM
-- Design Name: 
-- Module Name: port_a_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity port_a_tb is
  generic (g_WIDTH_TB: integer := 4);
--  Port ( );
end port_a_tb;

architecture Behavioral of port_a_tb is

component port_a is
  generic (g_WIDTH_A: integer := 4); -- Generic parameter to specify data size
  port (
    i_port_a_clk  : in  std_logic;  -- Input port clock for register
    i_port_a_sel  : in  std_logic;  -- Input select for sseg data format output
    i_port_a_data : in  std_logic_vector(g_WIDTH_A - 1 downto 0);  -- Input data
    o_port_a_data : out std_logic_vector(g_WIDTH_A - 1 downto 0);  -- Output data
    o_port_a_sseg : out std_logic_vector(6 downto 0)               -- Output sseg representation
    );
end component;

constant time_step: time := 10 ns;

signal i_port_a_clk_tb: std_logic;
signal i_port_a_sel_tb: std_logic;
signal i_port_a_data_tb: std_logic_vector(g_WIDTH_TB - 1 downto 0) := (others => '0');
signal o_port_a_data_tb: std_logic_vector(g_WIDTH_TB - 1 downto 0);
signal o_port_a_sseg_tb: std_logic_vector(6 downto 0);

begin
  -- Generate a clock signal
  p_GEN_CLK: process
  begin
    i_port_a_clk_tb <= '1';
    wait for time_step/2;
    i_port_a_clk_tb <= '0';
    wait for time_step/2;    
  end process;
  
  PORT_A_COMP: port_a
    generic map (g_WIDTH_A => g_WIDTH_TB)
    port map(
      i_port_a_clk  => i_port_a_clk_tb,
      i_port_a_sel  => i_port_a_sel_tb,
      i_port_a_data => i_port_a_data_tb,
      o_port_a_data => o_port_a_data_tb,
      o_port_a_sseg => o_port_a_sseg_tb 
      );
  
  p_TEST_CASE: process
  begin
    i_port_a_sel_tb <= '0';
    wait for time_step;
    for i in 0 to 15 loop
      i_port_a_data_tb <= i_port_a_data_tb + 1;
      wait for time_step;
    end loop;
    
    i_port_a_sel_tb <= '1';
    wait for time_step;
    for i in 0 to 15 loop
      i_port_a_data_tb <= i_port_a_data_tb + 1;
      wait for time_step;
    end loop;
    wait;
  end process;
end Behavioral;
