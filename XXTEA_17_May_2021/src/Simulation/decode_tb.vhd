----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/16/2021 08:00:03 PM
-- Design Name: 
-- Module Name: decode_tb - Behavioral
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

entity decode_tb is
  generic (g_WIDTH_TB : integer := 64);
--  Port ( );
end decode_tb;

architecture Behavioral of decode_tb is

component decode is
  generic (g_WIDTH_DEC: integer := 128);  -- Generic parameter to set the # of words in 32 bit increments
  port (
    i_dec_clk    : in  std_logic;
    i_dec_rst    : in  std_logic;
    i_dec_start  : in  std_logic; -- Signal to load value and begin encrypting
    i_dec_v      : in  std_logic_vector(g_WIDTH_DEC - 1 downto 0);  -- Input word vector for encrypting
                                                                    -- In C this is dynamic, so an
                                                                    -- arbitrary max value is set
    i_dec_key    : in  std_logic_vector(127 downto 0);              -- Input the 128-bit Encryption Key 
    o_dec_v      : out std_logic_vector(g_WIDTH_DEC - 1 downto 0);  -- Output the encrypted word
    o_dec_done   : out std_logic                                    -- Outputs a done signal when encryption is finished
    );
end component;

 constant clk_period: time := 0.5 ns;
  
  signal i_dec_clk_tb   : std_logic;
  signal i_dec_rst_tb   : std_logic;
  signal i_dec_start_tb : std_logic;
  signal i_dec_v_tb     : std_logic_vector(g_WIDTH_TB - 1 downto 0);
  signal i_dec_key_tb   : std_logic_vector(127 downto 0);
  signal o_dec_v_tb     : std_logic_vector(g_WIDTH_TB - 1 downto 0);
  signal o_dec_done_tb  : std_logic;
  
begin
  CLK_GEN: process
  begin
    i_dec_clk_tb <= '0';
    wait for clk_period/2;
    i_dec_clk_tb <= '1';
    wait for clk_period/2;
  end process;

  DEC_COMP: decode
    generic map (g_WIDTH_DEC => g_WIDTH_TB)
    port map(
      i_dec_clk => i_dec_clk_tb,
      i_dec_rst => i_dec_rst_tb,
      i_dec_start => i_dec_start_tb,
      i_dec_v => i_dec_v_tb,
      i_dec_key => i_dec_key_tb,
      o_dec_v => o_dec_v_tb,
      o_dec_done => o_dec_done_tb
      );
  
  -- Test with a 5-word input
--  TEST_CASE_5: process
--  begin
--    i_dec_rst_tb <= '1';
--    i_dec_v_tb   <= x"c7b65d16a2c4f4d452a5db6e8c010a0c3ea49671"; -- ASCII "testfilefiletest" in hex
--    i_dec_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "encryption tests" in hex
--    i_dec_start_tb <= '1';
--    wait for clk_period;
--    i_dec_rst_tb   <= '0';
--    wait for clk_period;
--    i_dec_start_tb <= '0';
    
--    wait for 1000*clk_period;
--    i_dec_start_tb <= '1';
--    wait for clk_period;
--    i_dec_start_tb <= '0';
--    wait;
--  end process;
       
  -- Test with a 4-word input
--  TEST_CASE_4: process
--  begin
--    i_dec_rst_tb <= '1';
--    i_dec_v_tb   <= x"2bb97ff4268bacfc24c4694c1ed79883"; -- ASCII "testfilefiletest" in hex
--    i_dec_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "encryption tests" in hex
--    i_dec_start_tb <= '1';
--    wait for clk_period;
--    i_dec_rst_tb   <= '0';
--    wait for clk_period;
--    i_dec_start_tb <= '0';
    
--    wait for 1000*clk_period;
--    i_dec_start_tb <= '1';
--    wait for clk_period;
--    i_dec_start_tb <= '0';
--    wait;
--  end process;
  
  -- Test with 3-word input
--  TEST_CASE_3: process
--  begin
--    i_dec_rst_tb <= '1';
--    i_dec_v_tb   <= x"b96e669eecd5105101d18a12"; -- ASCII "filefiletest" in hex
--    --i_dec_v_tb   <= x"b8f6e54faad8007eb9f0fc6c";
--    --i_dec_v_tb   <= x"420045f0fbdf228d2952d91a";
--    i_dec_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "encryption tests" in hex
--    i_dec_start_tb <= '1';
--    wait for clk_period;
--    i_dec_rst_tb   <= '0';
--    wait for clk_period;
--    i_dec_start_tb <= '0';
    
--    wait for 1000*clk_period;
--    i_dec_start_tb <= '1';
--    wait for clk_period;
--    i_dec_start_tb <= '0';
--    wait;
--  end process;
  
  -- Test with 2-word input
  TEST_CASE_2: process
  begin
    i_dec_rst_tb <= '1';
    i_dec_v_tb   <= x"e81e9729811e4471";  -- ASCII "filetest" in hex
    i_dec_key_tb <= x"656e6372797074696f6e207465737473"; -- ASCII "encryption tests" in hex
    i_dec_start_tb <= '1';
    wait for clk_period;
    i_dec_rst_tb   <= '0';
    wait for clk_period;
    i_dec_start_tb <= '0';
    
    wait for 1000*clk_period;
    i_dec_start_tb <= '1';
    wait for clk_period;
    i_dec_start_tb <= '0';
    wait;
  end process;
end Behavioral;
