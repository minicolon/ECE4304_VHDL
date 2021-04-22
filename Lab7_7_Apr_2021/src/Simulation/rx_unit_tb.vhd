----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2021 01:10:45 PM
-- Design Name: 
-- Module Name: rx_unit_tb - Behavioral
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

entity rx_unit_tb is
--  Port ( );
end rx_unit_tb;

architecture Behavioral of rx_unit_tb is

component rx_unit is
  generic (g_RX_CLKS_PER_BIT: integer := 2);       -- (100MHz/115200) = 868
  port (
    i_rx_clk     : in  std_logic;                    -- Input clock
    i_rx_rst     : in  std_logic;                    -- Input reset
    i_rx_data    : in  std_logic;                    -- Input serial data, single bit at a time
    i_rx_read_en : in  std_logic_vector(1 downto 0); -- Input read enable signal for fifo A and B
    o_rx_data_a  : out std_logic_vector(7 downto 0); -- Output the data from fifo A
    o_rx_data_b  : out std_logic_vector(7 downto 0); -- Output the data from fifo B
    o_rx_full    : out std_logic_vector(1 downto 0); -- Output full signal of fifo A and B
    o_rx_empty   : out std_logic_vector(1 downto 0)  -- Output empty signal of fifo A and B
    );
end component;

constant clk_period: time := 0.1 ns; 

signal i_rx_clk_tb     : std_logic;
signal i_rx_rst_tb     : std_logic;
signal i_rx_data_tb    : std_logic_vector(8 downto 0); -- Byte data with start bit
signal i_rx_serial_tb  : std_logic;
signal i_rx_read_en_tb : std_logic_vector(1 downto 0);
signal o_rx_data_a_tb  : std_logic_vector(7 downto 0);
signal o_rx_data_b_tb  : std_logic_vector(7 downto 0);
signal o_rx_full_tb    : std_logic_vector(1 downto 0);
signal o_rx_empty_tb   : std_logic_vector(1 downto 0);

begin
  p_CLOCK_GEN: process
  begin
    i_rx_clk_tb <= '1';
    wait for clk_period/2;
    i_rx_clk_tb <= '0';
    wait for clk_period/2;
  end process;

  RX_COMP: rx_unit
    generic map (g_RX_CLKS_PER_BIT => 2)
    port map(
    i_rx_clk     => i_rx_clk_tb,
    i_rx_rst     => i_rx_rst_tb,
    i_rx_data    => i_rx_serial_tb,
    i_rx_read_en => i_rx_read_en_tb,
    o_rx_data_a  => o_rx_data_a_tb,
    o_rx_data_b  => o_rx_data_b_tb,
    o_rx_full    => o_rx_full_tb,
    o_rx_empty   => o_rx_empty_tb
    );

  p_TEST_CASE: process
  begin
    -- Fill FIFO A
    i_rx_rst_tb <= '1';
    i_rx_data_tb <= "10101010" & '0';
    i_rx_read_en_tb <= "00";
    wait for clk_period;
    i_rx_rst_tb <= '0';
    wait for 10*clk_period;
    i_rx_serial_tb <= i_rx_data_tb(0);
    wait for 22*clk_period;
    for i in 1 to 8 loop
      i_rx_serial_tb <= i_rx_data_tb(i);
      wait for 44*clk_period;
    end loop;
    
    wait for 44*clk_period;
    i_rx_data_tb <= "11001100" & '0';
    i_rx_serial_tb <= i_rx_data_tb(0);
    wait for 66*clk_period;
    for i in 1 to 8 loop
      i_rx_serial_tb <= i_rx_data_tb(i);
      wait for 44*clk_period;
    end loop;
    
    wait for 44*clk_period;
    i_rx_data_tb <= "10011001" & '0';
    i_rx_serial_tb <= i_rx_data_tb(0);
    wait for 66*clk_period;
    for i in 1 to 8 loop
      i_rx_serial_tb <= i_rx_data_tb(i);
      wait for 44*clk_period;
    end loop;

    wait for 44*clk_period;
    i_rx_data_tb <= "11111111" & '0';
    i_rx_serial_tb <= i_rx_data_tb(0);
    wait for 66*clk_period;
    for i in 1 to 8 loop
      i_rx_serial_tb <= i_rx_data_tb(i);
      wait for 44*clk_period;
    end loop;

    --Fill Fifo B
    wait for 44*clk_period;
    i_rx_data_tb <= "11001100" & '0';
    i_rx_serial_tb <= i_rx_data_tb(0);
    wait for 66*clk_period;
    for i in 1 to 8 loop
      i_rx_serial_tb <= i_rx_data_tb(i);
      wait for 44*clk_period;
    end loop;
    
    wait for 44*clk_period;
    i_rx_data_tb <= "10011001" & '0';
    i_rx_serial_tb <= i_rx_data_tb(0);
    wait for 66*clk_period;
    for i in 1 to 8 loop
      i_rx_serial_tb <= i_rx_data_tb(i);
      wait for 44*clk_period;
    end loop;

    wait for 44*clk_period;
    i_rx_data_tb <= "11111111" & '0';
    i_rx_serial_tb <= i_rx_data_tb(0);
    wait for 66*clk_period;
    for i in 1 to 8 loop
      i_rx_serial_tb <= i_rx_data_tb(i);
      wait for 44*clk_period;
    end loop;

    wait for 44*clk_period;
    i_rx_data_tb <= "11001100" & '0';
    i_rx_serial_tb <= i_rx_data_tb(0);
    wait for 66*clk_period;
    for i in 1 to 8 loop
      i_rx_serial_tb <= i_rx_data_tb(i);
      wait for 44*clk_period;
    end loop;
    
    -- Empty Both Fifo Buffers
    wait for 198*clk_period;
    for i in 0 to 3 loop
      wait for 22*clk_period;
      i_rx_read_en_tb <= "11";
      wait for 22*clk_period;
      i_rx_read_en_tb <= "00";
    end loop;
    wait;
  end process;
end Behavioral;
