----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/15/2021 07:20:27 PM
-- Design Name: 
-- Module Name: dec_round - round_arch
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

-- Entity that sets up the logic to create a single round for decryption
-- Will work for any word size greater than 2 (64-bits) 
-- Comments under generate statements are an example of the mapping for a 4-word input
entity dec_round is
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
end dec_round;

architecture round_arch of dec_round is
  component MX is
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
  end component;
  
  -- Signal declaration 
  constant num_words : integer := g_WIDTH_RND/32;                                         -- Constant to set the number of words
  signal s_v         : std_logic_vector(g_WIDTH_RND - 1 downto 0)     := (others => '0'); -- Signal to hold intermitent v values
  signal s_p         : std_logic_vector((g_WIDTH_RND/32)- 1 downto 0) := (others => '0'); -- P signal for MX component 
  signal s_delay     : std_logic_vector((g_WIDTH_RND/32) downto 0)    := (others => '0'); -- Delay signal between each s_p
  
  -- Array for the MX output and left word MX input
  type MX_type is array (0 to num_words-1) of std_logic_vector(31 downto 0);
  signal s_z : MX_type := (others => (others => '0'));  
  signal s_MX: MX_type := (others => (others => '0'));
  
  -- Array for the right word MX input
  type y_type is array (0 to num_words) of std_logic_vector(31 downto 0);
  signal s_y: y_type := (others => (others => '0'));
  
begin
  -- Generates the MX(v[i-1],v[i+1]) mapping for a single round
  GEN_ROUND: for i in num_words - 1 downto 0 generate
    MX_COMP: MX
      port map(
        i_mx_clk => i_rnd_clk,
        i_mx_y   => s_y(num_words - 1 - i),
        i_mx_z   => s_z(num_words - 1 - i),
        i_mx_e   => i_rnd_e,
        i_mx_p   => std_logic_vector(to_unsigned(i, 2)),
        i_mx_sum => i_rnd_sum,
        i_mx_key => i_rnd_key,
        o_mx_MX  => s_MX(i) -- MX[3], MX[2], MX[1], MX[0]
        ); 
  end generate;
  
  -- Gnerates the y array logic
  GEN_Y: for i in 0 to num_words generate
    -- i = 0
    FIRST: if (i = 0) generate
      s_y(i) <= i_rnd_v(31 downto 0);  -- y(0) = v'[0]
    end generate;
    
    -- i = 1, 2, 3, 4
    -- y(n:1) = v
    -- y(1) = v[3] = v'[3] - MX[3]
    -- y(2) = v[2] = v'[2] - MX[2]
    -- y(3) = v[1] = v'[1] - MX[1]
    -- y(4) = v[0] = v'[0] - MX[0]
    REMAINING: if (i > 0) generate
      s_y(i) <= i_rnd_v(g_WIDTH_RND - 32*(i - 1) - 1 downto g_WIDTH_RND - 32*(i)) - s_MX(num_words - i);
    end generate;
  end generate;
  
  -- Gnerates the z array logic
  GEN_Z: for i in 0 to num_words - 1 generate
    REMAINING: if(i < num_words - 1) generate
      s_z(i) <= i_rnd_v(g_WIDTH_RND - 32*(i + 1) - 1 downto g_WIDTH_RND - 32*(i + 2));   -- z(i) = v'[2], v'[1], v'[0]
    end generate;
    
    LAST: if (i = num_words - 1) generate
      s_z(i) <= s_y(num_words - i);  -- z(i) = v[n - 1] = v[3]
    end generate;
  end generate;
  
  -- Generates the temp signal that holds the encoded output
  GEN_V: for i in 0 to num_words - 1 generate
    s_v(32*(i + 1) - 1 downto 32*i) <= s_y(num_words - i); -- s_y(1:4) = v
  end generate;
  
  -- Process that creates a counter p with a delay for each p-value
  p_COUNT: process(i_rnd_clk, i_rnd_rst)
  begin
    if (i_rnd_rst = '1') then
      s_p     <= (others => '0');
      s_delay <= (others => '0');
    elsif(rising_edge(i_rnd_clk)) then
      if(s_delay = num_words + 2) then
        s_delay <= (others => '0');
        if(s_p = num_words) then
          s_p <= (others => '0');
        else     
          s_p <= s_p + 1;
      end if;
      else
        s_delay <= s_delay + 1;
      end if;
    end if;
  end process;
  
  -- Combinational logic based on the counter 'p' value 
  p_ROUND: process(s_p)
  begin
    if(s_p = num_words) then
      o_rnd_done <= '1';
      o_rnd_v    <= s_v;
    else
      o_rnd_done <= '0';
      o_rnd_v    <= i_rnd_v;
    end if;
  end process;

end round_arch;
