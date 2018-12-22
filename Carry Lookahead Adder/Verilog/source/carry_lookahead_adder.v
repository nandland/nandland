///////////////////////////////////////////////////////////////////////////////
// File Downloaded from Nandland.com
///////////////////////////////////////////////////////////////////////////////

`include "module_full_adder.v"

module carry_lookahead_adder
  #(parameter WIDTH)
  (
   input [WIDTH-1:0] i_add1,
   input [WIDTH-1:0] i_add2,
   output [WIDTH:0]  o_result
   );
    
  wire [WIDTH:0]     w_C;
  wire [WIDTH-1:0]   w_G, w_P, w_SUM;

  // Create the Full Adders
  genvar             ii;
  generate
    for (ii=0; ii<WIDTH; ii=ii+1) 
      begin
        module_full_adder full_adder_inst
            ( 
              .i_bit1(i_add1[ii]),
              .i_bit2(i_add2[ii]),
              .i_carry(w_C[ii]),
              .o_sum(w_SUM[ii]),
              .o_carry()
              );
      end
  endgenerate

  // Create the Generate (G) Terms:  Gi=Ai*Bi
  // Create the Propagate Terms: Pi=Ai+Bi
  // Create the Carry Terms:
  genvar             jj;
  generate
    for (jj=0; jj<WIDTH; jj=jj+1) 
      begin
        assign w_G[jj]   = i_add1[jj] & i_add2[jj];
        assign w_P[jj]   = i_add1[jj] | i_add2[jj];
        assign w_C[jj+1] = w_G[jj] | (w_P[jj] & w_C[jj]);
      end
  endgenerate
  
  assign w_C[0] = 1'b0; // no carry input on first adder

  assign o_result = {w_C[WIDTH], w_SUM};   // Verilog Concatenation

endmodule // carry_lookahead_adder

