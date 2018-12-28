//////////////////////////////////////////////////////////////////////////////
// Performs CRC-16-CCITT on input bytes.
// Polynomial is f(x) = x^16+x^12+x^5+1
// In FPGA it's a linear feedback shift register (LFSR).
// Set i_Init to initialize CRC to 0xFFFF (initial value).
//
// This testbench will drive ASCII 1-9 in order to the CRC
// calculator.  Note that data bytes are driven non-consecutively
// in clock cycles.  This tests out the i_DV input.
//
// Expected CRC is 0x29B1
//////////////////////////////////////////////////////////////////////////////
module CRC_16_CCITT_Parallel_TB();

  import CRC_Pkg::*;

  CRC_Class CRC_Sim = new();
  
  logic r_Init = 0;
  logic r_Clk = 0;
  logic r_DV = 0;
  logic r_Rst_n = 1'b0; // start in reset
  logic [15:0] w_CRC, w_CRC_Reversed_Xor;
  logic [7:0]  r_Data = 8'h30;
  logic [15:0] Result;
  integer ii;

  CRC_16_CCITT_Parallel UUT 
    (.i_Clk(r_Clk),
     .i_Rst_n(r_Rst_n),
     .i_Init(r_Init),
     .i_DV(r_DV),
     .i_Data(r_Data),
     .o_CRC(w_CRC),
     .o_CRC_Reversed_Xor(w_CRC_Reversed_Xor)
     );

  // Clock Generator:
  always #2 r_Clk = ~r_Clk;
  
  initial
    begin
      #100 r_Rst_n <= 1'b1; // Release Reset

      // Initialize CRC prior to sending new data.
      @(posedge r_Clk);
      r_Init <= 1'b1;
      @(posedge r_Clk);
      r_Init <= 1'b0;

      for (ii=0; ii<8; ii++)
      begin
        @(posedge r_Clk);
        r_DV   <= 1'b1;
        r_Data <= r_Data + 1;
        $display("Value of CRC is %h", w_CRC);
      end

      @(posedge r_Clk);
      r_DV <= 1'b0;
      repeat (10) @(posedge r_Clk);
      r_DV   <= 1'b1;
      r_Data <= r_Data + 1;
      $display("Value of CRC is %h", w_CRC);
      @(posedge r_Clk);
      r_DV <= 1'b0;
      @(posedge r_Clk);
      @(posedge r_Clk);
      $display("Final value of CRC is %h", w_CRC);

/*      @(posedge r_Clk);
      r_Init <= 1'b1;
      repeat (10) @(posedge r_Clk);
*/
      CRC_Sim.Init();
      for (ii=8'h31; ii<8'h3A; ii++)
      begin
        //$display("Byte %h CRC %h", ii, CRC_Sim.GetCrc());
	CRC_Sim.AddByteSerial(ii);
      end
      $display("Final Value using Serial Forward %h", CRC_Sim.GetCrc());      

      CRC_Sim.Init();
      for (ii=8'h31; ii<8'h3A; ii++)
      begin
	CRC_Sim.AddByteSerial(ReverseBits(ii));
      end
      $display("Final Value using Serial Reverse %h", CRC_Sim.GetCrc());

      CRC_Sim.Init();
      for (ii=8'h31; ii<8'h3A; ii++)
      begin
	CRC_Sim.AddByteParallel(ii);
      end
      $display("Final Value using Parallel Forward %h", CRC_Sim.GetCrc()); 

      CRC_Sim.Init();
      for (ii=8'h31; ii<8'h3A; ii++)
      begin
	CRC_Sim.AddByteParallel(ReverseBits(ii));
      end
      $display("Final Value using Parallel Reverse %h", CRC_Sim.GetCrc());

      // Add testing here for debug
      CRC_Sim.Init();
      CRC_Sim.AddByteParallel(8'h45);
      CRC_Sim.AddByteParallel(8'h53);
      Result = CRC_Sim.GetCrc();
      $display("Serial Normal: %h, Backwards %h%h", Result, ReverseBits(Result[15:8]), ReverseBits(Result[7:0]));

      // REVERSED INPUTS
      CRC_Sim.Init();
      CRC_Sim.AddByteParallel(ReverseBits(8'h45));
      CRC_Sim.AddByteParallel(ReverseBits(8'h53));
      Result  = CRC_Sim.GetCrc();
      $display("Reversed Inputs:");
      $display("Normal: %h, Backwards %h%h", Result, ReverseBits(Result[15:8]), ReverseBits(Result[7:0]));

      CRC_Sim.Init();
      CRC_Sim.AddByteParallel(ReverseBits(8'h45));
      CRC_Sim.AddByteParallel(ReverseBits(8'h53));
      CRC_Sim.ReverseFinalCrc();
      CRC_Sim.XorFinalCrc();
      Result  = CRC_Sim.GetCrc();
      $display("God please work:");
      $display("Be 0x5787: %h", Result);


      // Initialize CRC prior to sending new data.
      @(posedge r_Clk);
      r_Init <= 1'b1;
      @(posedge r_Clk);
      r_Init <= 1'b0;

      // Send Reversed 0x45 0x53
      @(posedge r_Clk);
      r_DV   <= 1'b1;
      r_Data <= ReverseBits(8'h45);
      @(posedge r_Clk);      
      r_DV   <= 1'b1;
      r_Data <= ReverseBits(8'h53);      
      @(posedge r_Clk);      
      r_DV   <= 1'b0;
      @(posedge r_Clk);

      $display("Be 0x5787 Please: %h", w_CRC_Reversed_Xor);

    end

  function [7:0] ReverseBits(input logic [7:0] data);
    automatic logic [7:0] temp = data, ii=0;
    for (ii=0; ii<8; ii=ii+1)
    begin
      temp[ii] = data[7-ii];
    end
    return temp;
  endfunction // ReverseBits

  

endmodule // CRC_16_CCITT_Parallel_TB
