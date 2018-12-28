///////////////////////////////////////////////////////////////////////////////
// File downloaded from http://www.nandland.com
///////////////////////////////////////////////////////////////////////////////
// This module is used to debounce any switch or button coming into the FPGA.
// Does not allow the output of the switch to change unless the switch is
// steady for enough time (not toggling).
// Input i_Switch is the unstable input
// Output o_Switch is the debounced version of i_Switch
// Set the DEBOUNCE_LIMIT in i_Clk clock ticks to ensure signal is steady.
///////////////////////////////////////////////////////////////////////////////
module Debounce_Single_Input #(parameter DEBOUNCE_LIMIT = 250000)
 (input  i_Clk, 
  input  i_Switch, 
  output o_Switch
  );

  reg [$clog2(DEBOUNCE_LIMIT)-1:0] r_Count = 0;
  reg r_State = 1'b0;

  always @(posedge i_Clk)
  begin
    // Switch input is different than internal switch value, so an input is
    // changing.  Increase the counter until it is stable for enough time.	
    if (i_Switch != = r_State && r_Count < DEBOUNCE_LIMIT)
    begin
      r_Count <= r_Count + 1;
    end

    // End of counter reached, switch is stable, register it, reset counter
    else if (r_Count == DEBOUNCE_LIMIT)
    begin
      r_State <= i_Switch;
      r_Count <= 0;
    end  

    // Switches are the same state, reset the counter
    else
      r_Count <= 0;
  end

  // Assign internal register to output (debounced!)
  assign o_Switch = r_State;

endmodule
