----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/05/2021 07:00:41 AM
-- Design Name: 
-- Module Name: mux_2x1 - mux_2x1_arch
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

-- Basic 2x1 mux where 2 bit input is given and output is based on a selector
entity mux_2x1 is
  Port ( -- Port instantiation
    D0  : in std_logic;
    D1  : in std_logic;
    Sel : in std_logic;
    Dout: out std_logic
  );
end mux_2x1;

architecture mux_2x1_arch of mux_2x1 is

begin
  -- Gate level 2x1 MUX instantiation with 2 AND gates, 1 OR gate, and 1 NOT gate
  Dout <= ((not Sel) and D0) or (Sel and D1);

end mux_2x1_arch;
