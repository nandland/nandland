///////////////////////////////////////////////////////////////////////////////
// Simple Testbench for DPRAM Single Clock FIFO.
///////////////////////////////////////////////////////////////////////////////
module FIFO_DPRAM_Single_Clock_TB ();

  import Sim_Checker_Pkg::*;

  parameter DEPTH = 256;

  logic r_Rst_L  = 1'b0;
  logic r_Clk    = 1'b0;

  logic [$clog2(DEPTH)-1:0] r_AF_Level = 10, r_AE_Level = 10;
  logic r_Wr_DV  = 1'b0, w_Full, w_Empty, w_AF_Flag, w_AE_Flag, r_Rd_En = 1'b0;
  logic [7:0] r_Wr_Data = 8'h00, w_Rd_Data, tempByte;

  // Clock Generator:
  always #1 r_Clk = ~r_Clk;

  // Sim Checker
  Sim_Checker c1 = new("FIFO_DPRAM_Single_Clock_TB");

  FIFO_DPRAM_Single_Clock #(.WIDTH(8), 
                            .DEPTH(DEPTH), 
                            .MAKE_FWFT(0))  UUT
  (.i_Rst_L(r_Rst_L),
   .i_Clk(r_Clk),
   // Write Side
   .i_Wr_DV(r_Wr_DV),
   .i_Wr_Data(r_Wr_Data),
   .i_AF_Level(r_AF_Level),
   .o_AF_Flag(w_AF_Flag),
   .o_Full(w_Full),
   // Read Side
   .i_Rd_En(r_Rd_En),
   .o_Rd_Data(w_Rd_Data),
   .i_AE_Level(r_AE_Level),
   .o_AE_Flag(w_AE_Flag),
   .o_Empty(w_Empty)
   );

  initial
    begin
      #100;
      r_Rst_L  = 1'b1;
      #100;

      // Write single byte then read it out
      c1.t_Assert_True(w_Empty);
      writeByte(8'hA1);
      $display("value of empty here is %d", w_Empty);
      c1.t_Assert_False(w_Empty);

      repeat (5) @(posedge r_Clk);

      readByte(tempByte);
      c1.t_Compare_Two_Inputs(8'hA1, tempByte);
      #1;
      c1.t_Assert_True(w_Empty);
      c1.t_Assert_False(w_Full);

      // FIFO Should be empty here

      repeat (5) @(posedge r_Clk);

      $display("Checking AE Flag...");
      // Write 10 bytes and check AE flag
      repeat (10) writeByte(8'h37);
      c1.t_Assert_True(w_AE_Flag);
      writeByte(8'h37);   // 1 more!
      c1.t_Assert_False(w_AE_Flag);

      repeat (10) @(posedge r_Clk);
      
      // Write another 235 and check AF flag
      repeat (235) writeByte(8'h8F);
      c1.t_Assert_False(w_AF_Flag);
      writeByte(8'h8F);   // 1 more!
      c1.t_Assert_True(w_AF_Flag);

      // Write 8 more and check full flag
      repeat (8) writeByte(8'h99);
      c1.t_Assert_False(w_Full);
      writeByte(8'hFF);
      c1.t_Assert_True(w_Full);

      // Read out all DEPTH and check empty
      repeat (DEPTH) readByte(tempByte);
      c1.t_Assert_True(w_Empty);

      // Do simultaneous reading/writing
      @(posedge r_Clk);
      r_Wr_DV <= 1'b1;
      r_Rd_En <= 1'b1;
      repeat (10) @(posedge r_Clk);
      r_Wr_DV <= 1'b0;
      r_Rd_En <= 1'b0;
      @(posedge r_Clk);
      c1.t_Assert_True(w_Empty);

      // Let's see how we did
      c1.t_Print_Results();
      $finish();
    end


  task writeByte(input [7:0] i_Byte);
    @(posedge r_Clk);
    r_Wr_Data <= i_Byte;
    r_Wr_DV   <= 1'b1;
    @(posedge r_Clk);
    r_Wr_DV   <= 1'b0;
    @(posedge r_Clk);
  endtask // writeByte

  task readByte(output [7:0] o_Byte);
    @(posedge r_Clk);
    r_Rd_En <= 1'b1;
    @(posedge r_Clk);
    o_Byte   = w_Rd_Data;
    r_Rd_En <= 1'b0;
    @(posedge r_Clk);
  endtask // readByte

	
endmodule // FIFO_DPRAM_Single_Clock_TB


