//////////////////////////////////////////////////////////////////////////////
// FPGA Bus Registers
// Contains 16 Readable/Writable Registers.
//
// Parameters:
// BUS_WIDTH - Recommended to set to 8, 16, or 32.
// INIT_XX   - Used to initalize registers to non-zero values.
//
// Note: Address is used to increment into entire word of g_BUS_WIDTH
//////////////////////////////////////////////////////////////////////////////
module Bus_Reg_X16 #(parameter INIT_00  = 0,
                     parameter INIT_02  = 0,
                     parameter INIT_04  = 0,
                     parameter INIT_06  = 0,
                     parameter INIT_08  = 0,
                     parameter INIT_0A  = 0,
                     parameter INIT_0C  = 0,
                     parameter INIT_0E  = 0,
                     parameter INIT_10  = 0,
                     parameter INIT_12  = 0,
                     parameter INIT_14  = 0,
                     parameter INIT_16  = 0,
                     parameter INIT_18  = 0,
                     parameter INIT_1A  = 0,
                     parameter INIT_1C  = 0,
                     parameter INIT_1E  = 0)
 (input             i_Bus_Rst_L,
  input             i_Bus_Clk,
  input             i_Bus_CS,
  input             i_Bus_Wr_Rd_n,
  input [4:0]       i_Bus_Addr8,
  input [15:0]      i_Bus_Wr_Data,
  output reg [15:0] o_Bus_Rd_Data,
  output reg        o_Bus_Rd_DV,
  input [15:0]      i_Reg_00,
  input [15:0]      i_Reg_02,
  input [15:0]      i_Reg_04,
  input [15:0]      i_Reg_06,
  input [15:0]      i_Reg_08,
  input [15:0]      i_Reg_0A,
  input [15:0]      i_Reg_0C,
  input [15:0]      i_Reg_0E,
  input [15:0]      i_Reg_10,
  input [15:0]      i_Reg_12,
  input [15:0]      i_Reg_14,
  input [15:0]      i_Reg_16,
  input [15:0]      i_Reg_18,
  input [15:0]      i_Reg_1A,
  input [15:0]      i_Reg_1C,
  input [15:0]      i_Reg_1E,
  output reg [15:0] o_Reg_00,
  output reg [15:0] o_Reg_02,
  output reg [15:0] o_Reg_04,
  output reg [15:0] o_Reg_06,
  output reg [15:0] o_Reg_08,
  output reg [15:0] o_Reg_0A,
  output reg [15:0] o_Reg_0C,
  output reg [15:0] o_Reg_0E,
  output reg [15:0] o_Reg_10,
  output reg [15:0] o_Reg_12,
  output reg [15:0] o_Reg_14,
  output reg [15:0] o_Reg_16,
  output reg [15:0] o_Reg_18,
  output reg [15:0] o_Reg_1A,
  output reg [15:0] o_Reg_1C,
  output reg [15:0] o_Reg_1E);


  always @(posedge i_Bus_Clk or negedge i_Bus_Rst_L)
  begin
    if (~i_Bus_Rst_L)
    begin
      o_Bus_Rd_DV <= 1'b0;
      o_Reg_00   <= INIT_00;
      o_Reg_02   <= INIT_02;
      o_Reg_04   <= INIT_04;
      o_Reg_06   <= INIT_06;
      o_Reg_08   <= INIT_08;
      o_Reg_0A   <= INIT_0A;
      o_Reg_0C   <= INIT_0C;
      o_Reg_0E   <= INIT_0E;
      o_Reg_10   <= INIT_10;
      o_Reg_12   <= INIT_12;
      o_Reg_14   <= INIT_14;
      o_Reg_16   <= INIT_16;
      o_Reg_18   <= INIT_18;
      o_Reg_1A   <= INIT_1A;
      o_Reg_1C   <= INIT_1C;
      o_Reg_1E   <= INIT_1E;
    end
    else
    begin
      o_Bus_Rd_DV <= 1'b0;

      if (i_Bus_CS == 1'b1)
      begin
        if (i_Bus_Wr_Rd_n == 1'b1) // Write Command
        begin
          case (i_Bus_Addr8[4:1])
          4'b0000 : o_Reg_00 <= i_Bus_Wr_Data;
          4'b0001 : o_Reg_02 <= i_Bus_Wr_Data;
          4'b0010 : o_Reg_04 <= i_Bus_Wr_Data;
          4'b0011 : o_Reg_06 <= i_Bus_Wr_Data;
          4'b0100 : o_Reg_08 <= i_Bus_Wr_Data;
          4'b0101 : o_Reg_0A <= i_Bus_Wr_Data;
          4'b0110 : o_Reg_0C <= i_Bus_Wr_Data;
          4'b0111 : o_Reg_0E <= i_Bus_Wr_Data;
          4'b1000 : o_Reg_10 <= i_Bus_Wr_Data;
          4'b1001 : o_Reg_12 <= i_Bus_Wr_Data;
          4'b1010 : o_Reg_14 <= i_Bus_Wr_Data;
          4'b1011 : o_Reg_16 <= i_Bus_Wr_Data;
          4'b1100 : o_Reg_18 <= i_Bus_Wr_Data;
          4'b1101 : o_Reg_1A <= i_Bus_Wr_Data;
          4'b1110 : o_Reg_1C <= i_Bus_Wr_Data;
          4'b1111 : o_Reg_1E <= i_Bus_Wr_Data;
          endcase
        end
        else // Read Command
        begin
          o_Bus_Rd_DV   <= 1'b1;
          
          case (i_Bus_Addr8[4:1])
          4'b0000 : o_Bus_Rd_Data <= i_Reg_00;
          4'b0001 : o_Bus_Rd_Data <= i_Reg_02;
          4'b0010 : o_Bus_Rd_Data <= i_Reg_04;
          4'b0011 : o_Bus_Rd_Data <= i_Reg_06;
          4'b0100 : o_Bus_Rd_Data <= i_Reg_08;
          4'b0101 : o_Bus_Rd_Data <= i_Reg_0A;
          4'b0110 : o_Bus_Rd_Data <= i_Reg_0C;
          4'b0111 : o_Bus_Rd_Data <= i_Reg_0E;
          4'b1000 : o_Bus_Rd_Data <= i_Reg_10;
          4'b1001 : o_Bus_Rd_Data <= i_Reg_12;
          4'b1010 : o_Bus_Rd_Data <= i_Reg_14;
          4'b1011 : o_Bus_Rd_Data <= i_Reg_16;
          4'b1100 : o_Bus_Rd_Data <= i_Reg_18;
          4'b1101 : o_Bus_Rd_Data <= i_Reg_1A;
          4'b1110 : o_Bus_Rd_Data <= i_Reg_1C;
          4'b1111 : o_Bus_Rd_Data <= i_Reg_1E;
          endcase 
        end // else: !if(i_Bus_Wr_Rd_n == 1'b1)
      end // if (i_Bus_CS == 1'b1)
    end // else: !if(!i_Bus_Rst_L)
  end // always @ (posedge i_Bus_Clk or negedge i_Bus_Rst_L)

endmodule
