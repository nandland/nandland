-- This module is designed for 640x480 with a 25 MHz input clock.
-- Signal o_Paddle_Y represents the index of the top of the paddle in Y dimension.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Pong_Pkg.all;

entity Pong_Paddle_Ctrl is
  generic (
    g_Player_Paddle_X : integer  -- Changes for P1 vs P2
    );
  port (
    i_Clk : in std_logic;

    i_Col_Count_Div : in std_logic_vector(5 downto 0);
    i_Row_Count_Div : in std_logic_vector(5 downto 0);

    -- Player Paddle Control
    i_Paddle_Up : in std_logic;
    i_Paddle_Dn : in std_logic;

    o_Draw_Paddle : out std_logic;
    o_Paddle_Y    : out std_logic_vector(5 downto 0)
    );
end entity Pong_Paddle_Ctrl;

architecture rtl of Pong_Paddle_Ctrl is

  -- Integer representation of the above 6 downto 0 counters.
  -- Integers are easier to work with conceptually
  signal w_Col_Index : integer range 0 to 2**i_Col_Count_Div'length := 0;
  signal w_Row_Index : integer range 0 to 2**i_Row_Count_Div'length := 0;

  signal w_Paddle_Count_En : std_logic;

  signal r_Paddle_Count : integer range 0 to c_Paddle_Speed := 0;
  
  -- Start Location (Top Left) of Paddles
  signal r_Paddle_Y : integer range 0 to c_Game_Height-c_Paddle_Height-1 := 0;

  signal r_Draw_Paddle : std_logic := '0';
  
begin

  w_Col_Index <= to_integer(unsigned(i_Col_Count_Div));
  w_Row_Index <= to_integer(unsigned(i_Row_Count_Div));  

  -- Only allow paddles to move if only one button is pushed.
  w_Paddle_Count_En <= i_Paddle_Up xor i_Paddle_Dn;

  -- Controls how the paddles are moved.  Sets r_Paddle_Y.
  -- Can change the movement speed by changing the constant in Package file.
  p_Move_Paddles : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then

      -- Update the paddle counter when either switch is pushed and held.
      if w_Paddle_Count_En = '1' then
        if r_Paddle_Count = c_Paddle_Speed then
          r_Paddle_Count <= 0;
        else
          r_Paddle_Count <= r_Paddle_Count + 1;
        end if;
      else
        r_Paddle_Count <= 0;
      end if;

      -- Update the Paddle Location Slowly, only allowed when the Paddle Count
      -- reaches its limit
      if (i_Paddle_Up = '1' and r_Paddle_Count = c_Paddle_Speed) then

        -- If Paddle is already at the top, do not update it
        if r_Paddle_Y /= 0 then
          r_Paddle_Y <= r_Paddle_Y - 1;
        end if;

      elsif (i_Paddle_Dn = '1' and r_Paddle_Count = c_Paddle_Speed) then

        -- If Paddle is already at the bottom, do not update it
        if r_Paddle_Y /= c_Game_Height-c_Paddle_Height-1 then
          r_Paddle_Y <= r_Paddle_Y + 1;
        end if;
        
      end if;
    end if;
  end process p_Move_Paddles;

  
  -- Draws the Paddles as deteremined by input Generic g_Player_Paddle_X
  -- as well as r_Paddle_Y.
  p_Draw_Paddles : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      -- Draws in a single column and in a range of rows.
      -- Range of rows is determined by c_Paddle_Height
      if (w_Col_Index = g_Player_Paddle_X and
          w_Row_Index >= r_Paddle_Y and
          w_Row_Index <= r_Paddle_Y + c_Paddle_Height) then
          r_Draw_Paddle <= '1';
      else
        r_Draw_Paddle <= '0';
      end if;
    end if;
  end process p_Draw_Paddles;

  -- Assign output for next higher module to use
  o_Draw_Paddle <= r_Draw_Paddle;
  o_Paddle_Y    <= std_logic_vector(to_unsigned(r_Paddle_Y, o_Paddle_Y'length));
  
end architecture rtl;
