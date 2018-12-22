-------------------------------------------------------------------------------
-- File Downloaded from Nandland.com
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity carry_lookahead_adder_tb is
end carry_lookahead_adder_tb;

architecture behave of carry_lookahead_adder_tb is

  constant c_WIDTH : integer := 3;
  
  signal r_ADD_1  : std_logic_vector(c_WIDTH-1 downto 0) := (others => '0');
  signal r_ADD_2  : std_logic_vector(c_WIDTH-1 downto 0) := (others => '0');
  signal w_RESULT : std_logic_vector(c_WIDTH downto 0);


  component carry_lookahead_adder is
    generic (
      g_WIDTH : natural
      );
    port (
      i_add1   : in  std_logic_vector(g_WIDTH-1 downto 0);
      i_add2   : in  std_logic_vector(g_WIDTH-1 downto 0);
      --
      o_result : out std_logic_vector(g_WIDTH downto 0)
      );
  end component carry_lookahead_adder;
  
begin 

  -- Instantiate the Unit Under Test (UUT)
  UUT : carry_lookahead_adder
    generic map (
      g_WIDTH     => c_WIDTH
      )
    port map (
      i_add1   => r_ADD_1,
      i_add2   => r_ADD_2,
      o_result => w_RESULT
      );

  
  -- Test bench is non-synthesizable
  process is
  begin
    r_ADD_1 <= "000";
    r_ADD_2 <= "001";
    wait for 10 ns;
    r_ADD_1 <= "100";
    r_ADD_2 <= "010";
    wait for 10 ns;
    r_ADD_1 <= "010";
    r_ADD_2 <= "110";
    wait for 10 ns;
    r_ADD_1 <= "111";
    r_ADD_2 <= "111";
    wait for 10 ns;
  end process;
  
end behave;
