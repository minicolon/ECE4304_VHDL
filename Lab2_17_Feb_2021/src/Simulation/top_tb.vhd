----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2021 12:39:27 PM
-- Design Name: 
-- Module Name: top_tb - Behavioral
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
use STD.textio.all; -- Call in textio library for use of input/output files
use IEEE.STD_LOGIC_TEXTIO.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Testbench to make sure top file is works correctly
entity top_tb is
    generic(g_WIDTH_tb: integer := 5);
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is

-- Component instantiation
component top is
    generic(g_WIDTH_top: integer := 5);
    Port( 
        i_Sel_top : in  std_logic;
        i_Din_top : in  std_logic_vector(g_WIDTH_top - 1 downto 0);
        o_Dout_top: out std_logic_vector(2**(g_WIDTH_top - 1) - 1 downto 0)
        );
end component;

-- Create custom testbench signals
signal i_Sel_tb : std_logic;
signal i_Din_tb : std_logic_vector(g_WIDTH_tb - 1 downto 0);
signal o_Dout_tb: std_logic_vector(2**(g_WIDTH_tb - 1) - 1 downto 0);

-- Generate a clock period that simulates 100MHz
constant clock_period:time := 10 ns;

-- Variables for files
file file_vectors: text;
file file_results: text;

begin

    TOP_COMP: top -- Map the testbench signals with the component ports
        generic map(g_WIDTH_top => g_WIDTH_tb)
        port map(
            i_Sel_top  => i_Sel_tb,
            i_Din_top  => i_Din_tb,
            o_Dout_top => o_Dout_tb
            );
    
    TEXTIO_TEST: process -- Main testbench test code
        -- Variables to aid the flow of reading and writings files respective to top file ports
        variable v_ILINE: line;
        variable v_OLINE: line;
        variable v_DIN: std_logic_vector(g_WIDTH_tb-1 downto 0);
        variable v_SEL: std_logic;
        variable v_SPACE: character;
            
        begin -- Specify what file to read and write to, and its current location
        file_open(file_vectors, "S:\School Files\ECE4304_VHDL\Lab2_Files\src\Simulation\input.txt" , read_mode);
        file_open(file_results, "S:\School Files\ECE4304_VHDL\Lab2_Files\src\Simulation\output.txt" , write_mode);
            
        while not endfile(file_vectors) loop -- While loop to run until last line is read
            readline(file_vectors, v_ILINE); -- Read a single line
            hread(v_ILINE, v_DIN); -- Read first hex value on current line
            read(v_ILINE, v_SPACE); -- Read a space on current line
            read(v_ILINE, v_SEL); -- Read second value on current line
                
            --Connect read values to respective testbench signals
            i_Din_tb <= v_DIN;
            i_Sel_tb <= v_SEL;
                
            wait for 1*clock_period; -- wait a specified amount of time
                
            write (v_OLINE, o_Dout_tb); -- begin writing simulated output value
            writeline(file_results, v_OLINE);
                
        end loop;
        
        -- close files to prevent accidental corruption
        file_close(file_vectors);
        file_close(file_results);
        wait;        
    end process;

end Behavioral;
