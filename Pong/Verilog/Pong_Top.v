module Pong_Top
  #(parameter c_TOTAL_COLS=800,
    parameter c_TOTAL_ROWS=525,
    parameter c_ACTIVE_COLS=640,
    parameter c_ACTIVE_ROWS=480)
  (input            i_Clk,
   input            i_HSync,
   input            i_VSync,
   // Game Start Button   
   input            i_Game_Start,
   // Player 1 and Player 2 Controls (Controls Paddles)
   input            i_Paddle_Up_P1,
   input            i_Paddle_Dn_P1,
   input            i_Paddle_Up_P2,
   input            i_Paddle_Dn_P2,
   // Output Video
   output reg       o_HSync,
   output reg       o_VSync,
   output [3:0] o_Red_Video,
   output [3:0] o_Grn_Video,
   output [3:0] o_Blu_Video);

  // Local Constants to Determine Game Play
  parameter c_GAME_WIDTH  = 40;
  parameter c_GAME_HEIGHT = 30;
  parameter c_SCORE_LIMIT = 9;
  parameter c_PADDLE_HEIGHT = 6;
  parameter c_PADDLE_COL_P1 = 0;  // Col Index of Paddle for P1
  parameter c_PADDLE_COL_P2 = c_GAME_WIDTH-1; // Index for P2

  // State machine enumerations
  parameter IDLE    = 3'b000;
  parameter RUNNING = 3'b001;
  parameter P1_WINS = 3'b010;
  parameter P2_WINS = 3'b011;
  parameter CLEANUP = 3'b100;

  reg [2:0] r_SM_Main = IDLE;

  wire       w_HSync, w_VSync;
  wire [9:0] w_Col_Count, w_Row_Count;
  
  wire       w_Draw_Paddle_P1, w_Draw_Paddle_P2;
  wire [5:0] w_Paddle_Y_P1, w_Paddle_Y_P2;
  wire       w_Draw_Ball, w_Draw_Any;
  wire [5:0] w_Ball_X, w_Ball_Y;

  reg [3:0] r_P1_Score = 0;
  reg [3:0] r_P2_Score = 0;

  // Divided version of the Row/Col Counters
  // Allows us to make the board 40x30
  wire [5:0] w_Col_Count_Div, w_Row_Count_Div;

  Sync_To_Count #(.TOTAL_COLS(c_TOTAL_COLS),
                  .TOTAL_ROWS(c_TOTAL_ROWS)) Sync_To_Count_Inst
    (.i_Clk(i_Clk),
     .i_HSync(i_HSync),
     .i_VSync(i_VSync),
     .o_HSync(w_HSync),
     .o_VSync(w_VSync),
     .o_Col_Count(w_Col_Count),
     .o_Row_Count(w_Row_Count));

  // Register syncs to align with output data.
  always @(posedge i_Clk)
  begin
    o_HSync <= w_HSync;
    o_VSync <= w_VSync;
  end

  // Drop 4 LSBs, which effectively divides by 16
  assign w_Col_Count_Div = w_Col_Count[9:4];
  assign w_Row_Count_Div = w_Row_Count[9:4];


  // Instantiation of Paddle Control + Draw for Player 1
  Pong_Paddle_Ctrl #(.c_PLAYER_PADDLE_X(c_PADDLE_COL_P1),
                     .c_GAME_HEIGHT(c_GAME_HEIGHT)) P1_Inst
    (.i_Clk(i_Clk),
     .i_Col_Count_Div(w_Col_Count_Div),
     .i_Row_Count_Div(w_Row_Count_Div),
     .i_Paddle_Up(i_Paddle_Up_P1),
     .i_Paddle_Dn(i_Paddle_Dn_P1),
     .o_Draw_Paddle(w_Draw_Paddle_P1),
     .o_Paddle_Y(w_Paddle_Y_P1));

  // Instantiation of Paddle Control + Draw for Player 2
  Pong_Paddle_Ctrl #(.c_PLAYER_PADDLE_X(c_PADDLE_COL_P2),
                     .c_GAME_HEIGHT(c_GAME_HEIGHT)) P2_Inst
    (.i_Clk(i_Clk),
     .i_Col_Count_Div(w_Col_Count_Div),
     .i_Row_Count_Div(w_Row_Count_Div),
     .i_Paddle_Up(i_Paddle_Up_P2),
     .i_Paddle_Dn(i_Paddle_Dn_P2),
     .o_Draw_Paddle(w_Draw_Paddle_P2),
     .o_Paddle_Y(w_Paddle_Y_P2));

  // Instantiation of Ball Control + Draw
  Pong_Ball_Ctrl Pong_Ball_Ctrl_Inst
    (.i_Clk(i_Clk),
     .i_Game_Active(w_Game_Active),
     .i_Col_Count_Div(w_Col_Count_Div),
     .i_Row_Count_Div(w_Row_Count_Div),
     .o_Draw_Ball(w_Draw_Ball),
     .o_Ball_X(w_Ball_X),
     .o_Ball_Y(w_Ball_Y));


  // Create a state machine to control the state of play
  always @(posedge i_Clk)
  begin
    case (r_SM_Main)

    // Stay in this state until Game Start button is hit
    IDLE :
    begin
      if (i_Game_Start == 1'b1)
        r_SM_Main <= RUNNING;
    end

    // Stay in this state until either player misses the ball
    // can only occur when the Ball is at 0 to c_GAME_WIDTH-1
    RUNNING :
    begin
      // Player 1 Side
      if (w_Ball_X == 0 && 
          (w_Ball_Y < w_Paddle_Y_P1 || 
           w_Ball_Y > w_Paddle_Y_P1 + c_PADDLE_HEIGHT))
        r_SM_Main <= P2_WINS;

      // Player 2 Side
      else if (w_Ball_X == c_GAME_WIDTH-1 && 
               (w_Ball_Y < w_Paddle_Y_P2 ||
                w_Ball_Y > w_Paddle_Y_P2  + c_PADDLE_HEIGHT))
        r_SM_Main <= P1_WINS;
    end

    P1_WINS :
    begin
      if (r_P1_Score == c_SCORE_LIMIT-1)
        r_P1_Score <= 0;
      else
      begin
        r_P1_Score <= r_P1_Score + 1;
        r_SM_Main <= CLEANUP;
      end
    end

    P2_WINS :
    begin
      if (r_P2_Score == c_SCORE_LIMIT-1)
        r_P2_Score <= 0;
      else 
      begin
        r_P2_Score <= r_P2_Score + 1;
        r_SM_Main <= CLEANUP;
      end
    end

    CLEANUP :
      r_SM_Main <= IDLE;

    endcase
  end

  // Conditional Assignment based on State Machine state
  assign w_Game_Active = (r_SM_Main == RUNNING) ? 1'b1 : 1'b0;

  assign w_Draw_Any = w_Draw_Ball | w_Draw_Paddle_P1 | w_Draw_Paddle_P2;

  // Assign colors. Currently set to only 2 colors, white or black.
  assign o_Red_Video = w_Draw_Any ? 4'b1111 : 4'b0000;
  assign o_Grn_Video = w_Draw_Any ? 4'b1111 : 4'b0000;
  assign o_Blu_Video = w_Draw_Any ? 4'b1111 : 4'b0000;

endmodule // Pong_Top
