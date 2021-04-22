----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2021 02:54:57 PM
-- Design Name: 
-- Module Name: Barrel_Shifter_texio_tb - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.math_real."log2";
use IEEE.math_real."ceil";
use IEEE.std_logic_arith.all;
use STD.textio.all; -- Call in textio library for use of input/output files
use IEEE.STD_LOGIC_TEXTIO.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Barrel_Shifter_texio_tb is
  generic(g_WIDTH_TB: integer := 8);
--  Port ( );
end Barrel_Shifter_texio_tb;

architecture Behavioral of Barrel_Shifter_texio_tb is

component barrel_shifter is
  generic (g_WIDTH_BS: integer := 8);
  port (
    i_barrel_lr    : in  std_logic;
    i_barrel_value : in  std_logic_vector(g_WIDTH_BS - 1 downto 0);
    i_barrel_shift : in  std_logic_vector(integer(ceil(log2(real(g_WIDTH_BS)))) - 1 downto 0);
    o_barrel_new   : out std_logic_vector(g_WIDTH_BS - 1 downto 0)
    );
end component;

signal i_barrel_lr_tb    : std_logic;
signal i_barrel_value_tb : std_logic_vector(g_WIDTH_TB - 1 downto 0);
signal i_barrel_shift_tb : std_logic_vector(integer(ceil(log2(real(g_WIDTH_TB)))) - 1 downto 0);
signal o_barrel_new_tb   : std_logic_vector(g_WIDTH_TB - 1 downto 0);

constant time_step: time := 10 ns;

-- Variables for files
file file_vectors: text;
file file_results: text;

begin
  BS_COMP: barrel_shifter
    generic map(g_WIDTH_BS => g_WIDTH_TB)
    port map(
      i_barrel_lr    => i_barrel_lr_tb,
      i_barrel_value => i_barrel_value_tb,
      i_barrel_shift => i_barrel_shift_tb,
      o_barrel_new   => o_barrel_new_tb
      );

    TESTIO_GEN: process -- Main testbench test code
            -- Variables to aid the flow of reading and writings files respective to mux ports
            variable v_ILINE: line;
            variable v_OLINE: line;
            variable v_PORTSHIFT: std_logic_vector(integer(ceil(log2(real(g_WIDTH_TB)))) - 1 downto 0);
            variable v_PORTVAL: std_logic_vector(g_WIDTH_TB - 1 downto 0);
            variable v_PORTLR: std_logic;
            variable v_SPACE: character;
            
            begin -- Specify what file to read and write to, and its current location
            file_open(file_vectors, "S:\School Files\ECE4304_VHDL\Lab6_Files\src\Simulation\input.txt" , read_mode);
            file_open(file_results, "S:\School Files\ECE4304_VHDL\Lab6_Files\src\Simulation\output.txt" , write_mode);
            
            while not endfile(file_vectors) loop -- While loop to run until last line is read
                readline(file_vectors, v_ILINE); -- Read a single line
                hread(v_ILINE, v_PORTSHIFT); -- Read first hex value on current line
                read(v_ILINE, v_SPACE); -- Read a space on current line
                hread(v_ILINE, v_PORTVAL); -- Read second hex value on current line
                read(v_ILINE, v_SPACE); -- Read a space on current line
                read(v_ILINE, v_PORTLR); -- Read second hex value on current line
                
                --Connect read values to respective testbench signals
                i_barrel_shift_tb <= v_PORTSHIFT;
                i_barrel_value_tb <= v_PORTVAL;
                i_barrel_lr_tb    <= v_PORTLR;
                
                wait for 1*time_step; -- wait a specified amount of time
                
                write (v_OLINE, o_barrel_new_tb); -- begin writing simulated output value
                writeline(file_results, v_OLINE);
                
            end loop;
                -- close files to prevent accidental corruption
                file_close(file_vectors);
                file_close(file_results);
                wait;        
    end process;


end Behavioral;
