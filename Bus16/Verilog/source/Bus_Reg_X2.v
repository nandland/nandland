//////////////////////////////////////////////////////////////////////////////
// FPGA Bus Registers
// Contains 2 Readable/Writable Registers.
//
// Parameters:
// BUS_WIDTH - Recommended to set to 8, 16, or 32.
// INIT_XX   - Used to initalize registers to non-zero values.
//
// Note: Address is used to increment into entire word of g_BUS_WIDTH
//////////////////////////////////////////////////////////////////////////////
module Bus_Reg_X2 #(parameter INIT_00  = 0,
                    parameter INIT_02  = 0) 
 (input             i_Bus_Rst_L,
  input             i_Bus_Clk,
  input             i_Bus_CS,
  input             i_Bus_Wr_Rd_n,
  input [1:0]       i_Bus_Addr8,
  input [15:0]      i_Bus_Wr_Data,
  output reg [15:0] o_Bus_Rd_Data,
  output reg        o_Bus_Rd_DV,
  input [15:0]      i_Reg_00,
  input [15:0]      i_Reg_02,
  output reg [15:0] o_Reg_00,
  output reg [15:0] o_Reg_02);

  always @(posedge i_Bus_Clk or negedge i_Bus_Rst_L)
  begin
    if (~i_Bus_Rst_L)
    begin
      o_Bus_Rd_DV <= 1'b0;
      o_Reg_00    <= INIT_00;
      o_Reg_02    <= INIT_02;
    end
    else
    begin
      o_Bus_Rd_DV <= 1'b0;

      if (i_Bus_CS == 1'b1)
      begin
        if (i_Bus_Wr_Rd_n == 1'b1) // Write Command
        begin
          case (i_Bus_Addr8[1])
          2'b0 : o_Reg_00 <= i_Bus_Wr_Data;
          2'b1 : o_Reg_02 <= i_Bus_Wr_Data;
          endcase
        end
        else // Read Command
        begin
          o_Bus_Rd_DV   <= 1'b1;
          
          case (i_Bus_Addr8[1])
          2'b0 : o_Bus_Rd_Data <= i_Reg_00;
          2'b1 : o_Bus_Rd_Data <= i_Reg_02;
          endcase 
        end // else: !if(i_Bus_Wr_Rd_n == 1'b1)
      end // if (i_Bus_CS == 1'b1)
    end // else: !if(!i_Bus_Rst_L)
  end // always @ (posedge i_Bus_Clk or negedge i_Bus_Rst_L)

endmodule
