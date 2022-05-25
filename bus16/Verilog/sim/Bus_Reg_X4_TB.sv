///////////////////////////////////////////////////////////////////////////////
// Description:       Simple self-checking test bench for X4 Bus
//                    Registers.  Demonstrates how all combinations of Read
//                    Only, Write Only, Read/Write registers work, and how the
//                    initial conditions can set the initial values in the
//                    registers.  Uses SystemVerilog.
///////////////////////////////////////////////////////////////////////////////

module Bus_Reg_X4_TB ();
  
  import Sim_Bus_Pkg::*;
  import Sim_Checker_Pkg::*;

  parameter [15:0] c_INIT_00 = 16'h0000;
  parameter [15:0] c_INIT_02 = 16'hAAAA;
  parameter [15:0] c_INIT_04 = 16'h5555;
  parameter [15:0] c_INIT_06 = 16'hABCD;

  logic r_Bus_Clk = 1'b0;

  logic [15:0] w_Rd_Data;
  logic [15:0] w_Reg_00, w_Reg_02, w_Reg_04, w_Reg_06;
  
  // Clock Generator:
  always #5 r_Bus_Clk = ~r_Bus_Clk;

  // Bus Interface
  Bus_Interface hook(.i_Bus_Clk(r_Bus_Clk));

  // Bus Driver
  Bus_Driver d1 = new(hook);

  // Sim Checker
  Sim_Checker c1 = new("Bus_Reg_X4_TB");
  
  // Instantiate UUT
  Bus_Reg_X4 #(.g_INIT_00(c_INIT_00),
              .g_INIT_02(c_INIT_02),
              .g_INIT_04(c_INIT_04),
              .g_INIT_06(c_INIT_06))
  UUT(
      .i_Bus_Clk(r_Bus_Clk),
      .i_Bus_CS(hook.r_Bus_CS),
      .i_Bus_Wr_Rd_n(hook.r_Bus_Wr_Rd_n),
      .i_Bus_Addr8(hook.r_Bus_Addr8[2:0]),
      .i_Bus_Wr_Data(hook.r_Bus_Wr_Data),
      .o_Bus_Rd_Data(hook.r_Bus_Rd_Data),
      .o_Bus_Rd_DV(hook.r_Bus_Rd_DV),
      //
      .i_Reg_00(w_Reg_00),
      .i_Reg_02(w_Reg_02),
      .i_Reg_04(w_Reg_04),
      .i_Reg_06(16'h0000),
      //
      .o_Reg_00(w_Reg_00),
      .o_Reg_02(w_Reg_02),
      .o_Reg_04(),
      .o_Reg_06(w_Reg_06)
      );
  

  initial
    begin

      c1.t_Set_Printing(1); // Print all Passes and Failures to Console
      d1.t_Bus_Print_Disable(); // Turn off printing of Bus driver
      
      // TEST 1 - Ensure Reg_00 has its default value in it
      d1.t_Bus_Rd(0, w_Rd_Data);
      c1.t_Compare_Two_Inputs(c_INIT_00, w_Rd_Data);

      // TEST 2 - Ensure Reg_02 has its default value in it    
      d1.t_Bus_Rd(2, w_Rd_Data);
      c1.t_Compare_Two_Inputs(c_INIT_02, w_Rd_Data);      

      // TEST 3 - Write over default value in Reg_02 then read it back again
      d1.t_Bus_Wr(2, 16'h987B);
      d1.t_Bus_Rd(2, w_Rd_Data);
      c1.t_Compare_Two_Inputs(16'h987B, w_Rd_Data);

      // TEST 4 - Reg_04 is a SW Read Only Register.
      // It gets rewritten over its default value
      d1.t_Bus_Rd(4, w_Rd_Data);
      c1.t_Compare_Two_Inputs(w_Reg_04, w_Rd_Data);

      // TEST 5 - Reg_04 is Read only, so try to write to it and make sure
      // old value is still retained in the register
      d1.t_Bus_Wr(4, 16'hBEEF);
      d1.t_Bus_Rd(4, w_Rd_Data);
      c1.t_Compare_Two_Inputs(w_Reg_04, w_Rd_Data);
      
      // TEST 6 - Reg_06 is Write only Reg, it should always read back zero
      d1.t_Bus_Rd(6, w_Rd_Data);
      c1.t_Compare_Two_Inputs(0, w_Rd_Data);

      // TEST 6 - Write over the default value then make sure that readback 
      // only has 0, since it's a write-only register
      d1.t_Bus_Wr(6, 16'h12AB);
      d1.t_Bus_Rd(6, w_Rd_Data);
      c1.t_Compare_Two_Inputs(0, w_Rd_Data);

      c1.t_Print_Results();

      $finish();
      
    end // initial begin
  
endmodule // Bus_Reg_X4_TB


