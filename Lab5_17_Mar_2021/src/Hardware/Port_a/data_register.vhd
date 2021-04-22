----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2021 12:06:29 PM
-- Design Name: 
-- Module Name: data_register - data_reg_arch
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Data register that breaks up combinational logic
entity data_register is
  generic (g_WIDTH_REG: integer := 4);
  port (
    i_reg_clk  : in std_logic;                                   -- Input clock for the reg
    i_reg_data : in  std_logic_vector(g_WIDTH_REG - 1 downto 0); -- Input data for the reg
    o_reg_data : out std_logic_vector(g_WIDTH_REG - 1 downto 0)  -- Output data of the reg
    );
end data_register;

architecture data_reg_arch of data_register is

begin
  -- Register process
  p_REG: process(i_reg_clk)
    variable v_temp_data: std_logic_vector(g_WIDTH_REG - 1 downto 0); -- Variable to hold the data before sending it to the output
  begin
    if(rising_edge(i_reg_clk)) then -- Create the register to wait on a clock
      v_temp_data := i_reg_data;
    end if;
    
    o_reg_data <= v_temp_data; -- Output the register's data
  end process;

end data_reg_arch;
