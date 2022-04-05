// Russell Merrick - http://www.nandland.com
//
// Creates a Dual (2) Port RAM (Random Access Memory)
// Single port RAM has one port, so can only access one memory location at a time.
// Dual port RAM can read and write to different memory locations at the same time.
//
// WIDTH sets the width of the Memory created.
// DEPTH sets the depth of the Memory created.
// Likely tools will infer Block RAM if WIDTH/DEPTH is large enough.
// If small, tools will infer register-based memory.
// 
// Can be used in two different clock domains, or can tie i_Wr_Clk 
// and i_Rd_Clk to same clock for operation in a single clock domain.

module RAM_2Port #(parameter WIDTH = 16, DEPTH = 256)
  (// Write Signals
   input                     i_Wr_Clk,
   input [$clog2(DEPTH)-1:0] i_Wr_Addr,
   input                     i_Wr_DV,
   input [WIDTH-1:0]         i_Wr_Data,
   // Read Signals
   input                     i_Rd_Clk,
   input [$clog2(DEPTH)-1:0] i_Rd_Addr,
   input                     i_Rd_En,
   output reg                o_Rd_DV,
   output reg [WIDTH-1:0]    o_Rd_Data
   );

  // Declare the Memory variable
  reg [WIDTH-1:0] r_Mem[DEPTH-1:0];

  // Handle writes to memory
  always @ (posedge i_Wr_Clk)
  begin
    if (i_Wr_DV)
    begin
      r_Mem[i_Wr_Addr] <= i_Wr_Data;
    end
  end

  // Handle reads from memory
  always @ (posedge i_Rd_Clk)
  begin
    o_Rd_Data <= r_Mem[i_Rd_Addr];
    o_Rd_DV   <= i_Rd_En;
  end

endmodule
