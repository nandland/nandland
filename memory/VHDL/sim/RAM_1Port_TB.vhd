library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity RAM_1Port_TB is
end RAM_1Port_TB;

architecture test of RAM_1Port_TB is

  constant WIDTH : integer := 8;
  constant DEPTH : integer := 4;

  signal r_Clock   : std_logic := '0';
  signal r_Addr    : unsigned(1 downto 0) := (others => '0');
  signal r_Wr_DV   : std_logic := '0';
  signal r_Wr_Data : unsigned(WIDTH-1 downto 0) := (others => '0');
  signal r_Rd_En   : std_logic := '0';
  signal w_Rd_DV   : std_logic;
  signal w_Rd_Data : std_logic_vector(WIDTH-1 downto 0);

begin

  r_Clock <= not r_Clock after 5 ns;

  UUT : entity work.RAM_1Port
    generic map (
      WIDTH => WIDTH,
      DEPTH => DEPTH)
    port map (
      i_Clk     => r_Clock,
      i_Addr    => std_logic_vector(r_Addr),
      i_Wr_DV   => r_Wr_DV,
      i_Wr_Data => std_logic_vector(r_Wr_Data),
      i_Rd_En   => r_Rd_En,
      o_Rd_DV   => w_Rd_DV,
      o_Rd_Data => w_Rd_Data);
  
  process is
  begin
    wait until r_Clock = '1';
    wait until r_Clock = '1';

    -- Fill memory with incrementing pattern
    for i in 0 to DEPTH-1 loop
      r_Wr_DV <= '1';
      wait until r_Clock = '1';
      r_Wr_Data <= r_Wr_Data + 1;
      r_Addr    <= r_Addr + 1;
    end loop;

    -- Read out incrementing pattern
    r_Addr  <= (others => '0');
    r_Wr_DV <= '0';
    
    for i in 0 to DEPTH-1 loop
      r_Rd_En <= '1';
      wait until r_Clock = '1';
      r_Addr    <= r_Addr + 1;
    end loop;

    r_Rd_En <= '0';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    finish;  -- Need VHDL-2008 for this to work correctly.
  end process;
  
end test;
