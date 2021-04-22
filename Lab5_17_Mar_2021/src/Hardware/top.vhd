----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2021 12:51:01 PM
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
  generic (g_WIDTH_TOP: integer := 4);                          -- Generic data width of top file
  port (
    i_top_clk  : in std_logic;                                  -- Input top clock
    i_top_inst : in std_logic_vector(3 downto 0);               -- Input instruction set:
                                                                -- [3:2] Used for AU selection
                                                                -- [1] Used to select B output
                                                                -- [0] Used to select A output
    i_top_a    : in std_logic_vector(g_WIDTH_TOP - 1 downto 0); -- Input of port A
    i_top_b    : in std_logic_vector(g_WIDTH_TOP - 1 downto 0); -- Input of port B
    o_top_sseg : out std_logic_vector(6 downto 0);              -- Output sseg value
    o_top_an   : out std_logic_vector(7 downto 0)               -- Output anode for ssegs
    );
end top;

architecture top_arch of top is

component port_a is
  generic (g_WIDTH_A: integer := 4);                               -- Generic parameter to specify data size
  port (
    i_port_a_clk  : in  std_logic;                                 -- Input port clock for register
    i_port_a_sel  : in  std_logic;                                 -- Input select for sseg data format output
    i_port_a_data : in  std_logic_vector(g_WIDTH_A - 1 downto 0);  -- Input data
    o_port_a_data : out std_logic_vector(g_WIDTH_A - 1 downto 0);  -- Output data
    o_port_a_sseg : out std_logic_vector(6 downto 0)               -- Output sseg representation
    );
end component;

component port_b is
  generic (g_WIDTH_B: integer := 4);                               -- Generic parameter to specify data size
  port (
    i_port_b_clk  : in  std_logic;                                 -- Input port clock for register
    i_port_b_sel  : in  std_logic;                                 -- Input select for sseg data format output
    i_port_b_data : in  std_logic_vector(g_WIDTH_B - 1 downto 0);  -- Input data
    o_port_b_data : out std_logic_vector(g_WIDTH_B - 1 downto 0);  -- Output data
    o_port_b_sseg : out std_logic_vector(6 downto 0)               -- Output sseg representation
    );
end component;

component arith_unit is
  generic (g_WIDTH_AU: integer := 4);                                 -- Generic data width parameter
  port (
    i_arith_clk  : in  std_logic;                                     -- input clock for AU
    i_arith_inst : in  std_logic_vector(1 downto 0);                  -- Input instructions to decide what arithmetic to output
    i_arith_a    : in  std_logic_vector(g_WIDTH_AU - 1 downto 0);     -- Input port A
    i_arith_b    : in  std_logic_vector(g_WIDTH_AU - 1 downto 0);     -- Input port B
    o_arith_data : out std_logic_vector((2*g_WIDTH_AU) - 1 downto 0)  -- Output the data based on the inst
    );
end component;

component hex_to_sseg is
  port(
    i_hex  : in  std_logic_vector(3 downto 0); -- Input hex value
    i_en   : in  std_logic;                    -- Input enable
    o_sseg : out std_logic_vector(6 downto 0)  -- Output sseg hex equivalent
    );
end component;

component sel_sseg is
  port (
    i_sseg_clk  : in  std_logic;                     -- Input clock for sseg selector
    i_sseg_a    : in  std_logic_vector(6 downto 0);  -- Input sseg A value
    i_sseg_b    : in  std_logic_vector(6 downto 0);  -- Input sseg B value
    i_sseg_au_0 : in  std_logic_vector(6 downto 0);  -- Input Ones sseg value
    i_sseg_au_1 : in  std_logic_vector(6 downto 0);  -- Input tens sseg value
    o_sseg_sel  : out std_logic_vector(6 downto 0);  -- Output selected sseg
    o_sseg_an   : out std_logic_vector(7 downto 0)   -- Output sseg anode
    );
end component;

component Bin_To_BCD is
  port(
    i_Binary : in  std_logic_vector(3 downto 0);  -- Input binary data
    o_BCD    : out std_logic_vector(3 downto 0)   -- Output of valid BCD
    );
end component;

--component double_dabble is
--  port (
--    i_dd_bin: in std_logic_vector(7 downto 0);
--    o_dd_bcd: out std_logic_vector(7 downto 0)
--    );
--end component;

-- Temp data signals to connect components
signal temp_a_data     : std_logic_vector(g_WIDTH_TOP - 1 downto 0);
signal temp_b_data     : std_logic_vector(g_WIDTH_TOP - 1 downto 0);
signal temp_arith_data : std_logic_vector((2*g_WIDTH_TOP) - 1 downto 0);
signal temp_dd_data    : std_logic_vector(7 downto 0);
signal temp_sseg_a     : std_logic_vector(6 downto 0);
signal temp_sseg_b     : std_logic_vector(6 downto 0);
signal temp_sseg_au_0  : std_logic_vector(6 downto 0);
signal temp_sseg_au_1  : std_logic_vector(6 downto 0);

begin
  -- Port A instantiation
  PORT_A_COMP: port_a
    generic map (g_WIDTH_A => g_WIDTH_TOP)
    port map(
      i_port_a_clk  => i_top_clk,
      i_port_a_sel  => i_top_inst(0),
      i_port_a_data => i_top_a,
      o_port_a_data => temp_a_data,
      o_port_a_sseg => temp_sseg_a
      );
  
  -- Port B instantiation
  PORT_B_COMP: port_b
    generic map (g_WIDTH_B => g_WIDTH_TOP)
    port map(
      i_port_b_clk  => i_top_clk,
      i_port_b_sel  => i_top_inst(1),
      i_port_b_data => i_top_b,
      o_port_b_data => temp_b_data,
      o_port_b_sseg => temp_sseg_b
      );
  
  -- Arithmetic unit instantiation
  AU_COMP: arith_unit
    generic map(g_WIDTH_AU => g_WIDTH_TOP)
    port map(
      i_arith_clk  => i_top_clk,
      i_arith_inst => i_top_inst(3 downto 2),
      i_arith_a    => temp_a_data,
      i_arith_b    => temp_b_data,
      o_arith_data => temp_arith_data
      );
      
--  DD_CONV_COMP: double_dabble
--    port map(
--      i_dd_bin => temp_arith_data,
--      o_dd_bcd => temp_dd_data
--      );      
 
--  AU_SSEG_0_COMP: hex_to_sseg
--    port map(
--      i_hex  => temp_dd_data(3 downto 0),
--      i_en   => '1',
--      o_sseg => temp_sseg_au_0
--      );

--  AU_SSEG_1_COMP: hex_to_sseg
--    port map(
--      i_hex  => temp_dd_data(7 downto 4),
--      i_en   => '1',
--      o_sseg => temp_sseg_au_1
--      );

  -- Hex to sseg for the ones value of the AU
  AU_SSEG_0_COMP: hex_to_sseg
    port map(
      i_hex  => temp_arith_data(3 downto 0),
      i_en   => '1',
      o_sseg => temp_sseg_au_0
      );

  -- Hex to sseg for the tens value of the AU
  AU_SSEG_1_COMP: hex_to_sseg
    port map(
      i_hex  => temp_arith_data(7 downto 4),
      i_en   => '1',
      o_sseg => temp_sseg_au_1
      );
  
  -- Selecter for one sseg at a time  
  SSEG_COMP: sel_sseg
    port map(
      i_sseg_clk  => i_top_clk,
      i_sseg_a    => temp_sseg_a,
      i_sseg_b    => temp_sseg_b,
      i_sseg_au_0 => temp_sseg_au_0,
      i_sseg_au_1 => temp_sseg_au_1,
      o_sseg_sel  => o_top_sseg,
      o_sseg_an   => o_top_an
      );
end top_arch;
