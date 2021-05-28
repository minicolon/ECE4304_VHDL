----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/15/2021 04:29:50 PM
-- Design Name: 
-- Module Name: enc_round_tb - Behavioral
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

entity enc_round_tb is
  generic (g_WIDTH_TB : integer := 128);
--  Port ( );
end enc_round_tb;

architecture Behavioral of enc_round_tb is
  component enc_round is
    generic (g_WIDTH_RND : integer := 128);
    port (
      i_rnd_clk  : in  std_logic;
      i_rnd_rst  : in  std_logic;
      i_rnd_key  : in  std_logic_vector(127 downto 0);
      i_rnd_e    : in  std_logic_vector(31 downto 0);
      i_rnd_sum  : in  std_logic_vector(31 downto 0);
      i_rnd_v    : in  std_logic_vector(g_WIDTH_RND - 1 downto 0);
      o_rnd_v    : out std_logic_vector(g_WIDTH_RND - 1 downto 0);
      o_rnd_done : out std_logic
      );
  end component;

  constant clk_period: time := 10 ns;
  
  signal i_rnd_clk_tb  : std_logic;
  signal i_rnd_rst_tb  : std_logic;
  signal i_rnd_key_tb  : std_logic_vector(127 downto 0);
  signal i_rnd_e_tb    : std_logic_vector(31 downto 0);
  signal i_rnd_sum_tb  : std_logic_vector(31 downto 0);
  signal i_rnd_v_tb    : std_logic_vector(g_WIDTH_TB - 1 downto 0);
  signal o_rnd_v_tb    : std_logic_vector(g_WIDTH_TB - 1 downto 0);
  signal o_rnd_done_tb : std_logic;
  
begin
  CLK_GEN: process
  begin
    i_rnd_clk_tb <= '1';
    wait for clk_period/2;
    i_rnd_clk_tb <= '0';
    wait for clk_period/2;
  end process;

  ROUND_COMP: enc_round
    generic map (g_WIDTH_RND => g_WIDTH_TB)
    port map (
      i_rnd_clk  => i_rnd_clk_tb,
      i_rnd_rst  => i_rnd_rst_tb,
      i_rnd_key  => i_rnd_key_tb,
      i_rnd_e    => i_rnd_e_tb,
      i_rnd_sum  => i_rnd_sum_tb,
      i_rnd_v    => i_rnd_v_tb,
      o_rnd_v    => o_rnd_v_tb,
      o_rnd_done => o_rnd_done_tb
      );
      
  -- Test with 4-word input
  TEST_CASE_4: process
  begin
    -- First round
    i_rnd_rst_tb <= '1';
    i_rnd_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "encryption tests" in hex
    i_rnd_sum_tb <= x"9e3779b9";  -- sum = DELTA
    i_rnd_e_tb   <= x"00000002";  -- (sum >> 2) & 3
    i_rnd_v_tb   <= x"7465737466696c6566696c6574657374"; -- ASCII "File Test" in hex with '1' padding
    wait for clk_period;
    i_rnd_rst_tb <= '0';
    
    -- Simulate the second round
--    wait for 31*clk_period;
--    i_rnd_v_tb   <= x"dafa8e7bba1892a63486326e2e47caf3";
--    i_rnd_sum_tb <= x"3C6EF372"; --sum = 2*DELTA
--    i_rnd_e_tb   <= x"00000002";  -- (sum >> 2) & 3
    wait;
  end process;
  
  -- Test with 3-word input
--  TEST_CASE_3: process
--  begin
--    -- First Round
--    i_rnd_rst_tb <= '1';
--    i_rnd_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "encryption tests" in hex
--    i_rnd_sum_tb <= x"9e3779b9";  -- sum = DELTA
--    i_rnd_e_tb   <= x"00000002";  -- (sum >> 2) & 3
--    i_rnd_v_tb   <= x"0000000066696c6574657374"; -- ASCII "File Test" in hex with padding
--    wait for clk_period;
--    i_rnd_rst_tb <= '0';

--    -- Simulate as second round
--    wait for 43*clk_period;
--    i_rnd_v_tb   <= x"aba589b01b71791d244c76f2";
--    i_rnd_sum_tb <= x"3C6EF372"; --sum = 2*DELTA
--    i_rnd_e_tb   <= x"00000000";  -- (sum >> 2) & 3
--    wait;
--  end process;

  -- Test with 2-word input
--  TEST_CASE_2: process
--  begin
--    -- First Round
--    i_rnd_rst_tb <= '1';
--    i_rnd_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "encryption tests" in hex
--    i_rnd_sum_tb <= x"9e3779b9";  -- sum = DELTA
--    i_rnd_e_tb   <= x"00000002";  -- (sum >> 2) & 3
--    i_rnd_v_tb   <= x"66696c6574657374"; -- ASCII "filetest" in hex with padding
--    wait for clk_period;
--    i_rnd_rst_tb <= '0';
    
--    -- Simulate as second round
----    wait for 25*clk_period;
----    i_rnd_v_tb   <= x"cc4267c54bff6a89";
----    i_rnd_sum_tb <= x"3C6EF372"; --sum = 2*DELTA
----    i_rnd_e_tb   <= x"00000000";  -- (sum >> 2) & 3
--    wait;    
--  end process;
end Behavioral;
