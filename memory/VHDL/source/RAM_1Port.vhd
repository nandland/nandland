-- Russell Merrick - http:--www.nandland.com
--
-- Creates a Single Port RAM. (Random Access Memory)
-- Single port RAM has one port, so can only access one memory location at a time.
-- Dual port RAM can read and write to different memory locations at the same time.
--
-- WIDTH sets the width of the Memory created.
-- DEPTH sets the depth of the Memory created.
-- Likely tools will infer Block RAM if WIDTH/DEPTH is large enough.
-- If small, tools will infer register-based memory.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM_1Port is
  generic (
    WIDTH : integer := 16;
    DEPTH : integer := 256
    );
  port (
    i_Clk     : in  std_logic;
    -- Shared address for reads and writes
    i_Addr    : in  std_logic_vector; -- Gets sized at higher level
    -- Write Interface
    i_Wr_DV   : in  std_logic;
    i_Wr_Data : in  std_logic_vector(WIDTH-1 downto 0);
    -- Read Interface
    i_Rd_En   : in  std_logic;
    o_Rd_DV   : out std_logic;
    o_Rd_Data : out std_logic_vector(WIDTH-1 downto 0)
    );
end RAM_1Port;

architecture RTL of RAM_1Port is

  -- Create Memory that is DEPTH x WIDTH
  type t_Mem is array (0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);
  signal r_Mem : t_Mem;

begin

  process (i_Clk)
  begin
    if rising_edge(i_Clk) then
      -- Handle writes to memory
      if i_Wr_DV = '1' then
        r_Mem(to_integer(unsigned(i_Addr))) <= i_Wr_Data;
      end if;

      -- Handle reads from memory
      o_Rd_Data <= r_Mem(to_integer(unsigned(i_Addr)));
      o_Rd_DV   <= i_Rd_En; -- Generate DV pulse
    end if;
  end process;

end RTL;
