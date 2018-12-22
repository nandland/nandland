///////////////////////////////////////////////////////////////////////////////
// File Downloaded from Nandland.com
///////////////////////////////////////////////////////////////////////////////

`include "carry_lookahead_adder.v"

module carry_lookahead_adder_tb ();

  parameter WIDTH = 3;

  reg [WIDTH-1:0] r_ADD_1 = 0;
  reg [WIDTH-1:0] r_ADD_2 = 0;
  wire [WIDTH:0]  w_RESULT;
  
  carry_lookahead_adder #(.WIDTH(WIDTH)) carry_lookahead_inst
    (
     .i_add1(r_ADD_1),
     .i_add2(r_ADD_2),
     .o_result(w_RESULT)
     );

  initial
    begin
      #10;
      r_ADD_1 = 3'b000;
      r_ADD_2 = 3'b001;
      #10;
      r_ADD_1 = 3'b010;
      r_ADD_2 = 3'b010;
      #10;
      r_ADD_1 = 3'b101;
      r_ADD_2 = 3'b110;
      #10;
      r_ADD_1 = 3'b111;
      r_ADD_2 = 3'b111;
      #10;
    end

endmodule // carry_lookahead_adder_tb


