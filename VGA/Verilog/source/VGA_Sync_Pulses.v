// This module is designed for 640x480 with a 25 MHz input clock.

module VGA_Sync_Pulses 
 #(parameter TOTAL_COLS  = 800, 
   parameter TOTAL_ROWS  = 525,
   parameter ACTIVE_COLS = 640, 
   parameter ACTIVE_ROWS = 480)
  (input            i_Clk, 
   output           o_HSync,
   output           o_VSync,
   output reg [9:0] o_Col_Count = 0, 
   output reg [9:0] o_Row_Count = 0
  );  
  
  always @(posedge i_Clk)
  begin
    if (o_Col_Count == TOTAL_COLS-1)
    begin
      o_Col_Count <= 0;
      if (o_Row_Count == TOTAL_ROWS-1)
        o_Row_Count <= 0;
      else
        o_Row_Count <= o_Row_Count + 1;
    end
    else
      o_Col_Count <= o_Col_Count + 1;
      
  end
	  
  assign o_HSync = o_Col_Count < ACTIVE_COLS ? 1'b1 : 1'b0;
  assign o_VSync = o_Row_Count < ACTIVE_ROWS ? 1'b1 : 1'b0;
  
endmodule