//////////////////////////////////////////////////////////////////////////////
// FPGA Dual Port RAM, 8 bits wide
// Infers a Dual Port RAM using single clock (Bus Clock)
// Ties Port A to Bus, port B is available for general use
//
// Assert CS, Addr8, and Wr_Rd_n for 1 clock cycle to perform read or write.
// On Write, value is accepted immediately into memory being addressed.
// On Read, DV will pulse 1 clock later and o_Bus_Rd_Data will contain results.
//
// Parameters:
// DEPTH - Depth of DPRAM in number of words that are WIDTH wide.
//////////////////////////////////////////////////////////////////////////////


module Bus8_DPRAM #(DEPTH = 256)
 (input                     i_Bus_Rst_L,
  input                     i_Bus_Clk,
  input                     i_Bus_CS,
  input                     i_Bus_Wr_Rd_n,
  input [$clog2(DEPTH)-1:0] i_Bus_Addr8,
  input [7:0]               i_Bus_Wr_Data,
  output [7:0]              o_Bus_Rd_Data,
  output reg                o_Bus_Rd_DV,
  // Port B Signals
  input [7:0]               i_PortB_Data,
  input [$clog2(DEPTH)-1:0] i_PortB_Addr8,
  input                     i_PortB_WE,
  output [7:0]              o_PortB_Data
  );


  // Width is fixed to Bus width (8)
  Dual_Port_RAM_Single_Clock #(.WIDTH(8), .DEPTH(DEPTH)) Bus_RAM_Inst
  (.i_Clk(i_Bus_Clk),
   // Port A Signals
   .i_PortA_Data(i_Bus_Wr_Data),
   .i_PortA_Addr(i_Bus_Addr8),
   .i_PortA_WE(i_Bus_Wr_Rd_n & i_Bus_CS),
   .o_PortA_Data(o_Bus_Rd_Data),
   // Port B Signals
   .i_PortB_Data(i_PortB_Data),
   .i_PortB_Addr(i_PortB_Addr8),
   .i_PortB_WE(i_PortB_WE),
   .o_PortB_Data(o_PortB_Data)
   );


  // Create DV pulse, reads take 1 clock cycle
  always @(posedge i_Bus_Clk)
  begin
    o_Bus_Rd_DV <= i_Bus_CS & ~i_Bus_Wr_Rd_n;
  end

	
endmodule // Bus8_DPRAM

