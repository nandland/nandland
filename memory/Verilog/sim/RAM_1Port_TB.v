// Russell Merrick - http://www.nandland.com
//
// Single Port RAM testbench.

module RAM_1Port_TB ();

  localparam DEPTH = 4;
  localparam WIDTH = 8;

  reg r_Clk = 1'b0;
  reg r_Wr_DV = 1'b0, r_Rd_En = 1'b0;
  reg [$clog2(DEPTH)-1:0] r_Addr = 0;
  reg [WIDTH-1:0] r_Wr_Data = 0;
  wire [WIDTH-1:0] w_Rd_Data;
  
  always #10 r_Clk <= !r_Clk; // create oscillating clock

  RAM_1Port #(.WIDTH(WIDTH), .DEPTH(DEPTH)) UUT 
  (.i_Clk(r_Clk),
   .i_Addr(r_Addr),
   .i_Wr_DV(r_Wr_DV),
   .i_Wr_Data(r_Wr_Data),
   .i_Rd_En(r_Rd_En),
   .o_Rd_DV(w_Rd_DV),
   .o_Rd_Data(w_Rd_Data)
   );

  initial
  begin 
    $dumpfile("dump.vcd"); $dumpvars; // for EDA Playground sim
    
    repeat(4) @(posedge r_Clk); // Give simulation a few clocks to start

    // Fill memory with incrementing pattern
    repeat(DEPTH)
    begin
      r_Wr_DV <= 1'b1;
      @(posedge r_Clk);
      r_Wr_Data <= r_Wr_Data + 1;
      r_Addr    <= r_Addr + 1;
    end

    // Read out incrementing pattern
    r_Addr  <= 0;
    r_Wr_DV <= 1'b0;
    
    repeat(DEPTH)
    begin
      r_Rd_En <= 1'b1;
      @(posedge r_Clk);
      r_Addr <= r_Addr + 1;
	  end
    r_Rd_En <= 0'b1;

    repeat(4) @(posedge r_Clk); // Give simulation a few clocks to end

    $finish();
  end

endmodule
