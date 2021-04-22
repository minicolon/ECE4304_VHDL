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
    generic (g_WIDTH_DECODER: integer := 3);
    Port(
        i_Din_gen : in  std_logic_vector(g_WIDTH_DECODER - 1 downto 0);   -- Input the data based on the generic parameter
        o_Dout_gen: out std_logic_vector(2**g_WIDTH_DECODER - 1 downto 0) -- Output the new decoded data
        );
end generic_decoder;

architecture g_decoder_arch of generic_decoder is

-- Add in desired base component with respective ports
component decoder_2x4 is
    Port(
        i_En  : in   std_logic;                    -- Input enable bit
        i_Din : in   std_logic_vector(1 downto 0); -- Input data 
        o_Dout: out  std_logic_vector(3 downto 0)  -- Output decoded data
        );
end component;

-- Temporary constant that determines the total output bits based on input width
constant total_out: integer := 2**g_WIDTH_DECODER;

-- Create an array of arrays (2D array) for the 2x4 deocder enables
type En_type is array (0 to (g_WIDTH_DECODER/2)) of std_logic_vector((2**g_WIDTH_DECODER)-1 downto 0);
signal temp_En: En_type;

begin
    -- Generates decoders from output (first stage) to input (last stage)
    GEN_STAGES: for i in 0 to g_WIDTH_DECODER/2-1 generate -- Determines how many stages are required 
        GEN_DECODERS: for k in 0 to total_out/(4**(i+1)) - 1  generate -- Each stage decrements the decoders by a factor of 4
            BASE_DECODER: decoder_2x4 port map(
                i_En   => temp_En(i+1)(k),
                i_Din  => i_Din_gen((2*i)+1 downto 2*i),
                o_Dout => temp_En(i)((4*k)+3 downto 4*k)
                );
        end generate;
        
        -- When the input bit amount is odd (3, 5, etc.), assign the MSB of Din to the enable of the final 2 decoders
        IN_ODD_BITS: if (g_WIDTH_DECODER mod 2 = 1) and (i = g_WIDTH_DECODER/2-1) generate
            temp_En(i+1)(total_out/(4**(i+1)) - 2) <= not i_Din_gen(g_WIDTH_DECODER - 1);
            temp_En(i+1)(total_out/(4**(i+1)) - 1) <= i_Din_gen(g_WIDTH_DECODER - 1);        
        end generate;
        
        -- When the input amount is even (4, 6, etc.), all bits from Din are used so assign final enable to high        
        IN_EVEN_BITS: if (g_WIDTH_DECODER mod 2 = 0) and (i = g_WIDTH_DECODER/2-1) generate
            temp_En(i+1)(total_out/(4**(i+1)) - 1) <= '1';        
        end generate; 
    end generate;
    
    -- Assign the output to the temp output generated in the first stage
    o_Dout_gen <= temp_En(0)(total_out - 1 downto 0);
    
end g_decoder_arch;
