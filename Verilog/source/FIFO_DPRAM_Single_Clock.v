///////////////////////////////////////////////////////////////////////////////
// Infers a Dual Port RAM (DPRAM) Based FIFO using a single clock
// Uses a Dual Port RAM but automatically handles read/write addresses.
// To use Almost Full/Empty Flags (dynamic)
// Set i_AF_Level to number of words away from full when o_AF_Flag goes high
// Set i_AE_Level to number of words away from empty when o_AE goes high
//   o_AE_Flag is high when this number OR LESS is in FIFO.
//
// Parameters: WIDTH     - Width of the FIFO
//             DEPTH     - Max number of items able to be stored in the FIFO
//             MAKE_FWFT - Use First-Word Fall Through. Make output immediately
//                         have first written word.  TO DO: SIM THIS.
///////////////////////////////////////////////////////////////////////////////
module FIFO_DPRAM_Single_Clock #(parameter WIDTH = 8, 
                                 parameter DEPTH = 256, 
                                 parameter MAKE_FWFT = 0)
  (input                     i_Rst_L,
   input                     i_Clk,
   // Write Side
   input                     i_Wr_DV,
   input [WIDTH-1:0]         i_Wr_Data,
   input [$clog2(DEPTH)-1:0] i_AF_Level,
   output                    o_AF_Flag,
   output                    o_Full,
   // Read Side
   input                     i_Rd_En,
   output reg [WIDTH-1:0]    o_Rd_Data,
   input [$clog2(DEPTH)-1:0] i_AE_Level,
   output                    o_AE_Flag,
   output                    o_Empty
   );

  reg [$clog2(DEPTH)-1:0] r_Wr_Addr, r_Rd_Addr;
  reg [$clog2(DEPTH):0]   r_Word_Count;  // 1 extra bit to go to DEPTH

  wire [WIDTH-1:0] w_DPRAM_Data;
  //wire w_Going_Not_Empty;

  // Dual Port RAM used for storing Information bytes
  Dual_Port_RAM_Single_Clock #(.WIDTH(WIDTH), .DEPTH(DEPTH)) FIFO_DPRAM_Inst 
    (.i_Clk(i_Clk),   
     // PortA = Write Only
     .i_PortA_Data(i_Wr_Data),
     .i_PortA_Addr(r_Wr_Addr),
     .i_PortA_WE(i_Wr_DV),
     .o_PortA_Data(),
     // PortB = Read Only
     .i_PortB_Data(8'h00),
     .i_PortB_Addr(r_Rd_Addr),
     .i_PortB_WE(1'b0),
     .o_PortB_Data(w_DPRAM_Data)
     );


  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      r_Wr_Addr    <= 0;
      r_Rd_Addr    <= 0;
      r_Word_Count <= 0;
    end
    else
    begin
      // Write
      if (i_Wr_DV & ~o_Full)
      begin
        if (r_Wr_Addr == DEPTH-1)
          r_Wr_Addr <= 0;
        else
          r_Wr_Addr <= r_Wr_Addr + 1;
      end

      // Read
      if (i_Rd_En & ~o_Empty)
      begin
        if (r_Rd_Addr == DEPTH-1)
          r_Rd_Addr <= 0;
        else
          r_Rd_Addr <= r_Rd_Addr + 1;
      end

      // Keeps track of number of words in FIFO
      // Read with no write
      if (i_Rd_En & ~i_Wr_DV)
      begin
        if (r_Word_Count != 0)
        begin
          r_Word_Count <= r_Word_Count - 1;
        end
      end
      // Write with no read
      else if (i_Wr_DV & ~i_Rd_En)
      begin
        if (r_Word_Count != DEPTH)
        begin
          r_Word_Count <= r_Word_Count + 1;
        end
      end


      // Handle FWFT situation of Read/Write on same clock
      if (i_Rd_En & i_Wr_DV & o_Empty & (MAKE_FWFT == 1))
      begin
        o_Rd_Data <= i_Wr_Data;
      end
      else
      begin
        o_Rd_Data <= w_DPRAM_Data;
      end

    end // else: !if(~i_Rst_L)
  end // always @ (posedge i_Clk or negedge i_Rst_L)

/*
  generate if (MAKE_FWFT == 1)
    assign w_Going_Not_Empty = (r_Word_Count == 0) & i_Wr_DV & ~i_Rd_En;
  else
    assign w_Going_Not_Empty = 1'b0;
  endgenerate
*/
  

  assign o_Full  = (r_Word_Count == DEPTH);
  assign o_Empty = (r_Word_Count == 0);

  assign o_AF_Flag = (r_Word_Count > DEPTH - i_AF_Level) ? 1'b1 : 1'b0;
  assign o_AE_Flag = (r_Word_Count <= i_AE_Level)        ? 1'b1 : 1'b0;

  /////////////////////////////////////////////////////////////////////////////
  // ASSERTION CODE, NOT SYNTHESIZED
  // synthesis translate_off
  // Ensures that we never read from empty FIFO or write to full FIFO.
  always @(posedge i_Clk)
  begin
    if (i_Rd_En == 1'b1 && i_Wr_DV == 1'b0 && r_Word_Count == 0)
    begin
      $error("Error! Reading Empty FIFO");
    end

    if (i_Wr_DV == 1'b1 && i_Rd_En == 1'b0 && r_Word_Count == DEPTH)
    begin
      $error("Error! Writing Full FIFO");
    end
  end
  // synthesis translate_on
  /////////////////////////////////////////////////////////////////////////////
  
endmodule // FIFO_DPRAM_Single_Clock

