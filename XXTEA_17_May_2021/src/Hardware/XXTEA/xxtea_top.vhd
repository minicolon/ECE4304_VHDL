----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/14/2021 08:07:38 PM
-- Design Name: 
-- Module Name: xxtea_top - xxtea_arch
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

-- Corrected Block TEA (XXTEA) Algorithm implementation
-- Follows similar format and naming to original reference code for easy readability
-- Currently designed for any 32--bit increment value to encrypt
entity xxtea_top is
  generic (g_WIDTH_XXTEA : integer := 64);                             -- Generic parameter to set the # of words
  port (
    i_xxtea_clk   : in  std_logic;                                     -- Input clock
    i_xxtea_rst   : in  std_logic;                                     -- Input reset
    i_xxtea_start : in  std_logic_vector(1 downto 0);                  -- Input start signals for both encrypting and decrypting
                                                                       -- Start encrypting = i_xxtea_start(1)
                                                                       -- Start decrypting = i_xxtea_start(0)
    i_xxtea_v     : in  std_logic_vector(g_WIDTH_XXTEA - 1 downto 0);  -- Input v with a given number of words
    i_xxtea_key   : in  std_logic_vector(127 downto 0);                -- Input 128-bit key
    o_xxtea_done  : out std_logic;                                     -- Output done signal
    o_xxtea_enc   : out std_logic_vector(g_WIDTH_XXTEA - 1 downto 0);  -- Output the encrypted v-value
    o_xxtea_dec   : out std_logic_vector(g_WIDTH_XXTEA - 1 downto 0)   -- Output the decrypted v-value, should match the input
    );
end xxtea_top;

architecture xxtea_arch of xxtea_top is

  component decode is
    generic (g_WIDTH_DEC: integer := 128);                            -- Generic parameter to set the # of words in 32 bit increments
    port (
      i_dec_clk    : in  std_logic;                                   -- Input clock
      i_dec_rst    : in  std_logic;                                   -- Input reset
      i_dec_start  : in  std_logic;                                   -- Signal to load value and begin decrypting
      i_dec_v      : in  std_logic_vector(g_WIDTH_DEC - 1 downto 0);  -- Input word vector for decrypting
                                                                      -- In C this is dynamic, so an
                                                                      -- arbitrary max value is set
      i_dec_key    : in  std_logic_vector(127 downto 0);              -- Input the 128-bit Encryption Key 
      o_dec_v      : out std_logic_vector(g_WIDTH_DEC - 1 downto 0);  -- Output the encrypted word
      o_dec_done   : out std_logic                                    -- Outputs a done signal when decryption is finished
      );
  end component;

  component encode is
    generic (g_WIDTH_ENC: integer := 128);                            -- Generic parameter to set the # of words in 32 bit increments
    port (
      i_enc_clk    : in  std_logic;                                   -- Input clock
      i_enc_rst    : in  std_logic;                                   -- Input reset
      i_enc_start  : in  std_logic;                                   -- Signal to load value and begin encrypting
      i_enc_v      : in  std_logic_vector(g_WIDTH_ENC - 1 downto 0);  -- Input word vector for encrypting
                                                                      -- In C this is dynamic, so an
                                                                      -- arbitrary max value is set
      i_enc_key    : in  std_logic_vector(127 downto 0);              -- Input the 128-bit Encryption Key 
      o_enc_v      : out std_logic_vector(g_WIDTH_ENC - 1 downto 0);  -- Output the encrypted word
      o_enc_done   : out std_logic                                    -- Outputs a done signal when encryption is finished
      );
  end component;

  -- Signal declaration
  signal s_enc_done  : std_logic;
  signal s_dec_done  : std_logic;
  signal s_dec_start : std_logic;
  signal s_enc_v     : std_logic_vector(g_WIDTH_XXTEA - 1 downto 0);
  signal s_dec_v     : std_logic_vector(g_WIDTH_XXTEA - 1 downto 0);
  
begin
  o_xxtea_enc  <= s_enc_v;
  o_xxtea_dec  <= s_dec_v;
  o_xxtea_done <= s_dec_done;
  s_dec_start  <= i_xxtea_start(0) and s_enc_done; -- allow decrypting if encryption done signal is high
  
  ENC_COMP: encode
    generic map (g_WIDTH_ENC => g_WIDTH_XXTEA)
    port map(
      i_enc_clk   => i_xxtea_clk,
      i_enc_rst   => i_xxtea_rst,
      i_enc_start => i_xxtea_start(1),
      i_enc_v     => i_xxtea_v,
      i_enc_key   => i_xxtea_key,
      o_enc_v     => s_enc_v,
      o_enc_done  => s_enc_done
      );
  
  DEC_COMP: decode
    generic map (g_WIDTH_DEC => g_WIDTH_XXTEA)
    port map(
      i_dec_clk   => i_xxtea_clk,
      i_dec_rst   => i_xxtea_rst,
      i_dec_start => s_dec_start,
      i_dec_v     => s_enc_v,
      i_dec_key   => i_xxtea_key,
      o_dec_v     => s_dec_v,
      o_dec_done  => s_dec_done
      );
  
end xxtea_arch;
