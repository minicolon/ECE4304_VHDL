----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2021 02:38:55 PM
-- Design Name: 
-- Module Name: rx_unit - rx_arch
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

-- Rx circuit that uses two fifo buffers
entity rx_unit is
  generic (g_RX_CLKS_PER_BIT: integer := 87);       -- (10MHz/115200) = 87
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
end rx_unit;

architecture rx_arch of rx_unit is

component UART_RX is
  generic (g_CLKS_PER_BIT : integer := 87);           -- (10MHz/115200) = 87
  port (
    i_Clk        : in  std_logic;                     -- Input clock signal
    i_reset      : in  std_logic;                     -- Input reset signal
    i_RX_Serial  : in  std_logic;                     -- Input serial data
    ReadEn       : in  std_logic;                     -- Enable for reading from fifo
    DATAOUT_FIFO : out std_logic_vector(7 downto 0);  -- Output data from fifo when read
    Empty        : out std_logic;                     -- Output empty flag
    Full         : out std_logic                      -- Output full flag
    );
end component;

signal temp_full_a: std_logic := '0';  -- Temp full signal used for logic between fifo A and B
signal temp_full_b: std_logic := '0';  -- Temp full signal used for logic between fifo A and B
signal temp_data_a: std_logic := '1';  -- Temp serial data signal for A with initialization
signal temp_data_b: std_logic := '1';  -- Temp serial data signal for B with initialization

begin
  -- Instantiate Fifo A
  RX_A: UART_RX
    generic map (g_CLKS_PER_BIT => g_RX_CLKS_PER_BIT) 
    port map (
      i_Clk        => i_rx_clk,
      i_reset      => i_rx_rst,
      i_RX_Serial  => temp_data_a,
      ReadEn       => i_rx_read_en(1),
      DATAOUT_FIFO => o_rx_data_a,
      Empty        => o_rx_empty(1),
      Full         => temp_full_a
      );
  o_rx_full(1) <= temp_full_a;

  -- Instantiate Fifo B
  RX_B: UART_RX
    generic map (g_CLKS_PER_BIT => g_RX_CLKS_PER_BIT)
    port map (
      i_Clk        => i_rx_clk,
      i_reset      => i_rx_rst,
      i_RX_Serial  => temp_data_b,
      ReadEn       => i_rx_read_en(0),
      DATAOUT_FIFO => o_rx_data_b,
      Empty        => o_rx_empty(0),
      Full         => temp_full_b
      );
  o_rx_full(0) <= temp_full_b;
  
  -- Process to determine when A and B are being written to
  p_IN_DATA_LOGIC: process(i_rx_data, i_rx_clk, temp_full_a, temp_full_b)
  begin
    if(rising_edge(i_rx_clk)) then -- Use rising edge of clock to use F.F. and prevent latching
      if (temp_full_a = '1') then  -- If fifo A is full then start writing input data to fifo B
        temp_data_b <= i_rx_data;
      else
        temp_data_a <= i_rx_data;
      end if;
    end if;
  end process;
end rx_arch;
