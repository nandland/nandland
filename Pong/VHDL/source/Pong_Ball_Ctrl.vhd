-- This module is designed for 640x480 with a 25 MHz input clock.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Pong_Pkg.all;

entity Pong_Ball_Ctrl is
  port (
    i_Clk           : in  std_logic;
    i_Game_Active   : in  std_logic;
    i_Col_Count_Div : in  std_logic_vector(5 downto 0);
    i_Row_Count_Div : in  std_logic_vector(5 downto 0);
    --
    o_Draw_Ball     : out std_logic;
    o_Ball_X        : out std_logic_vector(5 downto 0);
    o_Ball_Y        : out std_logic_vector(5 downto 0)
    );
end entity Pong_Ball_Ctrl;

architecture rtl of Pong_Ball_Ctrl is

  -- Integer representation of the above 6 downto 0 counters.
  -- Integers are easier to work with conceptually
  signal w_Col_Index : integer range 0 to 2**i_Col_Count_Div'length := 0;
  signal w_Row_Index : integer range 0 to 2**i_Row_Count_Div'length := 0;
  
  signal r_Ball_Count : integer range 0 to c_Ball_Speed := 0;
  
  -- X and Y location (Col, Row) for Pong Ball, also Previous Locations
  signal r_Ball_X      : integer range 0 to 2**i_Col_Count_Div'length := 0;
  signal r_Ball_Y      : integer range 0 to 2**i_Row_Count_Div'length := 0;
  signal r_Ball_X_Prev : integer range 0 to 2**i_Col_Count_Div'length := 0;
  signal r_Ball_Y_Prev : integer range 0 to 2**i_Row_Count_Div'length := 0;

  signal r_Draw_Ball : std_logic := '0';
  
begin

  w_Col_Index <= to_integer(unsigned(i_Col_Count_Div));
  w_Row_Index <= to_integer(unsigned(i_Row_Count_Div));  

    
  p_Move_Ball : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      -- If the game is not active, ball stays in the middle of the screen
      -- until the game starts.
      if i_Game_Active = '0' then
        r_Ball_X      <= c_Game_Width/2;
        r_Ball_Y      <= c_Game_Height/2;
        r_Ball_X_Prev <= c_Game_Width/2 + 1; 
        r_Ball_Y_Prev <= c_Game_Height/2 - 1;

      else
        -- Update the ball counter continuously.  Ball movement update rate is
        -- determined by a constant in the package file.
        if r_Ball_Count = c_Ball_Speed then
          r_Ball_Count <= 0;
        else
          r_Ball_Count <= r_Ball_Count + 1;
        end if;

        -----------------------------------------------------------------------
        -- Control X Position (Col)
        -----------------------------------------------------------------------
        if r_Ball_Count = c_Ball_Speed then
          
          -- Store Previous Location to keep track of ball movement
          r_Ball_X_Prev <= r_Ball_X;
          
          -- If ball is moving to the right, keep it moving right, but check
          -- that it's not at the wall (in which case it bounces back)
          if r_Ball_X_Prev < r_Ball_X then
            if r_Ball_X = c_Game_Width-1 then
              r_Ball_X <= r_Ball_X - 1;
            else
              r_Ball_X <= r_Ball_X + 1;
            end if;

          -- Ball is moving left, keep it moving left, check for wall impact
          elsif r_Ball_X_Prev > r_Ball_X then
            if r_Ball_X = 0 then
              r_Ball_X <= r_Ball_X + 1;
            else
              r_Ball_X <= r_Ball_X - 1;
            end if;
          end if;
        end if;

        
        -----------------------------------------------------------------------
        -- Control Y Position (Row)
        -----------------------------------------------------------------------
        if r_Ball_Count = c_Ball_Speed then
          
          -- Store Previous Location to keep track of ball movement
          r_Ball_Y_Prev <= r_Ball_Y;
          
          -- If ball is moving to the up, keep it moving up, but check
          -- that it's not at the wall (in which case it bounces back)
          if r_Ball_Y_Prev < r_Ball_Y then
            if r_Ball_Y = c_Game_Height-1 then
              r_Ball_Y <= r_Ball_Y - 1;
            else
              r_Ball_Y <= r_Ball_Y + 1;
            end if;

          -- Ball is moving down, keep it moving down, check for wall impact
          elsif r_Ball_Y_Prev > r_Ball_Y then
            if r_Ball_Y = 0 then
              r_Ball_Y <= r_Ball_Y + 1;
            else
              r_Ball_Y <= r_Ball_Y - 1;
            end if;
          end if;
        end if;
      end if;                           -- w_Game_Active = '1'
    end if;                             -- rising_edge(i_Clk)
  end process p_Move_Ball;


  -- Draws a ball at the location determined by X and Y indexes.
  p_Draw_Ball : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      if (w_Col_Index = r_Ball_X and w_Row_Index = r_Ball_Y) then
        r_Draw_Ball <= '1';
      else
        r_Draw_Ball <= '0';
      end if;
    end if;
  end process p_Draw_Ball;

  o_Draw_Ball <= r_Draw_Ball;
  o_Ball_X    <= std_logic_vector(to_unsigned(r_Ball_X, o_Ball_X'length));
  o_Ball_Y    <= std_logic_vector(to_unsigned(r_Ball_Y, o_Ball_Y'length));
  
  
end architecture rtl;
