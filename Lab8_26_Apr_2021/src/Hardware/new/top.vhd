----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2021 02:32:05 PM
-- Design Name: 
-- Module Name: top - top_arch
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

entity top is
  port (
    i_top_clk: in std_logic;
    i_top_rst: in std_logic;
    i_top_tx: in std_logic;
    i_top_color: in std_logic_vector(8 downto 0);
    o_top_red: out std_logic_vector(2 downto 0);
    o_top_green: out std_logic_vector(2 downto 0);
    o_top_blue: out std_logic_vector(2 downto 0);
    o_top_hsync: out std_logic;
    o_top_vsync: out std_logic
    );
end top;

architecture top_arch of top is

component UART_RX is
  generic (g_CLKS_PER_BIT : integer := 87);  -- (10MHz/115200) = 87
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

component vga_initials_top is
 generic (strip_hpixels :positive:= 800;   -- Value of pixels in a horizontal line = 800
          strip_vlines  :positive:= 512;   -- Number of horizontal lines in the display = 521
          strip_hbp     :positive:= 144;   -- Horizontal back porch = 144 (128 + 16)
          strip_hfp     :positive:= 784;   -- Horizontal front porch = 784 (128+16 + 640)
          strip_vbp     :positive:= 31;    -- Vertical back porch = 31 (2 + 29)
          strip_vfp     :positive:= 511    -- Vertical front porch = 511 (2+29+ 480)
         );
    Port ( clk  : in STD_LOGIC;
           rst  : in STD_LOGIC;
           rx   : in STD_LOGIC_VECTOR (7 downto 0);
           sw   : in STD_LOGIC_VECTOR (8 downto 0);
           hsync: out STD_LOGIC;
           vsync: out STD_LOGIC; 
           red  : out STD_LOGIC_VECTOR (2 downto 0); 
           green: out STD_LOGIC_VECTOR (2 downto 0);
           blue : out STD_LOGIC_VECTOR (2 downto 0)   
         );
end component;

component generic_counter is
  generic(g_WIDTH_COUNTER: integer := 7);
  port(
    i_count_clk : in std_logic;                                       -- Input a clock for the counter
    i_count_rst : in std_logic;                                       -- Input a reset of the counter
    -- o_count     : out std_logic_vector(g_WIDTH_COUNTER - 1 downto 0); -- Output the current counter value
    o_count_tick: out std_logic
    );
end component;

constant rx_clks_per_bit : integer := 41; -- (10MHz/(115200*2)) = 43, the 2 is because there is a check in the middle of the bit
                                          -- Speed is sligthly too slow and gives incorrect value for latter nibble, drop by 2 clk cycles per bit

signal s_rx_data : std_logic_vector(7 downto 0);   -- Fifo data 
signal s_enable  : std_logic;

begin
  COUNT_COMP: generic_counter
    generic map(g_WIDTH_COUNTER => 7)
    port map(
      i_count_clk  => i_top_clk,
      i_count_rst  => i_top_rst,
      o_count_tick => s_enable
      );
    
  RX_COMP: UART_RX
    generic map (g_CLKS_PER_BIT => rx_clks_per_bit) 
    port map (
      i_Clk        => i_top_clk,
      i_reset      => i_top_rst,
      i_RX_Serial  => i_top_tx,
      ReadEn       => s_enable,
      DATAOUT_FIFO => s_rx_data,
      Empty        => open,
      Full         => open
      );
      
  VGA_COMP: vga_initials_top
    generic map(
      strip_hpixels => 800,   -- Value of pixels in a horizontal line = 800
      strip_vlines  => 512,   -- Number of horizontal lines in the display = 521
      strip_hbp     => 144,   -- Horizontal back porch = 144 (128 + 16)
      strip_hfp     => 784,   -- Horizontal front porch = 784 (128+16 + 640)
      strip_vbp     => 31,    -- Vertical back porch = 31 (2 + 29)
      strip_vfp     => 511    -- Vertical front porch = 511 (2+29+ 480)
      )
    port map(
      clk   => i_top_clk,
      rst   => i_top_rst,
      rx    => s_rx_data,
      sw    => i_top_color,
      hsync => o_top_hsync,
      vsync => o_top_vsync,
      red   => o_top_red,
      green => o_top_green,
      blue  => o_top_blue
      );
end top_arch;
