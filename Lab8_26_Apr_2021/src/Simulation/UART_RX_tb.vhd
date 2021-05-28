----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2021 02:18:55 PM
-- Design Name: 
-- Module Name: UART_RX_tb - Behavioral
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

entity UART_RX_tb is
--  Port ( );
end UART_RX_tb;

architecture Behavioral of UART_RX_tb is

component UART_RX is
  generic (
    g_CLKS_PER_BIT : integer := 87    -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_reset     : in  std_logic; 
    i_RX_Serial : in  std_logic;
    ReadEn      : in  std_logic;
    DATAOUT_FIFO: out std_logic_vector(7 downto 0);
    Empty       : out std_logic; 
    Full        : out std_logic 
    );
end component;

constant clk_period: time := 0.1 ns;

signal i_clk_tb: std_logic;
signal i_reset_tb: std_logic;
signal i_RX_Serial_tb: std_logic;
signal ReadEn_tb: std_logic;
signal DATAOUT_FIFO_tb: std_logic_vector(7 downto 0);
signal Empty_tb: std_logic;
signal Full_tb: std_logic;

begin
  p_CLOCK_GEN: process
  begin
    i_clk_tb <= '1';
    wait for clk_period/2;
    i_clk_tb <= '0';
    wait for clk_period/2;
  end process;
  
  UART_COMP: UART_RX
    generic map (g_CLKS_PER_BIT => 3)
    port map (
      i_Clk        => i_clk_tb,
      i_reset      => i_reset_tb,
      i_RX_Serial  => i_RX_Serial_tb,
      ReadEn       => ReadEn_tb,
      DATAOUT_FIFO => DATAOUT_FIFO_tb,
      Empty        => Empty_tb,
      Full         => Full_tb
      );
      
  p_TEST_CASE: process
  begin
    i_reset_tb <= '1';
    i_RX_Serial_tb <= '1';
    ReadEn_tb <= '0';
    wait for clk_period;
    i_reset_tb <= '0';
    i_RX_Serial_tb <= '0';
    wait for 2.3 ns;
    i_RX_Serial_tb <= '1';
    wait for 154*clk_period;
    i_RX_Serial_tb <= '0';
    wait for 200 ns;
    i_RX_Serial_tb <= '1';
    wait for 100 ns;
    ReadEn_tb <= '1';
    wait for 20*clk_period;
    ReadEn_tb <= '0';
    wait for 150 ns;
    ReadEn_tb <= '1';
    wait for 50*clk_period;
    ReadEn_tb <= '0';
    wait for 150 ns;
    ReadEn_tb <= '1';
    wait for 50*clk_period;
    ReadEn_tb <= '0';
--    wait for 150 ns;
--    ReadEn_tb <= '1';
--    wait for 50*clk_period;
--    ReadEn_tb <= '0';
    wait;
  end process;
end Behavioral;
