-------------------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
-------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity FIFO_Regs_No_Flags_TB is
end FIFO_Regs_No_Flags_TB;
 
architecture behave of FIFO_Regs_No_Flags_TB is
 
  constant c_DEPTH : integer := 4;
  constant c_WIDTH : integer := 8;
   
  signal r_RESET   : std_logic := '0';
  signal r_CLOCK   : std_logic := '0';
  signal r_WR_EN   : std_logic := '0';
  signal r_WR_DATA : std_logic_vector(c_WIDTH-1 downto 0) := X"A5";
  signal w_FULL    : std_logic;
  signal r_RD_EN   : std_logic := '0';
  signal w_RD_DATA : std_logic_vector(c_WIDTH-1 downto 0);
  signal w_EMPTY   : std_logic;
   
  component FIFO_Regs_No_Flags is
    generic (
      g_WIDTH : natural := 8;
      g_DEPTH : integer := 32
      );
    port (
      i_rst_sync : in std_logic;
      i_clk      : in std_logic;
 
      -- FIFO Write Interface
      i_wr_en   : in  std_logic;
      i_wr_data : in  std_logic_vector(g_WIDTH-1 downto 0);
      o_full    : out std_logic;
 
      -- FIFO Read Interface
      i_rd_en   : in  std_logic;
      o_rd_data : out std_logic_vector(g_WIDTH-1 downto 0);
      o_empty   : out std_logic
      );
  end component FIFO_Regs_No_Flags;
 
   
begin
 
  FIFO_REGS_NO_FLAGS_INST : FIFO_Regs_No_Flags
    generic map (
      g_WIDTH => c_WIDTH,
      g_DEPTH => c_DEPTH
      )
    port map (
      i_rst_sync => r_RESET,
      i_clk      => r_CLOCK,
      i_wr_en    => r_WR_EN,
      i_wr_data  => r_WR_DATA,
      o_full     => w_FULL,
      i_rd_en    => r_RD_EN,
      o_rd_data  => w_RD_DATA,
      o_empty    => w_EMPTY
      );
 
 
  r_CLOCK <= not r_CLOCK after 5 ns;
 
  p_TEST : process is
  begin
    wait until r_CLOCK = '1';
    r_WR_EN <= '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    r_WR_EN <= '0';
    r_RD_EN <= '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    r_RD_EN <= '0';
    r_WR_EN <= '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    r_RD_EN <= '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    r_WR_EN <= '0';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
 
  end process;
   
   
end behave;
