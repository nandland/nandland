library ieee;
use ieee.std_logic_1164.all;

entity VGA_TB is
end entity VGA_TB;

architecture Behave of VGA_TB is 

  component VGA_Sync_Pulses is
    generic (
      g_TOTAL_COLS  : integer;
      g_TOTAL_ROWS  : integer;
      g_ACTIVE_COLS : integer;
      g_ACTIVE_ROWS : integer
      );
    port (
      i_Clk       : in  std_logic;
      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Col_Count : out std_logic_vector(9 downto 0);
      o_Row_Count : out std_logic_vector(9 downto 0)
      );
  end component VGA_Sync_Pulses;
  
  component Test_Pattern_Gen is
    generic (
      g_VIDEO_WIDTH : integer := 3;
      g_TOTAL_COLS  : integer := 800;
      g_TOTAL_ROWS  : integer := 525;
      g_ACTIVE_COLS : integer := 640;
      g_ACTIVE_ROWS : integer := 480
      );
    port (
      i_Clk       : in  std_logic;
      i_Pattern   : in  std_logic_vector(3 downto 0);
      i_HSync     : in  std_logic;
      i_VSync     : in  std_logic;
      --
      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Red_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
      o_Grn_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
      o_Blu_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0)
      );
  end component Test_Pattern_Gen;


  constant c_CLK_PERIOD  : time    := 40 ns; -- 25 MHz clock
  constant c_VIDEO_WIDTH : integer := 3;     -- 3 bits per pixel
  constant c_TOTAL_COLS  : integer := 10;
  constant c_TOTAL_ROWS  : integer := 6;
  constant c_ACTIVE_COLS : integer := 8;
  constant c_ACTIVE_ROWS : integer := 4;

  signal r_Clk : std_logic := '0';
  
  signal w_HSync_Start, w_VSync_Start : std_logic;
  signal w_HSync_TP,    w_VSync_TP    : std_logic;
  
  signal w_Red_Video_TP    : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_TP    : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_TP    : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);

begin

  r_Clk <= not r_Clk after c_CLK_PERIOD/2;
 
  -- Generates Sync Pulses to run VGA
  VGA_Sync_Pulses_Inst : VGA_Sync_Pulses
    generic map (
      g_Total_Cols  => c_TOTAL_COLS,
      g_Total_Rows  => c_TOTAL_ROWS,
      g_Active_Cols => c_ACTIVE_COLS,
      g_Active_Rows => c_ACTIVE_ROWS)
    port map (
      i_Clk       => r_Clk,
      o_HSync     => w_HSync_Start,
      o_VSync     => w_VSync_Start,
      o_Col_Count => open,
      o_Row_Count => open);
  
  
  -- Drives Red/Grn/Blue video - Test Pattern 5 (Color Bars)
  Test_Pattern_Gen_Inst : Test_Pattern_Gen
    generic map (
      g_VIDEO_WIDTH => c_VIDEO_WIDTH,
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS)
    port map (
      i_Clk       => r_Clk,
      i_Pattern   => "0101",    -- Color Bars
      i_HSync     => w_HSync_Start,
      i_VSync     => w_VSync_Start,
      o_HSync     => w_HSync_TP,
      o_VSync     => w_VSync_TP,
      o_Red_Video => w_Red_Video_TP,
      o_Grn_Video => w_Grn_Video_TP,
      o_Blu_Video => w_Blu_Video_TP);
     
  process is
  begin
    wait for 5 us;
    assert false report "Test Complete" severity failure;
  end process;
    
end Behave;