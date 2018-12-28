-- This module is used to debounce a number of switches or buttons.
-- All share DEBOUNCE_LIMIT.  
--
-- Set the DEBOUNCE_LIMIT in i_Clk clock ticks to ensure signal is steady.

library ieee;
use ieee.std_logic_1164.all;

entity Debounce_Multi_Input is
  generic (
    NUM_INPUTS     : integer := 2;
    DEBOUNCE_LIMIT : integer := 250000;
    );
  port (
    i_Clk      : in  std_logic;
    i_Switches : in  std_logic_vector(NUM_INPUTS-1 downto 0);
    o_Switches : out std_logic_vector(NUM_INPUTS-1 downto 0)
    );
end entity Debounce_Multi_Input;

architecture RTL of Debounce_Multi_Input is

  component Debounce_Single_Input is
    generic (
      DEBOUNCE_LIMIT : integer);
    port (
      i_Clk    : in  std_logic;
      i_Switch : in  std_logic;
      o_Switch : out std_logic);
  end component Debounce_Single_Input;
  
begin
  
  Output_Assignment: for jj in 0 to NUM_INPUTS-1 generate
    Debounce_Single_Input_1: Debounce_Single_Input
      generic map (
        DEBOUNCE_LIMIT => DEBOUNCE_LIMIT)
      port map (
        i_Clk    => i_Clk,
        i_Switch => i_Switches(jj),
        o_Switch => o_Switches(jj)
        );
  end generate Output_Assignment;

end architecture RTL;
