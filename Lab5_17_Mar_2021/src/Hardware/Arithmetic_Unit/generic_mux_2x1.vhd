----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2021 05:51:24 AM
-- Design Name: 
-- Module Name: generic_mux_2x1 - g_mux_arch
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Basic 2x1 mux with 2 N-bit inputs and a single N-bit output
entity generic_mux_2x1 is
    generic(g_WIDTH_DATA: integer := 16);
    Port( -- Port instantiation
        i_mux_sel   : in  std_logic;                                   -- Input single select bit
        i_mux_data_0: in  std_logic_vector(g_WIDTH_DATA - 1 downto 0); -- Input first data set
        i_mux_data_1: in  std_logic_vector(g_WIDTH_DATA - 1 downto 0); -- Input second data set
        o_mux_data  : out std_logic_vector(g_WIDTH_DATA - 1 downto 0)  -- Output selected data
        );
end generic_mux_2x1;

architecture mux_2x1_arch of generic_mux_2x1 is

begin
    p_MUX: process (i_mux_sel, i_mux_data_0, i_mux_data_1) is -- List ports that will trigger the process
    begin
    if (i_mux_sel = '1') then -- When the input select is high the upper input is assigned to the output
        o_mux_data <= i_mux_data_1;
    else -- When select is low, the lower input is assigned to the output
        o_mux_data <= i_mux_data_0;
    end if;
    end process;

end mux_2x1_arch;
