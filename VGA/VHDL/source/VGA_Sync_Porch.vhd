-- The purpose of this module is to modify the input HSync and VSync signals to
-- include some time for what is called the Front and Back porch.  The front
-- and back porch of a VGA interface used to have more meaning when a monitor
-- actually used a Cathode Ray Tube (CRT) to draw an image on the screen.  You
-- can read more about the details of how old VGA monitors worked here.  These
-- days, the notion of a front and back porch is maintained, due more to
-- convention than to the physics of the monitor.
-- New standards like DVI and HDMI which are meant for digital signals have
-- removed this notion of the front and back porches.  Remember that VGA is an
-- analog interface.
-- This module is designed for 640x480 with a 25 MHz input clock.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_Sync_Porch is
  generic (
    g_VIDEO_WIDTH : integer;
    g_TOTAL_COLS  : integer;
    g_TOTAL_ROWS  : integer;
    g_ACTIVE_COLS : integer;
    g_ACTIVE_ROWS : integer
    );
  port (
    i_Clk       : in std_logic;
    i_HSync     : in std_logic;
    i_VSync     : in std_logic;
    i_Red_Video : in std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    i_Grn_Video : in std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    i_Blu_Video : in std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    --
    o_HSync     : out std_logic;
    o_VSync     : out std_logic;
    o_Red_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    o_Grn_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
    o_Blu_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0)    
    );
end entity VGA_Sync_Porch;


architecture RTL of VGA_Sync_Porch is

  constant c_FRONT_PORCH_HORZ : integer := 14;
  constant c_BACK_PORCH_HORZ  : integer := 54;
  constant c_FRONT_PORCH_VERT : integer := 9;
  constant c_BACK_PORCH_VERT  : integer := 34;

  component Sync_To_Count is
    generic (
      g_TOTAL_COLS : integer;
      g_TOTAL_ROWS : integer
      );
    port (
      i_Clk   : in std_logic;
      i_HSync : in std_logic;
      i_VSync : in std_logic;

      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Col_Count : out std_logic_vector(9 downto 0);
      o_Row_Count : out std_logic_vector(9 downto 0)
      );
  end component Sync_To_Count;
  
  signal w_HSync : std_logic;
  signal w_VSync : std_logic;
  signal r_HSync : std_logic := '0';
  signal r_VSync : std_logic := '0';

  signal w_Col_Count : std_logic_vector(9 downto 0);
  signal w_Row_Count : std_logic_vector(9 downto 0);

  signal r_Red_Video : std_logic_vector(g_VIDEO_WIDTH-1 downto 0) := (others => '0');
  signal r_Grn_Video : std_logic_vector(g_VIDEO_WIDTH-1 downto 0) := (others => '0');
  signal r_Blu_Video : std_logic_vector(g_VIDEO_WIDTH-1 downto 0) := (others => '0');
  
begin

  Sync_To_Count_Porch_inst : Sync_To_Count
    generic map (
      g_TOTAL_COLS => g_TOTAL_COLS,
      g_TOTAL_ROWS => g_TOTAL_ROWS
      )
    port map (
      i_Clk       => i_Clk,
      i_HSync     => i_HSync,
      i_VSync     => i_VSync,
      o_HSync     => w_HSync,
      o_VSync     => w_VSync,
      o_Col_Count => w_Col_Count,
      o_Row_Count => w_Row_Count
      );

  -- Purpose: Modifies the HSync and VSync signals to include Front/Back Porch
  p_Sync_Porch : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      if (to_integer(unsigned(w_Col_Count)) < c_FRONT_PORCH_HORZ + g_ACTIVE_COLS or 
          to_integer(unsigned(w_Col_Count)) > g_TOTAL_COLS - c_BACK_PORCH_HORZ - 1) then
        r_HSync <= '1';
      else
        r_HSync <= w_HSync;
      end if;

      if (to_integer(unsigned(w_Row_Count)) < c_FRONT_PORCH_VERT + g_ACTIVE_ROWS or
          to_integer(unsigned(w_Row_Count)) > g_TOTAL_ROWS - c_BACK_PORCH_VERT - 1) then
        r_Vsync <= '1';
      else
        r_VSync <= w_VSync;
      end if;
    end if;
  end process p_Sync_Porch;

  o_HSync <= r_HSync;
  o_VSync <= r_VSync;

  
  -- Purpose: Align input video to modified Sync pulses. (2 Clock Cycles of Delay)
  p_Video_Align : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      r_Red_Video <= i_Red_Video;
      r_Grn_Video <= i_Grn_Video;
      r_Blu_Video <= i_Blu_Video;

      o_Red_Video <= r_Red_Video;
      o_Grn_Video <= r_Grn_Video;
      o_Blu_Video <= r_Blu_Video;
    end if;
  end process p_Video_Align;
  
end architecture RTL;
