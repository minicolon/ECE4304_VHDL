----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2021 05:47:00 PM
-- Design Name: 
-- Module Name: decode - decode_arch
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

-- Entity that carries out the entire decryption process
entity decode is
  generic (g_WIDTH_DEC: integer := 128);                            -- Generic parameter to set the # of words in 32 bit increments
  port (
    i_dec_clk    : in  std_logic;                                   -- Input clock
    i_dec_rst    : in  std_logic;                                   -- Input reset
    i_dec_start  : in  std_logic;                                   -- Signal to load value and begin encrypting
    i_dec_v      : in  std_logic_vector(g_WIDTH_DEC - 1 downto 0);  -- Input word vector for encrypting
                                                                    -- In C this is dynamic, so an
                                                                    -- arbitrary max value is set
    i_dec_key    : in  std_logic_vector(127 downto 0);              -- Input the 128-bit Encryption Key 
    o_dec_v      : out std_logic_vector(g_WIDTH_DEC - 1 downto 0);  -- Output the encrypted word
    o_dec_done   : out std_logic                                    -- Outputs a done signal when encryption is finished
    );
end decode;

architecture decode_arch of decode is
  component dec_round is
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
  constant num_words : integer := g_WIDTH_DEC/32;                                      -- Define how many words to decrypt
  constant max_round : integer := 6 + (52/num_words);                                  -- Set the max round to finish at
  constant DELTA     : std_logic_vector(31 downto 0) := x"9E3779b9";                   -- Pre-assigned DELTA value
  constant DELTA_i   : unsigned(31 downto 0) := unsigned(DELTA);                       -- Convert DELTA into an integer
  constant sum_round : unsigned(63 downto 0) := (max_round*DELTA_i);                   -- Constant to calculate the beginning sum value
  constant c_sum     : std_logic_vector(63 downto 0) := std_logic_vector(sum_round);   -- Constant to hold the initialized sum value
  constant c_e       : std_logic_vector(1 downto 0) := c_sum(3 downto 2);              -- Constant to hold the initialized e value
  signal s_sum       : std_logic_vector(31 downto 0) := c_sum(31 downto 0);            -- Signal for the sum MX-input parameter
  signal s_e         : std_logic_vector(1 downto 0) := c_e;                            -- Signal for the e MX-input parameter
  signal s_rounds    : std_logic_vector(5 downto 0) := (others => '0');                -- Round signal for counting the amount of rounds
  signal s_v         : std_logic_vector(g_WIDTH_DEC - 1 downto 0) := (others => '0');  -- V signal for all round values
  signal s_rnd_v     : std_logic_vector(g_WIDTH_DEC - 1 downto 0) := (others => '0');  -- Holds the output of the curent round
  signal s_rnd_clk   : std_logic;                                                      -- Create a clock to stop the MX when finished
  signal s_rnd_done  : std_logic;                                                      -- Holds the round done signal
  signal s_decrypt   : std_logic;                                                      -- Signal to begin decrypting
  
begin
  -- Only decrypt while decrypt signal is high
  s_rnd_clk <= i_dec_clk and s_decrypt;

  ROUND_COMP: dec_round
    generic map (g_WIDTH_RND => g_WIDTH_DEC)
    port map (
      i_rnd_clk  => s_rnd_clk,
      i_rnd_rst  => i_dec_rst,
      i_rnd_key  => i_dec_key,
      i_rnd_e    => s_e,
      i_rnd_sum  => s_sum,
      i_rnd_v    => s_v,
      o_rnd_v    => s_rnd_v,
      o_rnd_done => s_rnd_done
      );

  -- Logic based on when a round ends and the done signal is high
  p_ROUND: process(s_rnd_done, i_dec_rst, i_dec_start)
  begin
    -- If rst or start is high, intialize
    if(i_dec_rst = '1') or (i_dec_start = '1') then
      if(i_dec_start = '1') then
        s_decrypt <= '1';
      else
        s_decrypt <= '0';
      end if;
      s_rounds <= (others => '0');
      s_sum <= c_sum(31 downto 0);
      
    -- When the max round is hit, count once more and stop decryption
    elsif(s_rounds = max_round) then
      s_decrypt <= '0';
      s_rounds <= s_rounds + 1;
    
    -- When the previous conditions are unmet, while not at max round, count
    elsif(rising_edge(s_rnd_done)) then
      if(s_rounds < max_round) then
        s_sum <= s_sum - DELTA;
        s_rounds <= s_rounds + 1;
      end if;
    end if;
  end process;

  p_ENCODE: process(i_dec_clk, i_dec_rst)
  begin
    if(i_dec_rst = '1') then
      o_dec_v <= (others => '0');
      o_dec_done <= '0';
      s_v <= i_dec_v;
      s_e <= c_e;
      
    elsif(rising_edge(i_dec_clk)) then
      -- When start signal is high, set the output to the input 
      if(i_dec_start = '1') then
        o_dec_v <= i_dec_v;
        
      else
        o_dec_done <= '0';
        
        -- When the rounds are at 0 set the temp signal to the input v
        if(s_rounds = 0) then
          s_v <= i_dec_v;
          
        -- When at the final round send a done signal and assign the output to the temp signal 
        elsif(s_rounds > max_round) then
          o_dec_v <= s_v;
          o_dec_done <= s_rnd_done;
          s_e <= c_e;
          
        -- If previous conditions are unmet 
        else
          s_e <= s_sum(3 downto 2);  -- equivalent of e = (sum >> 2) & 3
          if(s_rnd_done = '1') then
            s_v <= s_rnd_v;
          end if;
        end if;
      end if;
    end if;
  end process;

end decode_arch;
