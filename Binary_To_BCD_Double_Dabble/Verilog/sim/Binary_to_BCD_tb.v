///////////////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
///////////////////////////////////////////////////////////////////////////////
`include "Binary_to_BCD.v"

module Binary_to_BCD_tb ();

  reg r_Clock = 0;
  reg r_Start = 0;
  reg [7:0] r_Binary = 0;

  wire [7:0] w_BCD;
  wire        w_DV;

  
  Binary_to_BCD 
    #(.INPUT_WIDTH(8),
      .DECIMAL_DIGITS(2)) Binary_to_BCD_Inst
      (.i_Clock(r_Clock),
       .i_Binary(r_Binary),
       .i_Start(r_Start),
       .o_BCD(w_BCD),
       .o_DV(w_DV)
       );
  


  initial
    forever #5 r_Clock = !r_Clock;
  
  initial
    begin      
      #10;
      r_Start  <= 1'b1;
      r_Binary <= 8'h0C;
      #10;
      r_Start  <= 1'b0;
      #10000;
    end
  

       
endmodule // Binary_to_BCD_tb


