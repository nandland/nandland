-------------------------------------------------------------------------------
-- File Downloaded from Nandland.com
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity carry_lookahead_adder_4_bit is
  port (
    i_add1  : in std_logic_vector(3 downto 0);
    i_add2  : in std_logic_vector(3 downto 0);
    --
    o_result   : out std_logic_vector(4 downto 0)
    );
end carry_lookahead_adder_4_bit;


architecture rtl of carry_lookahead_adder_4_bit is

  component module_full_adder is
    port (
      i_bit1  : in  std_logic;
      i_bit2  : in  std_logic;
      i_carry : in  std_logic;
      o_sum   : out std_logic;
      o_carry : out std_logic);
  end component module_full_adder;

  signal w_G : std_logic_vector(3 downto 0); -- Generate
  signal w_P : std_logic_vector(3 downto 0); -- Propagate
  signal w_C : std_logic_vector(4 downto 0); -- Carry

  signal w_SUM   : std_logic_vector(3 downto 0);

  
begin 
  
  FULL_ADDER_BIT_0 : module_full_adder
    port map (
      i_bit1  => i_add1(0),
      i_bit2  => i_add2(0),
      i_carry => w_C(0),
      o_sum   => w_SUM(0),
      o_carry => open
      );

  FULL_ADDER_BIT_1 : module_full_adder
    port map (
      i_bit1  => i_add1(1),
      i_bit2  => i_add2(1),
      i_carry => w_C(1),
      o_sum   => w_SUM(1),
      o_carry => open
      );

  FULL_ADDER_BIT_2 : module_full_adder
    port map (
      i_bit1  => i_add1(2),
      i_bit2  => i_add2(2),
      i_carry => w_C(2),
      o_sum   => w_SUM(2),
      o_carry => open
      );
  
  FULL_ADDER_BIT_3 : module_full_adder
    port map (
      i_bit1  => i_add1(3),
      i_bit2  => i_add2(3),
      i_carry => w_C(3),
      o_sum   => w_SUM(3),
      o_carry => open
      );

  -- Create the Generate (G) Terms:  Gi=Ai*Bi
  w_G(0) <= i_add1(0) and i_add2(0);
  w_G(1) <= i_add1(1) and i_add2(1);
  w_G(2) <= i_add1(2) and i_add2(2);
  w_G(3) <= i_add1(3) and i_add2(3);

  -- Create the Propagate Terms: Pi=Ai+Bi
  w_P(0) <= i_add1(0) or i_add2(0);
  w_P(1) <= i_add1(1) or i_add2(1);
  w_P(2) <= i_add1(2) or i_add2(2);
  w_P(3) <= i_add1(3) or i_add2(3);

  -- Create the Carry Terms:
  w_C(0) <= '0'; -- no carry input
  w_C(1) <= w_G(0) or (w_P(0) and w_C(0));
  w_C(2) <= w_G(1) or (w_P(1) and w_C(1));
  w_C(3) <= w_G(2) or (w_P(2) and w_C(2));
  w_C(4) <= w_G(3) or (w_P(3) and w_C(3));

  -- Final Answer
  o_result <= w_C(4) & w_SUM;  -- VHDL Concatenation
  
end rtl;
