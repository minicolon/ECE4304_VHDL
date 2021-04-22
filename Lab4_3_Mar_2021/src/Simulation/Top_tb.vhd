library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top_tb is
--  Port ( );
end Top_tb;

architecture Behavioral of Top_tb is

component top
    Port(-- Port instantiation for board IO
        i_top_clk      : in  std_logic;
        i_top_rst_sseg : in  std_logic;
        i_top_rst_count: in  std_logic;
        i_top_SW_ud    : in  std_logic;
        i_top_SW_speed : in  std_logic_vector(1 downto 0);
        o_top_sseg     : out std_logic_vector(6 downto 0);
        o_top_anode    : out std_logic_vector(7 downto 0);
        o_top_dp       : out std_logic
        );
end component;

constant clock_period:time:=10ns;

signal i_top_clk_tb      :  std_logic;
signal i_top_rst_sseg_tb :  std_logic;
signal i_top_rst_count_tb:  std_logic;
signal i_top_SW_ud_tb    :  std_logic;
signal i_top_SW_speed_tb :  std_logic_vector(1 downto 0);
signal o_top_sseg_tb     :  std_logic_vector(6 downto 0);
signal o_top_anode_tb    :  std_logic_vector(7 downto 0);
signal o_top_dp_tb       :  std_logic;

begin

TOP_TB: top
    Port map(-- Port instantiation for board IO
        i_top_clk       => i_top_clk_tb,
        i_top_rst_sseg  => i_top_rst_sseg_tb,
        i_top_rst_count => i_top_rst_count_tb,
        i_top_SW_ud     => i_top_SW_ud_tb,
        i_top_SW_speed  => i_top_SW_speed_tb,
        o_top_sseg      => o_top_sseg_tb,
        o_top_anode     => o_top_anode_tb,
        o_top_dp        => o_top_dp_tb
        );

CLOCK_GEN: process  
           begin 
            i_top_clk_tb <= '0';
            wait for clock_period/2; 
            i_top_clk_tb <= '1';
            wait for clock_period/2; 
           end process;
           
TST_CASE_1: process
            begin
                i_top_SW_speed_tb<="11";
                i_top_SW_ud_tb <= '1';
                
                i_top_rst_count_tb<= '1'; 
                wait for clock_period; 
                i_top_rst_count_tb<= '0'; 
                
                i_top_rst_sseg_tb<= '1'; 
                wait for clock_period; 
                i_top_rst_sseg_tb<= '0'; 
                
                wait for 20us;
                
                i_top_SW_speed_tb<="00";
                i_top_SW_ud_tb <= '0';
                wait; 
            end process; 

end Behavioral;
