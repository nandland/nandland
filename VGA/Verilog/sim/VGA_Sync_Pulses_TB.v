// Testbench for VGA_Sync_Pulses module
`include "VGA_Sync_Pulses.v"
`include "Test_Pattern_Gen.v"
`include "VGA_Sync_Porch.v"

module VGA_TB;
  
  parameter c_VIDEO_WIDTH = 3; // 3 bits per pixel
  parameter c_TOTAL_COLS  = 10;
  parameter c_TOTAL_ROWS  = 6;
  parameter c_ACTIVE_COLS = 8;
  parameter c_ACTIVE_ROWS = 4;
  
  reg r_Clk = 1'b0;
  
  wire [c_VIDEO_WIDTH-1:0] w_Red_Video_TP;
  wire [c_VIDEO_WIDTH-1:0] w_Grn_Video_TP;
  wire [c_VIDEO_WIDTH-1:0] w_Blu_Video_TP;
    
  always #20 r_Clk <= ~r_Clk;
  
  // Generates Sync Pulses to run VGA
  VGA_Sync_Pulses #(.TOTAL_COLS(c_TOTAL_COLS),
                    .TOTAL_ROWS(c_TOTAL_ROWS),
                    .ACTIVE_COLS(c_ACTIVE_COLS),
                    .ACTIVE_ROWS(c_ACTIVE_ROWS)) VGA_Sync_Pulses_Inst 
  (.i_Clk(r_Clk),
   .o_HSync(w_HSync_Start),
   .o_VSync(w_VSync_Start),
   .o_Col_Count(),
   .o_Row_Count()
  );
  
  
  // Drives Red/Grn/Blue video - Test Pattern 5 (Color Bars)
  Test_Pattern_Gen  #(.VIDEO_WIDTH(c_VIDEO_WIDTH),
                      .TOTAL_COLS(c_TOTAL_COLS),
                      .TOTAL_ROWS(c_TOTAL_ROWS),
                      .ACTIVE_COLS(c_ACTIVE_COLS),
                      .ACTIVE_ROWS(c_ACTIVE_ROWS))
  Test_Pattern_Gen_Inst
   (.i_Clk(r_Clk),
    .i_Pattern(4'b0101), // color bars
    .i_HSync(w_HSync_Start),
    .i_VSync(w_VSync_Start),
    .o_HSync(w_HSync_TP),
    .o_VSync(w_VSync_TP),
    .o_Red_Video(w_Red_Video_TP),
    .o_Grn_Video(w_Grn_Video_TP),
    .o_Blu_Video(w_Blu_Video_TP));
  
  initial
  begin
    #5000;
    $finish();
  end
    
  initial 
  begin 
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule 