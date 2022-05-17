-- Russell Merrick - http:--www.nandland.com
--
-- FIFO testbench.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity FIFO_TB is 
end entity FIFO_TB;

architecture test of FIFO_TB is

  constant DEPTH     : integer := 4;
  constant WIDTH     : integer := 8;

  signal r_Clk, r_Rst_L : std_logic := '0';
  signal r_Wr_DV, r_Rd_En : std_logic := '0';
  signal r_Wr_Data : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal r_AF_Level : integer := DEPTH-1;
  signal r_AE_Level : integer := 1;
  signal w_AF_Flag, w_AE_Flag, w_Full, w_Empty, w_Rd_DV : std_logic;
  signal w_Rd_Data : std_logic_vector(WIDTH-1 downto 0);
 
  -- This procedure triggers a reset condition to the FIFO.
  procedure reset_fifo (
    signal r_Rst_L : out std_logic;
    signal r_Wr_DV : out std_logic;
    signal r_Rd_En : out std_logic) is
  begin
    wait until rising_edge(r_Clk);
    r_Rst_L <= '0';
    r_Wr_DV <= '0';  -- ensure rd/wr are off
    r_Rd_En <= '0';
    wait until rising_edge(r_Clk);
    r_Rst_L <= '1';
    wait until rising_edge(r_Clk);
    wait until rising_edge(r_Clk);
  end procedure;

begin

  r_Clk <= not r_Clk after 10 ns;

  UUT : entity work.FIFO
  generic map(
    WIDTH     => WIDTH,
    DEPTH     => DEPTH)
  port map (
    i_Rst_L => r_Rst_L,
    i_Clk   => r_Clk,
    -- Write Side
    i_Wr_DV    => r_Wr_DV,
    i_Wr_Data  => r_Wr_Data,
    i_AF_Level => r_AF_Level,
    o_AF_Flag  => w_AF_Flag,
    o_Full     => w_Full,
    -- Read Side
    i_Rd_En    => r_Rd_En,
    o_Rd_DV    => w_Rd_DV,
    o_Rd_Data  => w_Rd_Data,
    i_AE_Level => r_AE_Level,
    o_AE_Flag  => w_AE_Flag,
    o_Empty    => w_Empty
    );

  process is
  begin
    reset_fifo(r_Rst_L, r_Wr_DV, r_Rd_En);

    -- Write single word, ensure it appears on output
    r_Wr_DV   <= '1';
    r_Wr_Data <= X"AB";
    wait until rising_edge(r_Clk);
    r_Wr_DV   <= '0';
    wait until rising_edge(r_Clk);
    assert not w_Empty;

    wait until rising_edge(r_Clk);
    wait until rising_edge(r_Clk);
    wait until rising_edge(r_Clk);
    wait until rising_edge(r_Clk);

    -- Read out that word, ensure DV and empty is correct
    r_Rd_En <= '1';
    wait until rising_edge(r_Clk);
    r_Rd_En <= '0';
    wait until rising_edge(r_Clk);
    assert w_Rd_DV;
    assert w_Empty;
    assert w_Rd_Data = X"AB";

    -- Test: Fill FIFO with incrementing pattern, then read it back.
    reset_fifo(r_Rst_L, r_Wr_DV, r_Rd_En);
    r_Wr_Data <= X"30";
    for ii in 0 to DEPTH-1 loop
      r_Wr_DV <= '1';
      wait until rising_edge(r_Clk);
      r_Wr_DV <= '0';
      wait until rising_edge(r_Clk);
      r_Wr_Data <= std_logic_vector(unsigned(r_Wr_Data) + 1);
    end loop;
    r_Wr_DV <= '0';
    wait until rising_edge(r_Clk);
    assert w_Full;
    wait until rising_edge(r_Clk);

    -- Read out and verify incrementing pattern
    for i in 48 to 48 + DEPTH-1 loop
      r_Rd_En <= '1';
      wait until rising_edge(r_Clk);
      r_Rd_En <= '0';
      wait until rising_edge(r_Clk);
      assert w_Rd_DV report "DV not high" severity note;
      assert (w_Rd_Data = std_logic_vector(to_unsigned(i, w_Rd_Data'length))) report "Exp: " & integer'image(i) & " Act: " & integer'image(to_integer(unsigned(w_Rd_Data))) severity note;
      wait until rising_edge(r_Clk);
    end loop;
    assert w_Empty;

    -- Test: Read and write on same clock cycle when empty + full
    reset_fifo(r_Rst_L, r_Wr_DV, r_Rd_En);
    r_Rd_En <= '1';
    r_Wr_DV <= '1';
    wait until rising_edge(r_Clk);
    wait until rising_edge(r_Clk);
    r_Rd_En <= '0';
    wait until rising_edge(r_Clk);
    wait until rising_edge(r_Clk);
    wait until rising_edge(r_Clk);
    wait until rising_edge(r_Clk);
    assert w_Full;
    r_Rd_En <= '1';
    wait until rising_edge(r_Clk);
    assert w_Full;
    wait until rising_edge(r_Clk);
    assert w_Full;
    r_Wr_DV <= '0';
    r_Rd_En <= '0';

    -- Test: Almost Empty, Almost Full Flags
    -- AE is set to 1, AF is set to 3
    reset_fifo(r_Rst_L, r_Wr_DV, r_Rd_En);
    assert w_AE_Flag;
    assert not w_AF_Flag;
    
    r_Wr_DV <= '1';
    wait until rising_edge(r_Clk);
    assert w_AE_Flag;
    assert not w_AF_Flag;
    wait until rising_edge(r_Clk);
    assert not w_AE_Flag;
    assert not w_AF_Flag;
    wait until rising_edge(r_Clk);
    assert not w_AE_Flag;
    assert w_AF_Flag;
    wait until rising_edge(r_Clk);
    assert not w_AE_Flag;
    assert w_AF_Flag;
    assert w_Full;  
    
    finish; -- need VHDL-2008
  end process;

end test;
