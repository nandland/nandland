// Russell Merrick - http://www.nandland.com
//
// Creates a Single Port RAM. (Random Access Memory)
// Single port RAM has one port, so can only access one memory location at a time.
// Dual port RAM can read and write to different memory locations at the same time.
//
// WIDTH sets the width of the Memory created.
// DEPTH sets the depth of the Memory created.
// Likely tools will infer Block RAM if WIDTH/DEPTH is large enough.
// If small, tools will infer register-based memory.

module RAM_1Port #(parameter WIDTH = 16, parameter DEPTH = 256) (
  input                     i_Clk,
  // Shared address for writes and reads
  input [$clog2(DEPTH)-1:0] i_Addr,
  // Write Interface
  input                     i_Wr_DV,
  input [WIDTH-1:0]         i_Wr_Data,
  // Read Interface
  input                     i_Rd_En,
  output reg                o_Rd_DV,
  output reg [WIDTH-1:0]    o_Rd_Data
  );
  
  reg [WIDTH-1:0] r_Mem [DEPTH-1:0];

  always @(posedge i_Clk)
  begin
    // Handle writes to memory
    if (i_Wr_DV)
    begin
      r_Mem[i_Addr] <= i_Wr_Data;
    end

    // Handle reads from memory
    o_Rd_Data <= r_Mem[i_Addr];
    o_Rd_DV   <= i_Rd_En; // Generate DV pulse
  end

endmodule
