-- Russell Merrick - http://www.nandland.com
-- 
-- Testbench for FIFO made from registers. 
-- Demonstrates basic reads/writes working correctly
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity FIFO_Registers_TB is
end FIFO_Registers_TB;
 
architecture behave of FIFO_Registers_TB is
 
  constant c_DEPTH    : integer := 4;
  constant c_WIDTH    : integer := 8;
  constant c_AF_LEVEL : integer := 2;
  constant c_AE_LEVEL : integer := 2;
 
  signal r_Reset   : std_logic := '0';
  signal r_Clock   : std_logic := '0';
  signal r_Wr_En   : std_logic := '0';
  signal r_Wr_Data : std_logic_vector(c_WIDTH-1 downto 0) := X"A5";
  signal w_AF      : std_logic;
  signal w_Full    : std_logic;
  signal r_Rd_En   : std_logic := '0';
  signal w_Rd_Data : std_logic_vector(c_WIDTH-1 downto 0);
  signal w_AE      : std_logic;
  signal w_Empty   : std_logic;
   
begin
 
  FIFO_Registers_Inst : entity work.FIFO_Registers
    generic map (
      WIDTH    => c_WIDTH,
      DEPTH    => c_DEPTH,
      AF_LEVEL => c_AF_LEVEL,
      AE_LEVEL => c_AE_LEVEL
      )
    port map (
      i_Rst_Sync => r_Reset,
      i_Clk      => r_Clock,
      i_Wr_En    => r_Wr_En,
      i_Wr_Data  => r_Wr_Data,
      o_AF       => w_AF,
      o_Full     => w_Full,
      i_Rd_En    => r_Rd_En,
      o_Rd_Data  => w_Rd_Data,
      o_AE       => w_AE,
      o_Empty    => w_Empty
      );
 
  r_Clock <= not r_Clock after 5 ns;
 
  p_TEST : process is
  begin
    wait until r_Clock = '1';
    r_Wr_En <= '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    r_Wr_En <= '0';
    r_Rd_En <= '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    r_Rd_En <= '0';
    r_Wr_En <= '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    r_Rd_En <= '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    r_Wr_En <= '0';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
    wait until r_Clock = '1';
 
  end process;
   
end behave;
