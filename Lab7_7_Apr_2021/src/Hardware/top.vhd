----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2021 02:29:26 PM
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
use IEEE.math_real."log2";
use IEEE.math_real."ceil";

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
  port (
    i_top_clk   : in  std_logic;                     -- Input a top clock signal
    i_top_rst   : in  std_logic;                     -- Input a reset signal
    i_top_inst  : in  std_logic_vector(7 downto 0);  -- Input instruction set to control data 
                                                     -- i_top_inst(7) = read enable fifo A
                                                     -- i_top_inst(6) = read enable fifo B
                                                     -- i_top_inst(5) = BS left/right shift signal
                                                     -- i_top_inst(4 downto 2) = BS shift amount
                                                     -- i_top_inst(1 downto 0) = AU operation select
    i_top_tx    : in  std_logic;                     -- Input pc Tx data into FPGA Rx unit
    o_top_full  : out std_logic_vector(1 downto 0);  -- Output the full flags for both A and B
    o_top_empty : out std_logic_vector(1 downto 0);  -- Output the empty flags for both fifo A and B
    o_top_sseg  : out std_logic_vector(6 downto 0);  -- Output selected sseg value
    o_top_an    : out std_logic_vector(7 downto 0);  -- Output selected anode value
    o_top_dp    : out std_logic                      -- Output decimal point "off" signal
    );
end top;

architecture top_arch of top is

component rx_unit is
  generic (g_RX_CLKS_PER_BIT: integer := 87);        -- (10MHz/115200) = 87
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

component barrel_shifter is
  generic (g_WIDTH_BS: integer := 8);                                                           -- Barrel shifter word size generic parameter
  port (
    i_barrel_lr    : in  std_logic;                                                             -- Input left/right shift selector: '1' = right shift, '0' = left shift
    i_barrel_value : in  std_logic_vector(g_WIDTH_BS - 1 downto 0);                             -- Input value
    i_barrel_shift : in  std_logic_vector(integer(ceil(log2(real(g_WIDTH_BS)))) - 1 downto 0);  -- Input desired shift amount
    o_barrel_new   : out std_logic_vector(g_WIDTH_BS - 1 downto 0)                              -- Output newly shifted value
    );
end component;

component arith_unit is
  generic (g_WIDTH_AU: integer := 4);  -- Generic data width parameter
  port (
    i_arith_clk  : in  std_logic;  -- input clock for AU
    i_arith_inst : in  std_logic_vector(1 downto 0); -- Input instructions to decide what arithmetic to output
    i_arith_a    : in  std_logic_vector(g_WIDTH_AU - 1 downto 0); -- Input port A
    i_arith_b    : in  std_logic_vector(g_WIDTH_AU - 1 downto 0); -- Input port B
    o_arith_data : out std_logic_vector((2*g_WIDTH_AU) - 1 downto 0) -- Output the data based on the inst
    );
end component;

component display_unit is
  port (
    i_disp_clk  : in  std_logic;                      -- Input clock signal
    i_disp_rst  : in  std_logic;                      -- Input reset signal
    i_disp_bs_a : in  std_logic_vector(7 downto 0);   -- Input Barrel Shifted A value for 2 ssegs
    i_disp_bs_b : in  std_logic_vector(7 downto 0);   -- Input Barrel Shifted B value for 2 ssegs
    i_disp_au   : in  std_logic_vector(15 downto 0);  -- Input AU value to display over 4 ssegs
    o_disp_sseg : out std_logic_vector(6 downto 0);   -- Output selected sseg 
    o_disp_an   : out std_logic_vector(7 downto 0);   -- Output current selected anode
    o_disp_dp   : out std_logic                       -- Output the decimal point signal, set to off = '1'
    );
end component;

component debounce_unit is
  port (
    i_db_clk: in std_logic;  -- Input clock
    i_db_rst: in std_logic;  -- Input reset
    i_db_btn: in std_logic;  -- Input button to debounce
    o_db_new: out std_logic  -- Output Debounced signal
    );
end component;

constant data_width: integer := 8;                       -- Byte sized data width, 8 bits
constant rx_clks_per_bit: integer := 41;                 -- (10MHz/(115200*2)) = 43, the 2 is because there is a check in the middle of the bit
                                                         -- Speed is sligthly too slow and gives incorrect value for latter nibble, drop by 2 clk cycles per bit

signal temp_data_a     : std_logic_vector(7 downto 0);   -- Fifo B data for BS
signal temp_data_b     : std_logic_vector(7 downto 0);   -- Fifo B data for BS
signal temp_data_a_new : std_logic_vector(7 downto 0);   -- Newly shifted A value
signal temp_data_b_new : std_logic_vector(7 downto 0);   -- Newly shifted B value
signal temp_data_au    : std_logic_vector(15 downto 0);  -- Arithmetic data value
signal temp_db_btn     : std_logic_vector(1 downto 0);   -- Debounced read enable button

begin
  DB_COMP_A: debounce_unit
    port map (
      i_db_clk => i_top_clk,
      i_db_rst => i_top_rst,
      i_db_btn => i_top_inst(7),
      o_db_new => temp_db_btn(1)
      );

  DB_COMP_B: debounce_unit
    port map (
      i_db_clk => i_top_clk,
      i_db_rst => i_top_rst,
      i_db_btn => i_top_inst(6),
      o_db_new => temp_db_btn(0)
      );
      
  RX_COMP: rx_unit
    generic map(g_RX_CLKS_PER_BIT => rx_clks_per_bit)
    port map(
      i_rx_clk     => i_top_clk,
      i_rx_rst     => i_top_rst,
      i_rx_data    => i_top_tx,
      i_rx_read_en => temp_db_btn,
      o_rx_data_a  => temp_data_a,
      o_rx_data_b  => temp_data_b,
      o_rx_full    => o_top_full,
      o_rx_empty   => o_top_empty
      );

  BS_A_COMP: barrel_shifter
    generic map(g_WIDTH_BS => data_width)
    port map(
      i_barrel_lr    => i_top_inst(5),        
      i_barrel_value => temp_data_a,
      i_barrel_shift => i_top_inst(4 downto 2),
      o_barrel_new   => temp_data_a_new
      );
  
  BS_B_COMP: barrel_shifter
    generic map(g_WIDTH_BS => data_width)
    port map(
      i_barrel_lr    => i_top_inst(5),        
      i_barrel_value => temp_data_b,
      i_barrel_shift => i_top_inst(4 downto 2),
      o_barrel_new   => temp_data_b_new
      );
  
  AU_COMP: arith_unit
    generic map(g_WIDTH_AU => data_width)
    port map(
      i_arith_clk  => i_top_clk,
      i_arith_inst => i_top_inst(1 downto 0),
      i_arith_a    => temp_data_a_new,
      i_arith_b    => temp_data_b_new,
      o_arith_data => temp_data_au
      );
  
  DISP_COMP: display_unit
    port map(
      i_disp_clk => i_top_clk,
      i_disp_rst => i_top_rst,
      i_disp_bs_a => temp_data_a_new,
      i_disp_bs_b => temp_data_b_new,
      i_disp_au => temp_data_au,
      o_disp_sseg => o_top_sseg,
      o_disp_an => o_top_an,
      o_disp_dp => o_top_dp
      );
end top_arch;
