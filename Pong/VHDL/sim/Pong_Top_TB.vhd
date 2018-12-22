-- This module is designed for 640x480 with a 25 MHz input clock.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Pong_Pkg.all;

entity Pong_Top_TB is
end entity Pong_Top_TB;

architecture behavioral of Pong_Top_TB is

  constant c_Total_Cols  : integer := 794;
  constant c_Total_Rows  : integer := 525;
  constant c_Active_Cols : integer := 640;
  constant c_Active_Rows : integer := 480;
  
  signal r_Clk : std_logic := '0';

  signal w_HSync : std_logic;   
  signal w_VSync : std_logic;
  
  signal w_Game_Start   : std_logic := '1';
  signal w_Paddle_Up_P1 : std_logic := '0';
  signal w_Paddle_Dn_P1 : std_logic := '0';
  signal w_Paddle_Up_P2 : std_logic := '0';
  signal w_Paddle_Dn_P2 : std_logic := '0';
  
begin

  -- Instantiate a module to generate sync pulses for us
  VGA_Sync_Pulses_inst : entity work.VGA_Sync_Pulses
    generic map (
      g_Total_Cols  => c_Total_Cols,
      g_Total_Rows  => c_Total_Rows,
      g_Active_Cols => c_Active_Cols,
      g_Active_Rows => c_Active_Rows)
    port map (
      i_Clk       => r_Clk,
      o_HSync     => w_HSync,
      o_VSync     => w_VSync,
      o_Col_Count => open,
      o_Row_Count => open
      );
  
  -- Instantiate the Unit Under Test (UUT)
  Pong_Top_UUT : entity work.Pong_Top
    generic map (
      g_Total_Cols  => c_Total_Cols,
      g_Total_Rows  => c_Total_Rows,
      g_Active_Cols => c_Active_Cols,
      g_Active_Rows => c_Active_Rows
      )
    port map (
      i_Clk          => r_Clk,
      i_HSync        => w_HSync,
      i_VSync        => w_VSync,
      i_Game_Start   => w_Game_Start,
      i_Paddle_Up_P1 => w_Paddle_Up_P1,
      i_Paddle_Dn_P1 => w_Paddle_Dn_P1,
      i_Paddle_Up_P2 => w_Paddle_Up_P2,
      i_Paddle_Dn_P2 => w_Paddle_Dn_P2,
      o_HSync        => open,
      o_VSync        => open,
      o_Red_Video    => open,
      o_Blu_Video    => open,
      o_Grn_Video    => open
      );

  r_Clk <= not r_Clk after 5 ns;
  
  w_Game_Start <= '1', '0' after 200 ns;
  
  --p_Test : process (r_Clk) is
  --begin
  --  if rising_edge(r_Clk) then
  --    r_Game_Start <= '1';
  --  end if;
  --end process p_Test;

  
  
end architecture behavioral;
