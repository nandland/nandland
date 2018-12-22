-- Package file containing all Constants and Components used in Pong Game

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Pong_Pkg is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  
  -- Set the Width and Height of the Game Board
  constant c_Game_Width    : integer := 40;
  constant c_Game_Height   : integer := 30;

  -- Set the number of points to play to
  constant c_Score_Limit : integer := 9;
  
  -- Set the Height (in board game units) of the paddle.
  constant c_Paddle_Height : integer := 6;

  -- Set the Speed of the paddle movement.  In this case, the paddle will move
  -- one board game unit every 50 milliseconds that the button is held down.
  constant c_Paddle_Speed : integer := 1250000;

  -- Set the Speed of the ball movement.  In this case, the ball will move
  -- one board game unit every 50 milliseconds that the button is held down.   
  constant c_Ball_Speed : integer  := 1250000;
  
  -- Sets Column index to draw Player 1 & Player 2 Paddles.
  constant c_Paddle_Col_Location_P1 : integer := 0;
  constant c_Paddle_Col_Location_P2 : integer := c_Game_Width-1;


  -----------------------------------------------------------------------------
  -- Component Declarations
  -----------------------------------------------------------------------------
  component Pong_Paddle_Ctrl is
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
  end component Pong_Paddle_Ctrl;


  component Pong_Ball_Ctrl is
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
  end component Pong_Ball_Ctrl;

  
end package Pong_Pkg;  
