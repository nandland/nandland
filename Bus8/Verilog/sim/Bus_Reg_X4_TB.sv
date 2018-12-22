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

  parameter WIDTH = 8;
  parameter [WIDTH-1:0] INIT_00 = 8'h00;
  parameter [WIDTH-1:0] INIT_01 = 8'hAA;
  parameter [WIDTH-1:0] INIT_02 = 8'h55;
  parameter [WIDTH-1:0] INIT_03 = 8'hCD;

  logic r_Bus_Clk = 1'b0, r_Bus_Rst_L = 1'b1;

  logic [WIDTH-1:0] w_Rd_Data;
  logic [WIDTH-1:0] w_Reg_00, w_Reg_01, w_Reg_02, w_Reg_03;
  
  // Clock Generator:
  always #5 r_Bus_Clk = ~r_Bus_Clk;

  // Bus Interface
  Bus_Interface hook(.i_Bus_Clk(r_Bus_Clk));

  // Bus Driver
  Bus_Driver d1 = new(hook);

  // Sim Checker
  Sim_Checker c1 = new("Bus_Reg_X4_TB");
  
  // Instantiate UUT
  Bus8_Reg_X4 #(.INIT_00(INIT_00),
                .INIT_01(INIT_01),
                .INIT_02(INIT_02),
                .INIT_03(INIT_03))
  UUT(
      .i_Bus_Rst_L(r_Bus_Rst_L),
      .i_Bus_Clk(r_Bus_Clk),
      .i_Bus_CS(hook.r_Bus_CS),
      .i_Bus_Wr_Rd_n(hook.r_Bus_Wr_Rd_n),
      .i_Bus_Addr8(hook.r_Bus_Addr8[3:0]),
      .i_Bus_Wr_Data(hook.r_Bus_Wr_Data),
      .o_Bus_Rd_Data(hook.r_Bus_Rd_Data),
      .o_Bus_Rd_DV(hook.r_Bus_Rd_DV),
      //
      .i_Reg_00(w_Reg_00),
      .i_Reg_01(w_Reg_01),
      .i_Reg_02(w_Reg_02),
      .i_Reg_03(8'h00),
      //
      .o_Reg_00(w_Reg_00),
      .o_Reg_01(w_Reg_01),
      .o_Reg_02(),
      .o_Reg_03(w_Reg_03)
      );
  

  initial
    begin
      $display("Clog2(2.5) =  %d", $clog2(20/8));      
      $display("Clog2(2) = %d", $clog2(16/8));      
      $display("Clog2(1) = %d", $clog2(8/8));
      $display("clog2(0) = %d", $clog2(0));
      
      repeat(10) @(posedge r_Bus_Clk);
      r_Bus_Rst_L = 1'b0;
      repeat(10) @(posedge r_Bus_Clk);
      r_Bus_Rst_L = 1'b1;

      c1.t_Set_Printing(1); // Print all Passes and Failures to Console
      d1.t_Bus_Print_Disable(); // Turn off printing of Bus driver
      
      // TEST 1 - Ensure Reg_00 has its default value in it
      d1.t_Bus_Rd(0, w_Rd_Data);
      c1.t_Compare_Two_Inputs(INIT_00, w_Rd_Data);

      // TEST 2 - Ensure Reg_01 has its default value in it    
      d1.t_Bus_Rd(1, w_Rd_Data);
      c1.t_Compare_Two_Inputs(INIT_01, w_Rd_Data);      

      // TEST 3 - Write over default value in Reg_01 then read it back again
      d1.t_Bus_Wr(1, 8'h7B);
      d1.t_Bus_Rd(1, w_Rd_Data);
      c1.t_Compare_Two_Inputs(8'h7B, w_Rd_Data);

      // TEST 4 - Reg_02 is a SW Read Only Register.
      // It gets rewritten over its default value
      d1.t_Bus_Rd(2, w_Rd_Data);
      c1.t_Compare_Two_Inputs(w_Reg_02, w_Rd_Data);

      // TEST 5 - Reg_02 is Read only, so try to write to it and make sure
      // old value is still retained in the register
      d1.t_Bus_Wr(2, 8'hEF);
      d1.t_Bus_Rd(2, w_Rd_Data);
      c1.t_Compare_Two_Inputs(w_Reg_02, w_Rd_Data);
      
      // TEST 6 - Reg_03 is Write only Reg, it should always read back zero
      d1.t_Bus_Rd(3, w_Rd_Data);
      c1.t_Compare_Two_Inputs(0, w_Rd_Data);

      // TEST 6 - Write over the default value then make sure that readback 
      // only has 0, since it's a write-only register
      d1.t_Bus_Wr(3, 8'h12);
      d1.t_Bus_Rd(3, w_Rd_Data);
      c1.t_Compare_Two_Inputs(0, w_Rd_Data);

      c1.t_Print_Results();

      $finish();
      
    end // initial begin
  
endmodule // Bus_Reg_X4_TB


