// This module is designed for 640x480 with a 25 MHz input clock.
// All test patterns are being generated all the time.  This makes use of one
// of the benefits of FPGAs, they are highly parallelizable.  Many different
// things can all be happening at the same time.  In this case, there are several
// test patterns that are being generated simulatenously.  The actual choice of
// which test pattern gets displayed is done via the i_Pattern signal, which is
// an input to a case statement.

// Available Patterns:
// Pattern 0: Disables the Test Pattern Generator
// Pattern 1: All Red
// Pattern 2: All Green
// Pattern 3: All Blue
// Pattern 4: Checkerboard white/black
// Pattern 5: Color Bars
// Pattern 6: White Box with Border (2 pixels)

// Note: Comment out this line when building in iCEcube2:
//`include "Sync_To_Count.v"


module Test_Pattern_Gen 
 #(parameter VIDEO_WIDTH = 3,
   parameter TOTAL_COLS = 800,
   parameter TOTAL_ROWS = 525,
   parameter ACTIVE_COLS = 640,
   parameter ACTIVE_ROWS = 480)
  (input       i_Clk,
   input [3:0] i_Pattern,
   input       i_HSync,
   input       i_VSync,
   output reg  o_HSync = 0,
   output reg  o_VSync = 0,
   output reg [VIDEO_WIDTH-1:0] o_Red_Video,
   output reg [VIDEO_WIDTH-1:0] o_Grn_Video,
   output reg [VIDEO_WIDTH-1:0] o_Blu_Video);
  
  wire w_VSync;
  wire w_HSync;
  
  
  // Patterns have 16 indexes (0 to 15) and can be g_Video_Width bits wide
  wire [VIDEO_WIDTH-1:0] Pattern_Red[0:15];
  wire [VIDEO_WIDTH-1:0] Pattern_Grn[0:15];
  wire [VIDEO_WIDTH-1:0] Pattern_Blu[0:15];
  
  // Make these unsigned counters (always positive)
  wire [9:0] w_Col_Count;
  wire [9:0] w_Row_Count;

  wire [6:0] w_Bar_Width;
  wire [2:0] w_Bar_Select;
  
  Sync_To_Count #(.TOTAL_COLS(TOTAL_COLS),
                  .TOTAL_ROWS(TOTAL_ROWS))
  
  UUT (.i_Clk      (i_Clk),
       .i_HSync    (i_HSync),
       .i_VSync    (i_VSync),
       .o_HSync    (w_HSync),
       .o_VSync    (w_VSync),
       .o_Col_Count(w_Col_Count),
       .o_Row_Count(w_Row_Count)
      );
	  
  
  // Register syncs to align with output data.
  always @(posedge i_Clk)
  begin
    o_VSync <= w_VSync;
    o_HSync <= w_HSync;
  end
  
  /////////////////////////////////////////////////////////////////////////////
  // Pattern 0: Disables the Test Pattern Generator
  /////////////////////////////////////////////////////////////////////////////
  assign Pattern_Red[0] = 0;
  assign Pattern_Grn[0] = 0;
  assign Pattern_Blu[0] = 0;
  
  /////////////////////////////////////////////////////////////////////////////
  // Pattern 1: All Red
  /////////////////////////////////////////////////////////////////////////////
  assign Pattern_Red[1] = (w_Col_Count < ACTIVE_COLS && w_Row_Count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;
  assign Pattern_Grn[1] = 0;
  assign Pattern_Blu[1] = 0;

  /////////////////////////////////////////////////////////////////////////////
  // Pattern 2: All Green
  /////////////////////////////////////////////////////////////////////////////
  assign Pattern_Red[2] = 0;
  assign Pattern_Grn[2] = (w_Col_Count < ACTIVE_COLS && w_Row_Count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;
  assign Pattern_Blu[2] = 0;
  
  /////////////////////////////////////////////////////////////////////////////
  // Pattern 3: All Blue
  /////////////////////////////////////////////////////////////////////////////
  assign Pattern_Red[3] = 0;
  assign Pattern_Grn[3] = 0;
  assign Pattern_Blu[3] = (w_Col_Count < ACTIVE_COLS && w_Row_Count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;

  /////////////////////////////////////////////////////////////////////////////
  // Pattern 4: Checkerboard white/black
  /////////////////////////////////////////////////////////////////////////////
  assign Pattern_Red[4] = w_Col_Count[5] ^ w_Row_Count[5] ? {VIDEO_WIDTH{1'b1}} : 0;
  assign Pattern_Grn[4] = Pattern_Red[4];
  assign Pattern_Blu[4] = Pattern_Red[4];
  
  
  /////////////////////////////////////////////////////////////////////////////
  // Pattern 5: Color Bars
  // Divides active area into 8 Equal Bars and colors them accordingly
  // Colors Each According to this Truth Table:
  // R G B  w_Bar_Select  Ouput Color
  // 0 0 0       0        Black
  // 0 0 1       1        Blue
  // 0 1 0       2        Green
  // 0 1 1       3        Turquoise
  // 1 0 0       4        Red
  // 1 0 1       5        Purple
  // 1 1 0       6        Yellow
  // 1 1 1       7        White
  /////////////////////////////////////////////////////////////////////////////
  assign w_Bar_Width = ACTIVE_COLS/8;
  
  assign w_Bar_Select = w_Col_Count < w_Bar_Width*1 ? 0 : 
                        w_Col_Count < w_Bar_Width*2 ? 1 :
				        w_Col_Count < w_Bar_Width*3 ? 2 :
				        w_Col_Count < w_Bar_Width*4 ? 3 :
				        w_Col_Count < w_Bar_Width*5 ? 4 :
				        w_Col_Count < w_Bar_Width*6 ? 5 :
				        w_Col_Count < w_Bar_Width*7 ? 6 : 7;
				  
  // Implement Truth Table above with Conditional Assignments
  assign Pattern_Red[5] = (w_Bar_Select == 4 || w_Bar_Select == 5 ||
                           w_Bar_Select == 6 || w_Bar_Select == 7) ? 
                          {VIDEO_WIDTH{1'b1}} : 0;
					 
  assign Pattern_Grn[5] = (w_Bar_Select == 2 || w_Bar_Select == 3 ||
                           w_Bar_Select == 6 || w_Bar_Select == 7) ? 
                          {VIDEO_WIDTH{1'b1}} : 0;
					 					 
  assign Pattern_Blu[5] = (w_Bar_Select == 1 || w_Bar_Select == 3 ||
                           w_Bar_Select == 5 || w_Bar_Select == 7) ?
                          {VIDEO_WIDTH{1'b1}} : 0;


  /////////////////////////////////////////////////////////////////////////////
  // Pattern 6: Black With White Border
  // Creates a black screen with a white border 2 pixels wide around outside.
  /////////////////////////////////////////////////////////////////////////////
  assign Pattern_Red[6] = (w_Row_Count <= 1 || w_Row_Count >= ACTIVE_ROWS-1-1 ||
                           w_Col_Count <= 1 || w_Col_Count >= ACTIVE_COLS-1-1) ?
                          {VIDEO_WIDTH{1'b1}} : 0;
  assign Pattern_Grn[6] = Pattern_Red[6];
  assign Pattern_Blu[6] = Pattern_Red[6];
  

  /////////////////////////////////////////////////////////////////////////////
  // Select between different test patterns
  /////////////////////////////////////////////////////////////////////////////
  always @(posedge i_Clk)
  begin
    case (i_Pattern)
      4'h0 : 
      begin
	    o_Red_Video <= Pattern_Red[0];
        o_Grn_Video <= Pattern_Grn[0];
        o_Blu_Video <= Pattern_Blu[0];
      end
      4'h1 :
      begin
        o_Red_Video <= Pattern_Red[1];
        o_Grn_Video <= Pattern_Grn[1];
        o_Blu_Video <= Pattern_Blu[1];
      end
      4'h2 :
      begin
        o_Red_Video <= Pattern_Red[2];
        o_Grn_Video <= Pattern_Grn[2];
        o_Blu_Video <= Pattern_Blu[2];
      end
      4'h3 :
      begin
        o_Red_Video <= Pattern_Red[3];
        o_Grn_Video <= Pattern_Grn[3];
        o_Blu_Video <= Pattern_Blu[3];
      end
      4'h4 :
      begin
        o_Red_Video <= Pattern_Red[4];
        o_Grn_Video <= Pattern_Grn[4];
        o_Blu_Video <= Pattern_Blu[4];
      end
      4'h5 :
      begin
        o_Red_Video <= Pattern_Red[5];
        o_Grn_Video <= Pattern_Grn[5];
        o_Blu_Video <= Pattern_Blu[5];
      end
      4'h6 :
      begin
        o_Red_Video <= Pattern_Red[6];
        o_Grn_Video <= Pattern_Grn[6];
        o_Blu_Video <= Pattern_Blu[6];
      end
      default:
      begin
        o_Red_Video <= Pattern_Red[0];
        o_Grn_Video <= Pattern_Grn[0];
        o_Blu_Video <= Pattern_Blu[0];
      end
    endcase
  end
endmodule
