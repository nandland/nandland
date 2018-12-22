library ieee;
use ieee.std_logic_1164.all;

entity Binary_to_BCD_TB is
end entity Binary_to_BCD_TB;

architecture behave of Binary_to_BCD_TB is

  signal r_Clock  : std_logic                    := '0';
  signal r_Start  : std_logic                    := '0';
  signal r_Binary : std_logic_vector(7 downto 0) := (others => '0');
  signal w_BCD    : std_logic_vector(7 downto 0);
  signal w_DV     : std_logic;

  component Binary_to_BCD is
    generic (
      g_INPUT_WIDTH    : in positive;
      g_DECIMAL_DIGITS : in positive
      );
    port (
      i_Clock  : in std_logic;
      i_Start  : in std_logic;
      i_Binary : in std_logic_vector(g_INPUT_WIDTH-1 downto 0);

      o_BCD : out std_logic_vector(g_DECIMAL_DIGITS*4-1 downto 0);
      o_DV  : out std_logic
      );
  end component Binary_to_BCD;

  
begin

  Binary_to_BCD_inst : Binary_to_BCD
    generic map (
      g_INPUT_WIDTH    => 8,
      g_DECIMAL_DIGITS => 2
      )
    port map (
      i_Clock  => r_Clock,
      i_Start  => r_Start,
      i_Binary => r_Binary,
      o_BCD    => w_BCD,
      o_DV     => w_DV
      );

  r_Clock <= not r_Clock after 5 ns;

  process is
  begin
    wait for 20 ns;
    r_Start  <= '1';
    r_Binary <= X"0C";
    wait for 20 ns;    
    r_Start  <= '0';
    wait for 1000 ns;
  end process;

  
end architecture behave;

