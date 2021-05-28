----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2021 05:47:00 PM
-- Design Name: 
-- Module Name: encode - encode_arch
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Entity that carries out the encryption process
entity encode is
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
end encode;

architecture encode_arch of encode is
  component enc_round is
    generic (g_WIDTH_RND : integer := 128);                         -- Generic parameter for number of words
    port (
      i_rnd_clk  : in  std_logic;                                   -- Input clock
      i_rnd_rst  : in  std_logic;                                   -- Input reset
      i_rnd_key  : in  std_logic_vector(127 downto 0);              -- Input the assigned key
      i_rnd_e    : in  std_logic_vector(1 downto 0);                -- Input the e variable
      i_rnd_sum  : in  std_logic_vector(31 downto 0);               -- Input the sum variable
      i_rnd_v    : in  std_logic_vector(g_WIDTH_RND - 1 downto 0);  -- Input the previous round's value
      o_rnd_v    : out std_logic_vector(g_WIDTH_RND - 1 downto 0);  -- Output the round's new encrypted value
      o_rnd_done : out std_logic                                    -- Output a round done signal
      );
  end component;
  
  -- Signal and constant declaration
  constant num_words : integer := g_WIDTH_ENC/32;                                      -- Define how many words to encrypt
  constant max_round : integer := 6 + (52/num_words);                                  -- Set the max round to finish at
  constant DELTA     : std_logic_vector(31 downto 0)              := x"9E3779b9";      -- Pre-assigned DELTA value
  signal s_sum       : std_logic_vector(31 downto 0)              := DELTA;            -- Signal for the sum MX-input parameter
  signal s_e         : std_logic_vector(1 downto 0)               := "10";             -- Signal for the e MX-input parameter
  signal s_rounds    : std_logic_vector(5 downto 0)               := (others => '0');  -- Round signal for counting the amount of rounds
  signal s_v         : std_logic_vector(g_WIDTH_ENC - 1 downto 0) := (others => '0');  -- V signal for all round values
  signal s_rnd_v     : std_logic_vector(g_WIDTH_ENC - 1 downto 0) := (others => '0');  -- Holds the output of the curent round
  signal s_rnd_clk   : std_logic;                                                      -- Create a clock to stop the MX when finished
  signal s_rnd_done  : std_logic;                                                      -- Holds the round done signal
  signal s_encrypt   : std_logic;                                                      -- Signal to begin encrypting

begin
  -- Only encrypt while encrypt signal is high
  s_rnd_clk <= i_enc_clk and s_encrypt;

  ROUND_COMP: enc_round
    generic map (g_WIDTH_RND => g_WIDTH_ENC)
    port map (
      i_rnd_clk  => s_rnd_clk,
      i_rnd_rst  => i_enc_rst,
      i_rnd_key  => i_enc_key,
      i_rnd_e    => s_e,
      i_rnd_sum  => s_sum,
      i_rnd_v    => s_v,
      o_rnd_v    => s_rnd_v,
      o_rnd_done => s_rnd_done
      );

  -- Logic based on when a round ends and the done signal is high
  p_ROUND: process(s_rnd_done, i_enc_rst, i_enc_start)
  begin
    -- If rst or start is high, intialize
    if(i_enc_rst = '1') or (i_enc_start = '1') then
      if(i_enc_start = '1') then
        s_encrypt <= '1';
      else
        s_encrypt <= '0';
      end if;
      s_rounds <= (others => '0');
      s_sum <= DELTA;
    
    -- When the max round is hit, count once more and stop encryption
    elsif(s_rounds = max_round) then
      s_encrypt <= '0';
      s_rounds <= s_rounds + 1;
     
    -- When the previous conditions are unmet, while not at max round, count
    elsif(s_rnd_done = '1') then
      if(s_rounds < max_round) then
        s_sum <= s_sum + DELTA;
        s_rounds <= s_rounds + 1;
      end if;
    end if;
  end process;

  --
  p_ENCODE: process(i_enc_clk, i_enc_rst)
  begin
    if(i_enc_rst = '1') then
      o_enc_v <= (others => '0');
      o_enc_done <= '0';
      s_v <= i_enc_v;
      s_e <= "10";
      
    elsif(rising_edge(i_enc_clk)) then
      -- When start signal is high, set the output to the input 
      if(i_enc_start = '1') then
        o_enc_v <= i_enc_v;
        
      else
        o_enc_done <= '0';
        
        -- When the rounds are at 0 set the temp signal to the input v
        if(s_rounds = 0) then
          s_v <= i_enc_v;
        
        -- When at the final round send a done signal and assign the output to the temp signal  
        elsif(s_rounds > max_round) then
          o_enc_v <= s_v;
          o_enc_done <= '1';
          s_e <= "10";
        
        -- If previous conditions are unmet 
        else
          s_e <= s_sum(3 downto 2); -- equivalent of e = (sum >> 2) & 3
          if(s_rnd_done = '1') then
            s_v <= s_rnd_v;
          end if;
        end if;
      end if;
    end if;
  end process;
  
end encode_arch;
