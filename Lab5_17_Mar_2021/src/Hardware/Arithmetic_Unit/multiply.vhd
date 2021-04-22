----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2021 07:54:26 AM
-- Design Name: 
-- Module Name: multiply - multiply_arch
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Multiplier circuit using the add-shift method for the arithmetic unit
entity multiply is
  generic (g_WIDTH_MULT: integer := 4);                               -- Parameter to set input bit size
  port (
    i_mult_clk  : in  std_logic;                                      -- Input clock for multipler unit
    i_mult_a    : in  std_logic_vector(g_WIDTH_MULT - 1 downto 0);    -- Input value A
    i_mult_b    : in  std_logic_vector(g_WIDTH_MULT - 1 downto 0);    -- Input value B
    o_mult_prod : out std_logic_vector((g_WIDTH_MULT*2) - 1 downto 0) -- Output product value
    );
end multiply;

architecture multiply_arch of multiply is

  constant final_state: integer := (2*g_WIDTH_MULT) + 1;                                -- Constant that determines max state value
  signal   state      : std_logic_vector(g_WIDTH_MULT - 1 downto 0) := (others => '0'); -- State variable that determines what steps take place
  signal   acc        : std_logic_vector((g_WIDTH_MULT*2) downto 0) := (others => '0'); -- Accumulated value which holds the product and the carry
  signal   temp_a     : std_logic_vector(g_WIDTH_MULT - 1 downto 0) := (others => '0'); -- Temp signal to hold the input of A
  
begin
  -- Process for the multipying circuit
  p_LOGIC:process(i_mult_clk)
  begin
  if(rising_edge(i_mult_clk)) then                                -- Makes this circuit sequential
    if(state = 0) then                                            -- Initial state to start at
      acc(g_WIDTH_MULT*2 downto g_WIDTH_MULT) <= (others => '0'); -- Set upper half to 0
      acc(g_WIDTH_MULT - 1 downto 0) <= i_mult_b;                 -- Set lower half to input B value 
      temp_a <= i_mult_a;                                         -- Set temp with A value, this helps prevent incorrect output if A changes before multiplication is done
      state <= state + 1;                                         -- Increment the state by 1
      
    elsif((state(0) = '1') and (state /= final_state)) then       -- When the state is odd and not at the final stage
      if(acc(0) = '1') then                                       -- If the first bit in the accumulator is 1
        acc(g_WIDTH_MULT*2 downto g_WIDTH_MULT) <= ('0' & acc((2*g_WIDTH_MULT) - 1 downto g_WIDTH_MULT)) + temp_a; --add A with upper half of Acc 
        state <= state + 1;                                       -- Increment state by 1
      else
        acc <= '0' & acc(g_WIDTH_MULT*2 downto 1);                -- If the first Acc bit is 0 shift right by one 
        state <= state + 2;                                       -- Increment state by 2
      end if;

    elsif((state(0) = '0') and (state /= final_state)) then       -- When the state is even and not at final state
      acc <= '0' & acc(g_WIDTH_MULT*2 downto 1);                  -- Shift right by one 
      state <= state + 1;                                         -- Increment state by 1

    elsif (state = final_state) then                              -- If at the final multiplied state
      state <= (others => '0');                                   -- Reset state back to 0
      o_mult_prod <= acc((2*g_WIDTH_MULT) - 1 downto 0);          -- Output the multiplied product value
    end if;
  end if;
  end process;
  
--  constant final_state: integer := (2*g_WIDTH_MULT) + 1;                                -- Constant that determines max state value
--  signal   state      : std_logic_vector(g_WIDTH_MULT - 1 downto 0) := (others => '0'); -- State variable that determines what steps take place
--  signal   next_state : std_logic_vector(g_WIDTH_MULT - 1 downto 0) := (others => '0'); -- State variable that determines what steps take place
--  signal   acc        : std_logic_vector((g_WIDTH_MULT*2) downto 0) := (others => '0'); -- Accumulated value which holds the product and the carry
--  signal   temp_a     : std_logic_vector(g_WIDTH_MULT - 1 downto 0) := (others => '0'); -- Temp signal to hold the input of A
  
  
--begin
  -- Makes this circuit sequential
--  p_SEQ:process(i_mult_clk)
--  begin
--    if(rising_edge(i_mult_clk)) then
--        state <= next_state;
--    end if;
--  end process;
  
--  -- Process for the multipying circuit
--  p_COMB:process(state, acc, i_mult_a, i_mult_b, temp_a)
--  begin
----  if(rising_edge(i_mult_clk)) then                             
--    if(state = 0) then                                            -- Initial state to start at
--      acc(g_WIDTH_MULT*2 downto g_WIDTH_MULT) <= (others => '0'); -- Set upper half to 0
--      acc(g_WIDTH_MULT - 1 downto 0) <= i_mult_b;                 -- Set lower half to input B value 
--      temp_a <= i_mult_a;                                         -- Set temp with A value, this helps prevent incorrect output if A changes before multiplication is done
--      next_state <= state + 1;                               -- Increment the state by 1
      
--    elsif((state(0) = '1') and (state /= final_state)) then       -- When the state is odd and not at the final stage
--      if(acc(0) = '1') then                                       -- If the first bit in the accumulator is 1
--        acc(g_WIDTH_MULT*2 downto g_WIDTH_MULT) <= ('0' & acc((2*g_WIDTH_MULT) - 1 downto g_WIDTH_MULT)) + temp_a; --add A with upper half of Acc 
--        next_state <= state + 1;                             -- Increment state by 1
--      else
--        acc <= '0' & acc(g_WIDTH_MULT*2 downto 1);                -- If the first Acc bit is 0 shift right by one 
--        next_state <= state + 2;                             -- Increment state by 2
--      end if;

--    elsif((state(0) = '0') and (state /= final_state)) then       -- When the state is even and not at final state
--      acc <= '0' & acc(g_WIDTH_MULT*2 downto 1);                  -- Shift right by one 
--      next_state <= state + 1;                               -- Increment state by 1

--    elsif (state = final_state) then                              -- If at the final multiplied state
--      next_state <= (others => '0');                              -- Reset state back to 0
--      o_mult_prod <= acc((2*g_WIDTH_MULT) - 1 downto 0);          -- Output the multiplied product value
--    end if;
----  end if;
--  end process;

end multiply_arch;
