//////////////////////////////////////////////////////////////////////////////
// FPGA Bus Registers
// Contains 1 Readable/Writable Register.
//
// Parameters:
// BUS_WIDTH - Recommended to set to 8, 16, or 32.
// INIT_XX   - Used to initalize registers to non-zero values.
//////////////////////////////////////////////////////////////////////////////
module Bus_Reg_X1 #(parameter INIT_00  = 0)
 (input             i_Bus_Rst_L,
  input             i_Bus_Clk,
  input             i_Bus_CS,
  input             i_Bus_Wr_Rd_n,
  input [15:0]      i_Bus_Wr_Data,
  output reg [15:0] o_Bus_Rd_Data,
  output reg        o_Bus_Rd_DV,
  input [15:0]      i_Reg_00,
  output reg [15:0] o_Reg_00);

  always @(posedge i_Bus_Clk or negedge i_Bus_Rst_L)
  begin
    if (~i_Bus_Rst_L)
    begin
      o_Bus_Rd_DV <= 1'b0;
      o_Reg_00   <= INIT_00;
    end
    else
    begin
      o_Bus_Rd_DV <= 1'b0;

      if (i_Bus_CS == 1'b1)
      begin
        if (i_Bus_Wr_Rd_n == 1'b1) // Write Command
          o_Reg_00 <= i_Bus_Wr_Data;
        else // Read Command
        begin
          o_Bus_Rd_DV   <= 1'b1;
          o_Bus_Rd_Data <= i_Reg_00;
        end
      end // if (i_Bus_CS == 1'b1)
    end // else: !if(!i_Bus_Rst_L)
  end // always @ (posedge i_Bus_Clk or negedge i_Bus_Rst_L)

endmodule
