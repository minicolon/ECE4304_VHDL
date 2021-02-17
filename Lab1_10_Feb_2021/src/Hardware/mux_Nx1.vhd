----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/05/2021 07:00:41 AM
-- Design Name: 
-- Module Name: mux_Nx1 - mux_Nx1_arch
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Top file for standard mux with N-bit inputs and a single output 
entity mux_Nx1 is
  generic (WIDTH:integer := 16; SEL_BITS:integer := 4); --WIDTH is size of input bits, SEL_BITS is bits needed to select from 0 to N bit
  Port ( -- Port instantiation
    Port_Din  : in  std_logic_vector(WIDTH-1 downto 0);
    Port_Sel  : in  std_logic_vector(SEL_BITS-1 downto 0);
    Port_Dout : out std_logic
    );
end mux_Nx1;

architecture mux_Nx1_arch of mux_Nx1 is

-- Call in 2x1 mux as a component to create network of muxes
component mux_2x1 is
  Port (
    D0   : in  std_logic;
    D1   : in  std_logic;
    Sel  : in  std_logic;
    Dout : out std_logic
    );
end component;

-- signal which acts as intermediate for the output of each 2x1 mux
signal temp_Dout : std_logic_vector(WIDTH - 2 downto 0);

begin    
    GEN_MUX_LEVELS: for i in 0 to SEL_BITS-1 generate -- i is the current "level", which is the current select bit while appropriate muxes are generated
        MUX_PER_LEVEL: for j in WIDTH - 2**(SEL_BITS - i) to WIDTH - 2**(SEL_BITS - i - 1) - 1 generate -- Generates appropriate muxes based on current level in relation to N-bit input
           
           FIRST_LEVEL_MUX: if (i = 0) generate -- First created level varies from all subsequent levels
               GEN_FIRST: mux_2x1 port map( -- Requires inputs from Din port and begins to generate temporary output connections
               D0   => Port_Din(2*j),
               D1   => Port_Din(2*j + 1),
               Sel  => Port_Sel(i),
               Dout => temp_Dout(j)
               );
           end generate;
           
           REMAINING_LEVELS: if ((i /= 0)) generate -- Creates Remaining muxes after the first level
               GEN_REMAINING: mux_2x1 port map( -- Takes in previous temp output and wires it to current input
               D0   => temp_Dout(2*j - WIDTH), 
               D1   => temp_Dout(2*j - WIDTH + 1),
               Sel  => Port_Sel(i),
               Dout => temp_Dout(j)
               );
	       end generate;
        end generate;
    end generate;
    
    Port_Dout <= temp_Dout(WIDTH - 2); -- final intermediate output is connected to port output
  
end mux_Nx1_arch;
