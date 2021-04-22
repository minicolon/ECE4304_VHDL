----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2021 03:14:04 PM
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

-- Top File entity that controls Sseg logic and main barrel shifter code
entity top is
  generic (g_WIDTH_TOP: integer := 8);              -- Top entity generic parameter
  port(
    i_top_clk  : in  std_logic;                     -- Input clock for Ssegs
    i_top_rst  : in  std_logic;                     -- Input reset for Ssegs
    i_top_lr   : in  std_logic;                     -- Input left/right selector
    i_top_val  : in  std_logic_vector(7 downto 0);  -- Input desired vlaue
    i_top_shft : in  std_logic_vector(2 downto 0);  -- Input shifting amount
    o_top_sseg : out std_logic_vector(6 downto 0);  -- Output current Sseg value
    o_top_an   : out std_logic_vector(7 downto 0);  -- Output current slected anode
    o_top_leds : out std_logic_vector(11 downto 0); -- Output LEDs for all switch inputs
    o_top_dp   : out std_logic
    );
end top;

architecture top_arch of top is

-- Display component instantiation
component display_sseg is
  port(
    i_disp_clk     : in  std_logic;                     -- Input clock
    i_disp_rst     : in  std_logic;                     -- Input reset
    i_disp_bs_val  : in  std_logic_vector(7 downto 0);  -- Input value before shifting
    i_disp_bs_new  : in  std_logic_vector(7 downto 0);  -- Input value after shifting
    i_disp_bs_shft : in  std_logic_vector(3 downto 0);  -- Input shifting amount
    o_disp_sseg    : out std_logic_vector(6 downto 0);  -- Output sseg value
    o_disp_an      : out std_logic_vector(7 downto 0)   -- Output selected anode
    );
end component;

-- Barrel shifter component instantiation
component barrel_shifter is
  generic (g_WIDTH_BS: integer := 8);                                                           -- Barrel shifter word size generic parameter
  port (
    i_barrel_lr    : in  std_logic;                                                             -- Input left/right shift selector: '1' = right shift, '0' = left shift
    i_barrel_value : in  std_logic_vector(g_WIDTH_BS - 1 downto 0);                             -- Input value
    i_barrel_shift : in  std_logic_vector(integer(ceil(log2(real(g_WIDTH_BS)))) - 1 downto 0);  -- Input desired shift amount
    o_barrel_new   : out std_logic_vector(g_WIDTH_BS - 1 downto 0)                              -- Output newly shifted value
    );
end component;

-- Temp signal instantiation
signal temp_bs_new   : std_logic_vector(g_WIDTH_TOP - 1 downto 0);
signal temp_bs_shift : std_logic_vector(3 downto 0);

begin
  BS_COMP: barrel_shifter
    generic map(g_WIDTH_BS => g_WIDTH_TOP)
    port map(
      i_barrel_lr    => i_top_lr,        
      i_barrel_value => i_top_val,
      i_barrel_shift => i_top_shft,
      o_barrel_new   => temp_bs_new
      );
  
  -- Shift bits for 8 bit word is 3 bits, size to a standard 4 bits by concatenating with 0
  temp_bs_shift <= '0' & i_top_shft;
  
  DISPLAY_COMP: display_sseg
    port map(
    i_disp_clk     => i_top_clk,
    i_disp_rst     => i_top_rst,
    i_disp_bs_val  => i_top_val,
    i_disp_bs_new  => temp_bs_new,
    i_disp_bs_shft => temp_bs_shift,
    o_disp_sseg    => o_top_sseg,
    o_disp_an      => o_top_an
    );
  
  o_top_dp <= '1'; -- Turn off decimal points
  o_top_leds <= i_top_lr & i_top_shft & i_top_val; -- Assign all switches to output an led respective to each bit
end top_arch;
