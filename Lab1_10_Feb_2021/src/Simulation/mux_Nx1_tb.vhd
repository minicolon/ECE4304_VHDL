----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/07/2021 01:44:44 PM
-- Design Name: 
-- Module Name: mux_Nx1_tb - tb_arch
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
use IEEE.NUMERIC_STD.ALL;
use STD.textio.all; -- Call in textio library for use of input/output files
use IEEE.STD_LOGIC_TEXTIO.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Testbench for Nx1 mux
entity mux_Nx1_tb is
    generic(WIDTH_TB: integer := 16; SEL_BITS_TB: integer := 4); -- Allows test bench to modify Nx1 mux
--  Port ( );
end mux_Nx1_tb;

architecture tb_arch of mux_Nx1_tb is

component mux_Nx1 is -- Call in Nx1 mux and instantiate it as a component
  generic (WIDTH:integer := 16; SEL_BITS:integer := 4);
  Port (
    Port_Din  : in  std_logic_vector(WIDTH-1 downto 0);
    Port_Sel  : in  std_logic_vector(SEL_BITS-1 downto 0);
    Port_Dout : out std_logic
    );
end component;

--Testbench signals based on component ports
signal Port_Din_tb  : std_logic_vector(WIDTH_TB-1 downto 0);
signal Port_Sel_tb  : std_logic_vector(SEL_BITS_TB-1 downto 0);
signal Port_Dout_tb : std_logic;

-- Testbench clock instantiation
constant clock_period:time:=10 ns; 

-- Variables for files
file file_vectors: text;
file file_results: text;

begin
    MUX_GEN: mux_Nx1 -- Map testbench signals with appropriate mux ports
        generic map(WIDTH => WIDTH_TB, SEL_BITS => SEL_BITS_TB)
        port map(
            Port_Din  => Port_Din_tb,
            Port_Sel  => Port_Sel_tb,
            Port_Dout => Port_Dout_tb
            );

    TESTIO_GEN: process -- Main testbench test code
            -- Variables to aid the flow of reading and writings files respective to mux ports
            variable v_ILINE: line;
            variable v_OLINE: line;
            variable v_PORTDIN: std_logic_vector(WIDTH_TB-1 downto 0);
            variable v_PORTSEL: std_logic_vector(SEL_BITS_TB-1 downto 0);
            variable v_SPACE: character;
            
            begin -- Specify what file to read and write to, and its current location
            file_open(file_vectors, "/home/acolon/Documents/Vivado/ECE4304_VHDL/Lab1_10_Feb_2021/Mux_64x1/Mux_64x1.srcs/sim_1/new/input.txt" , read_mode);
            file_open(file_results, "/home/acolon/Documents/Vivado/ECE4304_VHDL/Lab1_10_Feb_2021/Mux_64x1/Mux_64x1.srcs/sim_1/new/output.txt" , write_mode);
            
            while not endfile(file_vectors) loop -- While loop to run until last line is read
                readline(file_vectors, v_ILINE); -- Read a single line
                hread(v_ILINE, v_PORTDIN); -- Read first hex value on current line
                read(v_ILINE, v_SPACE); -- Read a space on current line
                hread(v_ILINE, v_PORTSEL); -- Read second hex value on current line
                
                --Connect read values to respective testbench signals
                Port_Din_tb <= v_PORTDIN;
                Port_Sel_tb <= v_PORTSEL;
                
                wait for 1*clock_period; -- wait a specified amount of time
                
                write (v_OLINE, Port_Dout_tb); -- begin writing simulated output value
                writeline(file_results, v_OLINE);
                
            end loop;
                -- close files to prevent accidental corruption
                file_close(file_vectors);
                file_close(file_results);
                wait;        
    end process;

end tb_arch;
