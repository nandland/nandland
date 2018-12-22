// Infers a Dual Port RAM using single clock (Bus Clock)
// Ties Port A to Bus, port B is available for general use

module Bus_DPRAM #(DEPTH = 256)
 (input             i_Bus_Rst_L,
  input             i_Bus_Clk,
  input             i_Bus_CS,
  input             i_Bus_Wr_Rd_n,
  input [15:0]      i_Bus_Addr8,
  input [15:0]      i_Bus_Wr_Data,
  output [15:0]     o_Bus_Rd_Data,
  output reg        o_Bus_Rd_DV,
  // Port B Signals
  input [15:0]              i_PortB_Data,
  input [$clog2(DEPTH)-1:0] i_PortB_Addr16,  // NOT byte address
  input                     i_PortB_WE,
  output [15:0]             o_PortB_Data
  );


  // Width is fixed to Bus width (16)
  Dual_Port_RAM_Single_Clock #(.WIDTH(16), .DEPTH(DEPTH)) Bus_RAM_Inst
  (.i_Clk(i_Bus_Clk),
   // Port A Signals
   .i_PortA_Data(i_Bus_Wr_Data),
   .i_PortA_Addr(i_Bus_Addr8[$clog2(DEPTH):1]),  // Convert to Addr16
   .i_PortA_WE(i_Bus_Wr_Rd_n & i_Bus_CS),
   .o_PortA_Data(o_Bus_Rd_Data),
   // Port B Signals
   .i_PortB_Data(i_PortB_Data),
   .i_PortB_Addr(i_PortB_Addr),
   .i_PortB_WE(i_PortB_WE),
   .o_PortB_Data(o_PortB_Data)
   );


  // Create DV pulse, reads take 1 clock cycle
  always @(posedge i_Bus_Clk)
  begin
    o_Bus_Rd_DV <= i_Bus_CS & ~i_Bus_Wr_Rd_n;
  end

	
endmodule // Dual_Port_RAM_Single_Clock
