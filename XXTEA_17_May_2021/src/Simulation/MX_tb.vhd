----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2021 04:51:16 PM
-- Design Name: 
-- Module Name: MX_tb - Behavioral
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

entity MX_tb is
--  Port ( );
end MX_tb;

architecture Behavioral of MX_tb is

component MX is
  port (
    i_mx_clk : in  std_logic;
    i_mx_y   : in  std_logic_vector(31 downto 0);  -- Input y variable
    i_mx_z   : in  std_logic_vector(31 downto 0);  -- Input z variable
    i_mx_e   : in  std_logic_vector(31 downto 0);  -- Input e variable
    i_mx_p   : in  std_logic_vector(1 downto 0);   -- Input p variable
    i_mx_sum : in  std_logic_vector(31 downto 0);  -- Input sum variable
    i_mx_key : in  std_logic_vector(127 downto 0); -- Input key
    o_mx_MX  : out std_logic_vector(31 downto 0)   -- Output completed MX value
    );
end component;

  constant clk_period: time := 10 ns;
  
  signal i_mx_clk_tb : std_logic;
  signal i_mx_y_tb   : std_logic_vector(31 downto 0);
  signal i_mx_z_tb   : std_logic_vector(31 downto 0);
  signal i_mx_e_tb   : std_logic_vector(31 downto 0);
  signal i_mx_p_tb   : std_logic_vector(1 downto 0);
  signal i_mx_sum_tb : std_logic_vector(31 downto 0);
  signal i_mx_key_tb : std_logic_vector(127 downto 0);
  signal o_mx_MX_tb  : std_logic_vector(31 downto 0);
  
begin
  CLK_GEN: process
  begin
    i_mx_clk_tb <= '0';
    wait for clk_period/2;
    i_mx_clk_tb <= '1';
    wait for clk_period/2;
  end process;
  
  MX_COMP: MX
    port map (
      i_mx_clk => i_mx_clk_tb,
      i_mx_y   => i_mx_y_tb,
      i_mx_z   => i_mx_z_tb,
      i_mx_e   => i_mx_e_tb,
      i_mx_p   => i_mx_p_tb,
      i_mx_sum => i_mx_sum_tb,
      i_mx_key => i_mx_key_tb,
      o_mx_MX  => o_mx_MX_tb
      );

  TEST_CASE: process
  begin
    -- First encryption round with MX
    i_mx_y_tb   <= x"74657374";  -- ASCII "Test" in hex
--    i_mx_z_tb   <= x"00000000";
    i_mx_z_tb   <= x"66696c65";  -- ASCII "File" in hex
    i_mx_e_tb   <= x"00000002";  -- (sum >> 2) & 3
    i_mx_p_tb   <= "00";
    i_mx_sum_tb <= x"9E3779b9";  -- sum = DELTA
    i_mx_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "Encryption Tests" in hex
    wait for clk_period;
    i_mx_p_tb   <= "01";
    wait for clk_period;
    i_mx_p_tb   <= "10";
    wait for clk_period;
    i_mx_p_tb   <= "11";
    wait;
  end process;
end Behavioral;
