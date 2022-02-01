// Russell Merrick - http://www.nandland.com
//
// Creates a Synchronous FIFO made out of registers (flip-flops)
// Parameters: 
// WIDTH sets the width of the FIFO created.
// DEPTH sets the depth of the FIFO created.
// AF_LEVEL o_AF goes high when # words in FIFO is > this number.
// AE_LEVEL o_AE goes high when # words in FIFO is < this number.
//
// Total FIFO register usage will be width * depth
// Recommended to keep WIDTH/DEPTH low to prevent high reg utilization
// Note that this fifo should not be used to cross clock domains.
// (Read and write clocks NEED TO BE the same clock domain)
//
// FIFO Full Flag will assert as soon as last word is written.
// FIFO Empty Flag will assert as soon as last word is read.
// If user does not need Almost Full and Almost Empty flags,
// can just leave these outputs unconnected.
 
module FIFO_Registers #(WIDTH = 8, DEPTH = 16, AF_LEVEL = 12, AE_LEVEL = 4)
 (input i_Rst_Sync,
  input i_Clk,
 
  // FIFO Write Interface
  input i_Wr_En,
  input [WIDTH-1:0] i_Wr_Data,
  output o_AF,
  output o_Full,
  
  // FIFO Read Interface
  input i_Rd_En,
  output [WIDTH-1:0] o_Rd_Data,
  output o_AE,
  output o_Empty);
 
  reg [WIDTH-1:0] r_FIFO_Data[0:DEPTH-1];
  reg [$clog2(DEPTH)-1:0] r_Wr_Index, r_Rd_Index, r_FIFO_Count;
    
  always @(posedge i_Clk)
  begin
    if (i_Rst_Sync == 1'b1)
    begin
      r_FIFO_Count <= 0;
      r_Wr_Index   <= 0;
      r_Rd_Index   <= 0;
    end
    else
    begin
      // Keeps track of the total number of words in the FIFO
      if (i_Wr_En == 1'b1 && i_Rd_En == 1'b0)
          r_FIFO_Count <= r_FIFO_Count + 1;
      else if (i_Wr_En == 1'b0 && i_Rd_En == 1'b1)
          r_FIFO_Count <= r_FIFO_Count - 1;
 
      // Keeps track of the write index (and controls roll-over)
      if (i_Wr_En == 1'b1 && o_Full == 1'b0)
      begin
        if (r_Wr_Index == DEPTH-1)
          r_Wr_Index <= 0;
        else
          r_Wr_Index <= r_Wr_Index + 1;
      end
 
      // Keeps track of the read index (and controls roll-over)        
      if (i_Rd_En == 1'b1 && o_Empty == 1'b0)
      begin
        if (r_Rd_Index == DEPTH-1)
          r_Rd_Index <= 0;
        else
          r_Rd_Index <= r_Rd_Index + 1;
      end

      // Registers the input data when there is a write
      if (i_Wr_En == 1'b1)
        r_FIFO_Data[r_Wr_Index] <= i_Wr_Data;
                 
    end
  end

  assign o_Rd_Data = r_FIFO_Data[r_Rd_Index];
 
  assign o_Full  = (r_FIFO_Count == DEPTH) || (r_FIFO_Count == DEPTH-1 && i_Wr_En == 1'b1);
  assign o_Empty = (r_FIFO_Count == 0) || (r_FIFO_Count == 1 && i_Rd_En == 1'b1);
  
  assign o_AF = (r_FIFO_Count > AF_LEVEL);
  assign o_AE = (r_FIFO_Count < AE_LEVEL);

endmodule
