// Russell Merrick - http://www.nandland.com
// 
// Testbench for FIFO made from registers. 
// Demonstrates basic reads/writes working
 
 
module FIFO_Registers_TB ();
 
  parameter DEPTH = 4;
  parameter WIDTH = 8;
  parameter AF_LEVEL = 2;
  parameter AE_LEVEL = 2;
 
  reg r_Reset = 1'b0;
  reg r_Clock = 1'b0;
  reg r_Wr_En = 1'b0;
  reg [WIDTH-1:0] r_Wr_Data = 8'hA5;
  wire w_AF, w_Full, w_AE, w_Empty;
  reg r_Rd_En = 1'b0;
  reg [WIDTH-1:0] w_Rd_Data;
   
  FIFO_Registers #(.WIDTH(WIDTH), 
                   .DEPTH(DEPTH), 
                   .AF_LEVEL(AF_LEVEL), 
                   .AE_LEVEL(AE_LEVEL)) FIFO_Registers_Inst
    (.i_Rst_Sync(r_Reset),
     .i_Clk(r_Clock),
     .i_Wr_En(r_Wr_En),
     .i_Wr_Data(r_Wr_Data),
     .o_AF(w_AF),
     .o_Full(w_Full),
     .i_Rd_En(r_Rd_En),
     .o_Rd_Data(w_Rd_Data),
     .o_AE(w_AE),
     .o_Empty(w_Empty));
 
    // Clock Generator:
    always #5 r_Clock = ~r_Clock;
 
  initial 
  begin
    $dumpfile("dump.vcd");  // For edaplayground.com
    $dumpvars;
    @(posedge r_Clock);
    r_Reset <= 1'b1;
    @(posedge r_Clock);
    r_Reset <= 1'b0;
    @(posedge r_Clock);

    r_Wr_En <= 1'b1;
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    r_Wr_En <= 1'b0;
    r_Rd_En <= 1'b1;
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    r_Rd_En <= 1'b0;
    r_Wr_En <= 1'b1;
    @(posedge r_Clock);
    @(posedge r_Clock);
    r_Rd_En <= 1'b1;
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    r_Wr_En <= 1'b0;
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    @(posedge r_Clock);
    $display("Test complete");
    $finish();
  end
endmodule
