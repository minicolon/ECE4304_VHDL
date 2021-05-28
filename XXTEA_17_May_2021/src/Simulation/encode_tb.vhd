----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2021 04:51:16 PM
-- Design Name: 
-- Module Name: encode_tb - Behavioral
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

entity encode_tb is
  generic (g_WIDTH_TB : integer := 96);
--  Port ( );
end encode_tb;

architecture Behavioral of encode_tb is

component encode is
  generic (g_WIDTH_ENC: integer := 128);  -- Generic parameter to set the # of words in 32 bit increments
  port (
    i_enc_clk    : in  std_logic;
    i_enc_rst    : in  std_logic;
    i_enc_start  : in  std_logic; -- Signal to load value and begin encrypting
    i_enc_v      : in  std_logic_vector(g_WIDTH_ENC - 1 downto 0);  -- Input word vector for encrypting
                                                                    -- In C this is dynamic, so an
                                                                    -- arbitrary max value is set
    i_enc_key    : in  std_logic_vector(127 downto 0);              -- Input the 128-bit Encryption Key 
    o_enc_v      : out std_logic_vector(g_WIDTH_ENC - 1 downto 0);  -- Output the encrypted word
    o_enc_done   : out std_logic                                    -- Outputs a done signal when encryption is finished
    );
end component;

  constant clk_period: time := 0.5 ns;
  
  signal i_enc_clk_tb   : std_logic;
  signal i_enc_rst_tb   : std_logic;
  signal i_enc_start_tb : std_logic;
  signal i_enc_v_tb     : std_logic_vector(g_WIDTH_TB - 1 downto 0);
  signal i_enc_key_tb   : std_logic_vector(127 downto 0);
  signal o_enc_v_tb     : std_logic_vector(g_WIDTH_TB - 1 downto 0);
  signal o_enc_done_tb  : std_logic;
  
begin
  CLK_GEN: process
  begin
    i_enc_clk_tb <= '0';
    wait for clk_period/2;
    i_enc_clk_tb <= '1';
    wait for clk_period/2;
  end process;

  ENC_COMP: encode
    generic map (g_WIDTH_ENC => g_WIDTH_TB)
    port map(
      i_enc_clk => i_enc_clk_tb,
      i_enc_rst => i_enc_rst_tb,
      i_enc_start => i_enc_start_tb,
      i_enc_v => i_enc_v_tb,
      i_enc_key => i_enc_key_tb,
      o_enc_v => o_enc_v_tb,
      o_enc_done => o_enc_done_tb
      );

  -- Test with a 5-word input
--  TEST_CASE_5: process
--  begin
--    i_enc_rst_tb <= '1';
--    i_enc_v_tb   <= x"66696c657465737466696c6566696c6574657374"; -- ASCII "filetestfilefiletest" in hex
--    i_enc_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "encryption tests" in hex
--    i_enc_start_tb <= '1';
--    wait for clk_period;
--    i_enc_rst_tb   <= '0';
--    wait for clk_period;
--    i_enc_start_tb <= '0';
    
--    wait for 1000*clk_period;
--    i_enc_start_tb <= '1';
--    wait for 18*clk_period;
--    i_enc_start_tb <= '0';
--    wait;
--  end process;
    
  -- Test with a 4-word input
--  TEST_CASE_4: process
--  begin
--    i_enc_rst_tb <= '1';
--    i_enc_v_tb   <= x"7465737466696c6566696c6574657374"; -- ASCII "testfilefiletest" in hex
--    i_enc_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "encryption tests" in hex
--    i_enc_start_tb <= '1';
--    wait for clk_period;
--    i_enc_rst_tb   <= '0';
--    wait for clk_period;
--    i_enc_start_tb <= '0';
    
--    wait for 1000*clk_period;
--    i_enc_start_tb <= '1';
--    wait for clk_period;
--    i_enc_start_tb <= '0';
--    wait;
--  end process;
  
  -- Test with 3-word input
  TEST_CASE_3: process
  begin
    i_enc_rst_tb <= '1';
    i_enc_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "encryption tests" in hex
    i_enc_v_tb   <= x"7465737466696c6574657374"; -- ASCII "testfiletest" in hex with padding
    i_enc_start_tb <= '1';
    wait for clk_period;
    i_enc_rst_tb <= '0';
    wait for clk_period;
    i_enc_start_tb <= '0';
    
    wait for 1000*clk_period;
    i_enc_start_tb <= '1';
    wait for clk_period;
    i_enc_start_tb <= '0';
    wait;
  end process;

  -- Test with 2-word input
--  TEST_CASE_2: process
--  begin
--    i_enc_rst_tb <= '1';
--    i_enc_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "encryption tests" in hex
--    i_enc_v_tb   <= x"66696c6574657374"; -- ASCII "filetest" in hex
--    i_enc_start_tb <= '1';
--    wait for clk_period;
--    i_enc_rst_tb <= '0';
--    wait for clk_period;
--    i_enc_start_tb <= '0';
    
--    wait for 1000*clk_period;
--    i_enc_start_tb <= '1';
--    wait for clk_period;
--    i_enc_start_tb <= '0';
--    wait;
--  end process;
end Behavioral;
