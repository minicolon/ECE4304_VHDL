----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2021 08:47:03 AM
-- Design Name: 
-- Module Name: generic_decoder - g_decoder_arch
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

--Create a generic Nx2**N decoder network from the base 2x4 decoder
entity generic_decoder is
    generic (g_WIDTH: integer := 5);
    Port (-- Port instantiation
        i_Din_gen : in  std_logic_vector(g_WIDTH - 1 downto 0);
        o_Dout_gen: out std_logic_vector(2**g_WIDTH - 1 downto 0)
    );
end generic_decoder;

architecture g_decoder_arch of generic_decoder is

-- Add in desired base component with respective ports
component decoder_2x4 is
    Port (
        i_En  : in   std_logic;
        i_Din : in   std_logic_vector(1 downto 0);
        o_Dout: out  std_logic_vector(3 downto 0)
        );
end component;

-- Temporary constant that determines the total output bits based on input width
constant total_out: integer := 2**g_WIDTH;

-- Create an array of arrays (2D array) for the 2x4 deocder enables
type En_type is array (0 to (g_WIDTH/2)-1) of std_logic_vector((2**g_WIDTH)-1 downto 0);
signal temp_En: En_type;

-- Temp signal to tie the first stage to the output port
signal temp_Dout: std_logic_vector(total_out - 1 downto 0);

begin
    -- Generates decoders from output (first stage) to input (last stage)
    GEN_STAGES: for i in 0 to g_WIDTH/2-1 generate -- Determines how many stages are required 
        GEN_DECODERS: for k in 0 to total_out/(4**(i+1)) - 1  generate -- Each stage decrements the decoders by a factor of 4
            FIRST_STAGE: if (i = 0) generate -- When i is 0 create the first stage
                BASE_DECODER: decoder_2x4 port map(
                    i_En   => temp_En(i)(k),
                    i_Din  => i_Din_gen((2*i)+1 downto 2*i),
                    o_Dout => temp_Dout((4*k)+3 downto 4*k)
                    );
            end generate; 
            REMAINING_STAGES: if (i /= 0) generate -- When i is not 0, map the output to the previous enable pins
                BASE_DECODER: decoder_2x4 port map(
                    i_En   => temp_En(i)(k),
                    i_Din  => i_Din_gen((2*i)+1 downto 2*i),
                    o_Dout => temp_En(i-1)((4*k)+3 downto 4*k)
                    );
            end generate;                     
        end generate;
        
        -- When the input bit amount is odd (3, 5, etc.), assign the MSB of Din to the enable of the final 2 decoders
        IN_ODD_BITS: if (g_WIDTH mod 2 = 1) and (i = g_WIDTH/2-1) generate
            temp_En(i)(total_out/(4**(i+1)) - 2) <= not i_Din_gen(g_WIDTH - 1);
            temp_En(i)(total_out/(4**(i+1)) - 1) <= i_Din_gen(g_WIDTH - 1);        
        end generate;
        
        -- When the input amount is even (4, 6, etc.), all bits from Din are used so assign final enable to high        
        IN_EVEN_BITS: if (g_WIDTH mod 2 = 0) and (i = g_WIDTH/2-1) generate
            temp_En(i)(total_out/(4**(i+1)) - 1) <= '1';        
        end generate; 
    end generate;
    
    -- Assign the output to the temp output generated in the first stage
    o_Dout_gen <= temp_Dout;
    
end g_decoder_arch;
