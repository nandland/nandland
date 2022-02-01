-- Russell Merrick - http://www.nandland.com
--
-- Creates a Synchronous FIFO made out of registers (flip-flops)
-- Generic: WIDTH sets the width of the FIFO created.
-- Generic: DEPTH sets the depth of the FIFO created.
-- Generic: AF_LEVEL o_AF goes high when # words in FIFO is > this number.
-- Generic: AE_LEVEL o_AE goes high when # words in FIFO is < this number.
--
-- Total FIFO register usage will be width * depth
-- Recommended to keep WIDTH/DEPTH low to prevent high reg utilization
-- Note that this fifo should not be used to cross clock domains.
-- (Read and write clocks NEED TO BE the same clock domain)
--
-- FIFO Full Flag will assert as soon as last word is written.
-- FIFO Empty Flag will assert as soon as last word is read.
-- Almost Full/Empty flags can be used for more FIFO control. 
-- If user does not need Almost Full and Almost Empty flags,
-- can just leave these outputs unconnected.
--
-- FIFO is 100% synthesizable.  It uses assert statements which do
-- not synthesize, but will cause your simulation to crash if you
-- are doing something you shouldn't be doing (reading from an
-- empty FIFO or writing to a full FIFO).
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity FIFO_Registers is
  generic (
    WIDTH    : natural := 8;
    DEPTH    : integer := 32;
    AF_LEVEL : integer := 28;
    AE_LEVEL : integer := 4
    );
  port (
    i_Rst_Sync : in std_logic;
    i_Clk      : in std_logic;
 
    -- FIFO Write Interface
    i_Wr_En   : in  std_logic;
    i_Wr_Data : in  std_logic_vector(WIDTH-1 downto 0);
    o_AF      : out std_logic;
    o_Full    : out std_logic;
 
    -- FIFO Read Interface
    i_Rd_En   : in  std_logic;
    o_Rd_Data : out std_logic_vector(WIDTH-1 downto 0);
    o_AE      : out std_logic;
    o_Empty   : out std_logic
    );
end FIFO_Registers;
 
architecture RTL of FIFO_Registers is
 
  type t_FIFO_DATA is array (0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);
  signal r_FIFO_Data : t_FIFO_DATA := (others => (others => '0'));
 
  signal r_Wr_Index   : integer range 0 to DEPTH-1 := 0;
  signal r_Rd_Index   : integer range 0 to DEPTH-1 := 0;
 
  -- # Words in FIFO, has extra range to allow for assert conditions
  signal r_FIFO_Count : integer range -1 to DEPTH+1 := 0;
 
  signal w_Full  : std_logic;
  signal w_Empty : std_logic;
   
begin
 
  p_CONTROL : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      if i_Rst_Sync = '1' then
        r_FIFO_Count <= 0;
        r_Wr_Index   <= 0;
        r_Rd_Index   <= 0;
      else
 
        -- Keeps track of the total number of words in the FIFO
        if (i_Wr_En = '1' and i_Rd_En = '0') then
          r_FIFO_Count <= r_FIFO_Count + 1;
        elsif (i_Wr_En = '0' and i_Rd_En = '1') then
          r_FIFO_Count <= r_FIFO_Count - 1;
        end if;
 
        -- Keeps track of the write index (and controls roll-over)
        if (i_Wr_En = '1' and w_Full = '0') then
          if r_Wr_Index = DEPTH-1 then
            r_Wr_Index <= 0;
          else
            r_Wr_Index <= r_Wr_Index + 1;
          end if;
        end if;
 
        -- Keeps track of the read index (and controls roll-over)        
        if (i_Rd_En = '1' and w_Empty = '0') then
          if r_Rd_Index = DEPTH-1 then
            r_Rd_Index <= 0;
          else
            r_Rd_Index <= r_Rd_Index + 1;
          end if;
        end if;
 
        -- Registers the input data when there is a write
        if i_Wr_En = '1' then
          r_FIFO_Data(r_Wr_Index) <= i_Wr_Data;
        end if;
         
      end if;                           -- sync reset
    end if;                             -- rising_edge(i_Clk)
  end process p_CONTROL;
 
   
  o_Rd_Data <= r_FIFO_Data(r_Rd_Index);
 
  w_Full  <= '1' when (r_FIFO_Count = DEPTH) or (r_FIFO_Count = DEPTH-1 and i_Wr_En = '1') else '0';
  w_Empty <= '1' when (r_FIFO_Count = 0) or (r_FIFO_Count = 1 and i_Rd_En = '1') else '0';
 
  o_AF <= '1' when r_FIFO_Count > AF_LEVEL else '0';
  o_AE <= '1' when r_FIFO_Count < AE_LEVEL else '0';
   
  o_Full  <= w_Full;
  o_Empty <= w_Empty;
   
 
  -----------------------------------------------------------------------------
  -- ASSERTION LOGIC - Not synthesized
  -----------------------------------------------------------------------------
  -- synthesis translate_off
 
  p_ASSERT : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      if i_Wr_En = '1' and w_Full = '1' then
        report "ASSERT FAILURE - MODULE_REGISTER_FIFO: FIFO IS FULL AND BEING WRITTEN " severity failure;
      end if;
 
      if i_Rd_En = '1' and w_Empty = '1' then
        report "ASSERT FAILURE - MODULE_REGISTER_FIFO: FIFO IS EMPTY AND BEING READ " severity failure;
      end if;
    end if;
  end process p_ASSERT;
 
  -- synthesis translate_on
   
end RTL;
