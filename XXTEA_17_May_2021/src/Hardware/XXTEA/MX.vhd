----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2021 06:21:13 PM
-- Design Name: 
-- Module Name: MX - MX_arch
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Entity to create the C-implementation MX macro, shown below
-- MX = ((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (key[(p&3)^e] ^ z))
entity MX is
  port (
    i_mx_clk : in  std_logic;                      -- Input clock
    i_mx_y   : in  std_logic_vector(31 downto 0);  -- Input y variable
    i_mx_z   : in  std_logic_vector(31 downto 0);  -- Input z variable
    i_mx_e   : in  std_logic_vector(1 downto 0);   -- Input e variable
    i_mx_p   : in  std_logic_vector(1 downto 0);   -- Input p variable
    i_mx_sum : in  std_logic_vector(31 downto 0);  -- Input sum variable
    i_mx_key : in  std_logic_vector(127 downto 0); -- Input key
    o_mx_MX  : out std_logic_vector(31 downto 0)   -- Output completed MX value
    );
end MX;

architecture MX_arch of MX is
  signal s_xor_left  : std_logic_vector(31 downto 0) := (others => '0');  -- (z >> 5) ^ (y << 2)
  signal s_xor_right : std_logic_vector(31 downto 0) := (others => '0');  -- (y >> 3) ^ (z << 4)
  signal s_sum_xor   : std_logic_vector(31 downto 0) := (others => '0');  -- sum ^ y
  signal s_sel_key   : std_logic_vector(1 downto 0)  := (others => '0');  -- (p&3)^e
  signal s_key_xor   : std_logic_vector(31 downto 0) := (others => '0');  -- key[s_sel_key] ^ z
  signal s_add_xor_0 : std_logic_vector(31 downto 0) := (others => '0');  -- s_xor_left + s_xor_right
  signal s_add_xor_1 : std_logic_vector(31 downto 0) := (others => '0');  -- s_sum_xor + s_key_xor
  
  -- Used to break up 128-bit key into 4 32-bit sections
  type key_type is array (0 to 3) of std_logic_vector(31 downto 0);
  signal s_key: key_type;
  
begin
  -- Split the key into 4 segments for easy access
  GEN_KEY: for i in 0 to 3 generate
    s_key(i) <= i_mx_key(32*(i+1) - 1 downto 32*i);
  end generate; 
  
  -- Process that implements the MX macro from the original C-implementation
  p_MX: process(i_mx_clk)
  begin
    if (rising_edge(i_mx_clk)) then
    s_xor_left  <= ("00000" & i_mx_z(31 downto 5)) xor (i_mx_y(29 downto 0) & "00");
    s_xor_right <= ("000" & i_mx_y(31 downto 3)) xor (i_mx_z(27 downto 0) & "0000");
    s_sum_xor   <= i_mx_sum xor i_mx_y;
    s_sel_key   <= i_mx_p xor i_mx_e;
    s_key_xor   <= s_key(to_integer(unsigned(s_sel_key))) xor i_mx_z;

    s_add_xor_0 <= s_xor_left + s_xor_right;
    s_add_xor_1 <= s_sum_xor + s_key_xor;
    
    o_mx_MX     <= s_add_xor_0 xor s_add_xor_1;
    end if;
  end process;
end MX_arch;
