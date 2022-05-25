//////////////////////////////////////////////////////////////////////////////
// Description:       Self-Checking test bench for Autoclear Registers
//                    Exercises all functionality of the autoclear registers
//                    and reports an overall simulation PASS/FAIL status.
//////////////////////////////////////////////////////////////////////////////

module Bus_Autoclear_TB ();
  
  import Sim_Bus_Pkg::*;
  import Sim_Checker_Pkg::*;
  
  parameter integer c_AC_BITS_USED = 2;
  
  logic r_Bus_Clk = 1'b0;

  logic [15:0] w_Rd_Data;
  logic [c_AC_BITS_USED-1:0] r_Done = 0;
  
  // Clock Generator:
  always #5 r_Bus_Clk = ~r_Bus_Clk;

  // Bus Interface
  Bus_Interface hook(.i_Bus_Clk(r_Bus_Clk));

  // Bus Driver
  Bus_Driver d1 = new(hook);

  // Sim Checker
  Sim_Checker c1 = new("Bus_Autoclear_TB");
  
  // Instantiate UUT
  Bus_Autoclear #(.g_AC_BITS_USED(c_AC_BITS_USED))
  UUT(
      .i_Bus_Clk(r_Bus_Clk),
      .i_Bus_CS(hook.r_Bus_CS),
      .i_Bus_Wr_Rd_n(hook.r_Bus_Wr_Rd_n),
      .i_Bus_Addr8(hook.r_Bus_Addr8[3:0]),
      .i_Bus_Wr_Data(hook.r_Bus_Wr_Data),
      .o_Bus_Rd_Data(hook.r_Bus_Rd_Data),
      .o_Bus_Rd_DV(hook.r_Bus_Rd_DV),
      //
      .o_Start(),
      .i_Done(r_Done)
      );

  initial
    begin
      
      c1.t_Set_Printing(1); // Print all Passes and Failures to Console
      d1.t_Bus_Print_Disable(); // Turn off printing of Bus driver

      #20;
      
      // Set Start Register
      d1.t_Bus_Wr(16'h0000, 16'h0001);
      // Read State Register to verify AC is in progress
      d1.t_Bus_Rd(16'h0002, w_Rd_Data);
      c1.t_Compare_Two_Inputs(1'b1, w_Rd_Data[0]);

      repeat (20) @(posedge r_Bus_Clk);

      // Tell Autoclear Module It's Done
      r_Done[0] <= 1'b1;
      repeat (2) @(posedge r_Bus_Clk);
      r_Done[0] <= 1'b0;
      
      // Read History State Register, LSb should be 1
      d1.t_Bus_Rd(16'h0006, w_Rd_Data);
      c1.t_Compare_Two_Inputs(1'b1, w_Rd_Data[0]);
      
      // Clear History Register
      d1.t_Bus_Wr(16'h0008, 16'h0001);
      
      // Read History State Register, LSb should be 0
      d1.t_Bus_Rd(16'h0006, w_Rd_Data);
      c1.t_Compare_Two_Inputs(1'b0, w_Rd_Data[0]);
      
      // Set Start Register (bit 1 this time)
      d1.t_Bus_Wr(16'h0000, 16'h0002);
      // Read State Register to see if autoclear is in progress
      d1.t_Bus_Rd(16'h0002, w_Rd_Data);
      c1.t_Compare_Two_Inputs(1'b1, w_Rd_Data[1]);

      // Set Stop Register
      d1.t_Bus_Wr(16'h0004, 16'h0002);

      // Read Status Register to see if autoclear was stopped successfully
      d1.t_Bus_Rd(16'h0002, w_Rd_Data);
      c1.t_Compare_Two_Inputs(1'b0, w_Rd_Data[1]);

      c1.t_Print_Results();

      $finish();
      
    end // initial begin
  
endmodule // Bus_Autoclear_TB
