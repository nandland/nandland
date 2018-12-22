//////////////////////////////////////////////////////////////////////////////
// FPGA Bus Registers, 8 bits wide
// Contains 16 Readable/Writable Registers.
//
// Parameters:
// INIT_XX - Used to initalize registers to non-zero values.
//////////////////////////////////////////////////////////////////////////////
module Bus8_Reg_X16 #(parameter INIT_00  = 0,
                      parameter INIT_01  = 0,
                      parameter INIT_02  = 0,
                      parameter INIT_03  = 0,
                      parameter INIT_04  = 0,
                      parameter INIT_05  = 0,
                      parameter INIT_06  = 0,
                      parameter INIT_07  = 0,
                      parameter INIT_08  = 0,
                      parameter INIT_09  = 0,
                      parameter INIT_0A  = 0,
                      parameter INIT_0B  = 0,
                      parameter INIT_0C  = 0,
                      parameter INIT_0D  = 0,
                      parameter INIT_0E  = 0,
                      parameter INIT_0F  = 0)
 (input            i_Bus_Rst_L,
  input            i_Bus_Clk,
  input            i_Bus_CS,
  input            i_Bus_Wr_Rd_n,
  input [3:0]      i_Bus_Addr8,
  input [7:0]      i_Bus_Wr_Data,
  output reg [7:0] o_Bus_Rd_Data,
  output reg       o_Bus_Rd_DV,
  input [7:0]      i_Reg_00,
  input [7:0]      i_Reg_01,
  input [7:0]      i_Reg_02,
  input [7:0]      i_Reg_03,
  input [7:0]      i_Reg_04,
  input [7:0]      i_Reg_05,
  input [7:0]      i_Reg_06,
  input [7:0]      i_Reg_07,
  input [7:0]      i_Reg_08,
  input [7:0]      i_Reg_09,
  input [7:0]      i_Reg_0A,
  input [7:0]      i_Reg_0B,
  input [7:0]      i_Reg_0C,
  input [7:0]      i_Reg_0D,
  input [7:0]      i_Reg_0E,
  input [7:0]      i_Reg_0F,
  output reg [7:0] o_Reg_00,
  output reg [7:0] o_Reg_01,
  output reg [7:0] o_Reg_02,
  output reg [7:0] o_Reg_03,
  output reg [7:0] o_Reg_04,
  output reg [7:0] o_Reg_05,
  output reg [7:0] o_Reg_06,
  output reg [7:0] o_Reg_07,
  output reg [7:0] o_Reg_08,
  output reg [7:0] o_Reg_09,
  output reg [7:0] o_Reg_0A,
  output reg [7:0] o_Reg_0B,
  output reg [7:0] o_Reg_0C,
  output reg [7:0] o_Reg_0D,
  output reg [7:0] o_Reg_0E,
  output reg [7:0] o_Reg_0F);


  always @(posedge i_Bus_Clk or negedge i_Bus_Rst_L)
  begin
    if (~i_Bus_Rst_L)
    begin
      o_Bus_Rd_DV <= 1'b0;
      o_Reg_00   <= INIT_00;
      o_Reg_01   <= INIT_01;
      o_Reg_02   <= INIT_02;
      o_Reg_03   <= INIT_03;
      o_Reg_04   <= INIT_04;
      o_Reg_05   <= INIT_05;
      o_Reg_06   <= INIT_06;
      o_Reg_07   <= INIT_07;
      o_Reg_08   <= INIT_08;
      o_Reg_09   <= INIT_09;
      o_Reg_0A   <= INIT_0A;
      o_Reg_0B   <= INIT_0B;
      o_Reg_0C   <= INIT_0C;
      o_Reg_0D   <= INIT_0D;
      o_Reg_0E   <= INIT_0E;
      o_Reg_0F   <= INIT_0F;
    end
    else
    begin
      o_Bus_Rd_DV <= 1'b0;

      if (i_Bus_CS == 1'b1)
      begin
        if (i_Bus_Wr_Rd_n == 1'b1) // Write Command
        begin
          case (i_Bus_Addr8[3:0])
          4'b0000 : o_Reg_00 <= i_Bus_Wr_Data;
          4'b0001 : o_Reg_01 <= i_Bus_Wr_Data;
          4'b0010 : o_Reg_02 <= i_Bus_Wr_Data;
          4'b0011 : o_Reg_03 <= i_Bus_Wr_Data;
          4'b0100 : o_Reg_04 <= i_Bus_Wr_Data;
          4'b0101 : o_Reg_05 <= i_Bus_Wr_Data;
          4'b0110 : o_Reg_06 <= i_Bus_Wr_Data;
          4'b0111 : o_Reg_07 <= i_Bus_Wr_Data;
          4'b1000 : o_Reg_08 <= i_Bus_Wr_Data;
          4'b1001 : o_Reg_09 <= i_Bus_Wr_Data;
          4'b1010 : o_Reg_0A <= i_Bus_Wr_Data;
          4'b1011 : o_Reg_0B <= i_Bus_Wr_Data;
          4'b1100 : o_Reg_0C <= i_Bus_Wr_Data;
          4'b1101 : o_Reg_0D <= i_Bus_Wr_Data;
          4'b1110 : o_Reg_0E <= i_Bus_Wr_Data;
          4'b1111 : o_Reg_0F <= i_Bus_Wr_Data;
          endcase
        end
        else // Read Command
        begin
          o_Bus_Rd_DV <= 1'b1;
          
          case (i_Bus_Addr8[3:0])
          4'b0000 : o_Bus_Rd_Data <= i_Reg_00;
          4'b0001 : o_Bus_Rd_Data <= i_Reg_01;
          4'b0010 : o_Bus_Rd_Data <= i_Reg_02;
          4'b0011 : o_Bus_Rd_Data <= i_Reg_03;
          4'b0100 : o_Bus_Rd_Data <= i_Reg_04;
          4'b0101 : o_Bus_Rd_Data <= i_Reg_05;
          4'b0110 : o_Bus_Rd_Data <= i_Reg_06;
          4'b0111 : o_Bus_Rd_Data <= i_Reg_07;
          4'b1000 : o_Bus_Rd_Data <= i_Reg_08;
          4'b1001 : o_Bus_Rd_Data <= i_Reg_09;
          4'b1010 : o_Bus_Rd_Data <= i_Reg_0A;
          4'b1011 : o_Bus_Rd_Data <= i_Reg_0B;
          4'b1100 : o_Bus_Rd_Data <= i_Reg_0C;
          4'b1101 : o_Bus_Rd_Data <= i_Reg_0D;
          4'b1110 : o_Bus_Rd_Data <= i_Reg_0E;
          4'b1111 : o_Bus_Rd_Data <= i_Reg_0F;
          endcase 
        end // else: !if(i_Bus_Wr_Rd_n == 1'b1)
      end // if (i_Bus_CS == 1'b1)
    end // else: !if(!i_Bus_Rst_L)
  end // always @ (posedge i_Bus_Clk or negedge i_Bus_Rst_L)

endmodule // Bus8_Reg_X16

