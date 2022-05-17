-- Russell Merrick - http://www.nandland.com
--
-- Creates a Dual (2) Port RAM (Random Access Memory)
-- Single port RAM has one port, so can only access one memory location at a time.
-- Dual port RAM can read and write to different memory locations at the same time.
-- 
-- Generic: WIDTH sets the width of the Memory created.
-- Generic: DEPTH sets the depth of the Memory created.
-- Likely tools will infer Block RAM if WIDTH/DEPTH is large enough.
-- If small, tools will infer register-based memory.
-- 
-- Can be used in two different clock domains, or can tie i_Wr_Clk 
-- and i_Rd_Clk to same clock for operation in a single clock domain.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM_2Port is
  generic (
    WIDTH : integer := 16;
    DEPTH : integer := 256
    );
  port (
    -- Write signals
    i_Wr_Clk  : in  std_logic;
    i_Wr_Addr : in  std_logic_vector; -- Gets sized at higher level
    i_Wr_DV   : in  std_logic;
    i_Wr_Data : in  std_logic_vector(WIDTH-1 downto 0);
    -- Read signals
    i_Rd_Clk  : in  std_logic;
    i_Rd_Addr : in  std_logic_vector; -- Gets sized at higher level
    i_Rd_En   : in  std_logic;
    o_Rd_DV   : out std_logic;
    o_Rd_Data : out std_logic_vector(WIDTH-1 downto 0)
    );
end RAM_2Port;

architecture RTL of RAM_2Port is

  -- Create Memory that is DEPTH x WIDTH
  type t_Mem is array (0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);
  signal r_Mem : t_Mem;

begin

  -- Purpose: Control Writes to Memory.
  process (i_Wr_Clk)
  begin
    if rising_edge(i_Wr_Clk) then
      if i_Wr_DV = '1' then
        r_Mem(to_integer(unsigned(i_Wr_Addr))) <= i_Wr_Data;
      end if;
    end if;
  end process;

  -- Purpose: Control Reads From Memory.
  process (i_Rd_Clk)
  begin
    if rising_edge(i_Rd_Clk) then
      o_Rd_Data <= r_Mem(to_integer(unsigned(i_Rd_Addr)));
      o_Rd_DV   <= i_Rd_En;
    end if;
  end process;

end RTL;
