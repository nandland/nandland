///////////////////////////////////////////////////////////////////////////////
// Company:     Nandland LLC
// Engineer:    Russell Merrick
//
// Description: Creates autoclear functionality as a single module.
//
//              Offset Description
//              0x0  - Autoclear Start (SW Write Only)
//                     Software writes this offset to start an event.
//                     Output pulse needs to be stretched by this module
//                     to ensure crossing clock domains is OK.  Ensure
//                     that source module looking for this pulses uses
//                     edge detection.
//
//              0x2  - Autoclear State (SW Read Only).
//                     Software can read this offset to see which events
//                     are in progress.  FPGA will clear this bit when
//                     the event is complete.
//
//              0x4  - Autoclear Stop (SW Write Only)
//                     Software writes to this offset to stop an event.
//                     Position of asserted bit will stop the event.
//
//              0x6  - Autoclear History State (SW Read Only)
//                     Contains a history of the Autoclear State
//                     register.  Used for debug.
//
//              0x8  - Autoclear History Clear (SW Write Only)
//                     Clears the History State in 0x06.
//                     Position of asserted bit will clear the
//                     corresponding bit in History State
//   
// Parameters: AC_BITS_USED  Sets how many Autoclear bits are used.  Usage
//                           starts at 1 and goes up to 15, spaces cannot be
//                           skipped.  This is used to remove unneeded logic in
//                           synthesis.
///////////////////////////////////////////////////////////////////////////////

module Bus_Autoclear #(parameter AC_BITS_USED = 2)
  (input             i_Bus_Rst_L,
   input             i_Bus_Clk,
   input             i_Bus_CS,
   input             i_Bus_Wr_Rd_n,
   input [3:0]       i_Bus_Addr8,
   input [15:0]      i_Bus_Wr_Data,
   output reg [15:0] o_Bus_Rd_Data,
   output reg        o_Bus_Rd_DV,
   //
   output [AC_BITS_USED-1:0] o_AC_Start,
   input  [AC_BITS_USED-1:0] i_AC_Done);

  parameter REG_AC_START      = 0;
  parameter REG_AC_STATUS     = 2;
  parameter REG_AC_STOP       = 4;
  parameter REG_AC_HIST_STATE = 6;
  parameter REG_AC_HIST_CLEAR = 8;

  integer ii; // for loop variable

  reg [AC_BITS_USED-1:0] r_Reg_Start, r_Reg_State, r_Reg_Stop, 
                         r_Reg_Hist_State, r_Reg_Hist_Clear;

  // Purpose: Provide SW interfaces to read/write registers.
  always @(posedge i_Bus_Clk or negedge i_Bus_Rst_L)
  begin
    if (~i_Bus_Rst_L)
    begin
      o_Bus_Rd_DV <= 1'b0;
    end
    else
    begin
      o_Bus_Rd_DV       <= 1'b0;
      r_Reg_Start      <= 0;
      r_Reg_Stop       <= 0;
      r_Reg_Hist_Clear <= 0;

      if (i_Bus_CS == 1'b1)
      begin
        if (i_Bus_Wr_Rd_n == 1'b1)
        begin

          // SW Write to either 0x0, 0x4, or 0x8
          if (i_Bus_Addr8 == REG_AC_START)
            for (ii=0; ii<AC_BITS_USED; ii=ii+1)
              r_Reg_Start[ii] <= i_Bus_Wr_Data[ii];

          else if (i_Bus_Addr8 == REG_AC_STOP)
            for (ii=0; ii<AC_BITS_USED; ii=ii+1)
              r_Reg_Stop[ii]  <= i_Bus_Wr_Data[ii];

          else if (i_Bus_Addr8 == REG_AC_HIST_CLEAR)
            for (ii=0; ii<AC_BITS_USED; ii=ii+1)
              r_Reg_Hist_Clear[ii] <= i_Bus_Wr_Data[ii];

        end
        
        else
        begin    
          o_Bus_Rd_DV   <= 1'b1;
          o_Bus_Rd_Data <= 0;

          // SW Read from either 0x2 or 0x6
          if (i_Bus_Addr8 == REG_AC_STATUS)
            for (ii=0; ii<AC_BITS_USED; ii=ii+1)
              o_Bus_Rd_Data[ii] <= r_Reg_State[ii];
                        
          else if (i_Bus_Addr8 == REG_AC_HIST_STATE)
            for (ii=0; ii<AC_BITS_USED; ii=ii+1)
              o_Bus_Rd_Data[ii] <= r_Reg_Hist_State[ii];

        end // else: !if(i_Bus_Wr_Rd_n == 1'b1)
      end // if (i_Bus_CS == 1'b1)
    end // else: !if(~i_Bus_Rst_L)
  end // always @ (posedge i_Bus_Clk or negedge i_Bus_Rst_L)


  // Purpose: Keep track of Autoclear State Registers
  always @(posedge i_Bus_Clk or negedge i_Bus_Rst_L)
  begin
    if (~i_Bus_Rst_L)
    begin
      r_Reg_State      <= 0;
      r_Reg_Hist_State <= 0;
    end
    else
    begin
      for (ii=0; ii<AC_BITS_USED; ii=ii+1)
      begin
        if (r_Reg_Start[ii] == 1'b1)
        begin
          r_Reg_State[ii]      <= 1'b1;
          r_Reg_Hist_State[ii] <= 1'b1;
        end
        else if (i_AC_Done[ii] == 1'b1 || r_Reg_Stop[ii] == 1'b1)
        begin
          r_Reg_State[ii] <= 1'b0;
        end
        else if (r_Reg_Hist_Clear[ii] == 1'b1)
        begin
          r_Reg_Hist_State[ii] <= 1'b0;
        end
      end // for (ii=0; ii<AC_BITS_USED; ii=ii+1)
    end // else: !if(~i_Bus_Rst_L)
  end // always @ (posedge i_Bus_Clk or negedge i_Bus_Rst_L)

  assign o_AC_Start = r_Reg_State;
  
endmodule // Bus_Autoclear
