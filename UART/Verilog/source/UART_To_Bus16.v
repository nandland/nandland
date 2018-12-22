///////////////////////////////////////////////////////////////////////////////
// Engineer:    Russell Merrick
// Description: Creates an interface from a UART to the 16-bit wide Bus
//              Allows reading and writing of registers.
//              Module uses 16-bit read/write data, Addr uses byte-indexing
//
//              Commands:
//              rd {4 Hex Digit Addr} {CR}
//              Will perform a Bus Read and report the data back.
//              wr {4 Hex Digit Addr} {4 Digit Hex Data} {CR}
//              Will perform a Bus Write of the input data.
//              e.g.
//              rd 14 {CR} reads from addr 0x14
//              wr 5A 6 {CR} writes 0x6 to addr 0x5A
//
// Note:        This module will only assert ONE chip-select!  If UART needs
//              to talk to multiple modules, chip-select decoding must be
//              done at a higher level.
//
// Parameters:  CLKS_PER_BIT - Set to (Bus Clk Freq)/(UART Freq)
//              Example: 25 MHz Bus Clock, 115200 baud UART
//              (25000000)/(115200) = 217
//////////////////////////////////////////////////////////////////////////////


module UART_To_Bus16 #(parameter CLKS_PER_BIT = 217)
  (input             i_Bus_Rst_L,
   input             i_Bus_Clk,
   output reg        o_Bus_CS,
   output reg        o_Bus_Wr_Rd_n,
   output reg [15:0] o_Bus_Addr8,
   output reg [15:0] o_Bus_Wr_Data,
   input [15:0]      i_Bus_Rd_Data,
   input             i_Bus_Rd_DV,
   //
   input             i_UART_RX,
   output            o_TX_Active,
   output            o_TX_Data);

  // Put in a better location
  localparam ASCII_BS = 8'h8;
  localparam ASCII_LF = 8'hA;
  localparam ASCII_CR = 8'hD;
  localparam ASCII_Sp = 8'h20;
  localparam ASCII_Ep = 8'h21;
  localparam ASCII_0  = 8'h30;
  localparam ASCII_1  = 8'h31;
  localparam ASCII_2  = 8'h32;
  localparam ASCII_3  = 8'h33;
  localparam ASCII_4  = 8'h34;
  localparam ASCII_5  = 8'h35;
  localparam ASCII_6  = 8'h36;
  localparam ASCII_7  = 8'h37;
  localparam ASCII_8  = 8'h38;
  localparam ASCII_9  = 8'h39;
  localparam ASCII_a  = 8'h61;
  localparam ASCII_b  = 8'h62;
  localparam ASCII_c  = 8'h63;
  localparam ASCII_d  = 8'h64;
  localparam ASCII_e  = 8'h65;
  localparam ASCII_f  = 8'h66;
  localparam ASCII_g  = 8'h67;
  localparam ASCII_h  = 8'h68;
  localparam ASCII_i  = 8'h69;
  localparam ASCII_j  = 8'h6A;
  localparam ASCII_k  = 8'h6B;
  localparam ASCII_l  = 8'h6C;
  localparam ASCII_m  = 8'h6D;
  localparam ASCII_n  = 8'h6E;
  localparam ASCII_o  = 8'h6F;
  localparam ASCII_p  = 8'h70;
  localparam ASCII_q  = 8'h71;
  localparam ASCII_r  = 8'h72;
  localparam ASCII_s  = 8'h73;
  localparam ASCII_t  = 8'h74;
  localparam ASCII_u  = 8'h75;
  localparam ASCII_v  = 8'h76;
  localparam ASCII_w  = 8'h77;
  localparam ASCII_x  = 8'h78;
  localparam ASCII_y  = 8'h79;
  localparam ASCII_z  = 8'h7A;
  localparam ASCII_A  = 8'h41;
  localparam ASCII_B  = 8'h42;
  localparam ASCII_C  = 8'h43;
  localparam ASCII_D  = 8'h44;
  localparam ASCII_E  = 8'h45;
  localparam ASCII_F  = 8'h46;
  localparam ASCII_G  = 8'h47;
  localparam ASCII_H  = 8'h48;
  localparam ASCII_I  = 8'h49;
  localparam ASCII_J  = 8'h4A;
  localparam ASCII_K  = 8'h4B;
  localparam ASCII_L  = 8'h4C;
  localparam ASCII_M  = 8'h4D;
  localparam ASCII_N  = 8'h4E;
  localparam ASCII_O  = 8'h4F;
  localparam ASCII_P  = 8'h50;
  localparam ASCII_Q  = 8'h51;
  localparam ASCII_R  = 8'h52;
  localparam ASCII_S  = 8'h53;
  localparam ASCII_T  = 8'h54;
  localparam ASCII_U  = 8'h55;
  localparam ASCII_V  = 8'h56;
  localparam ASCII_W  = 8'h57;
  localparam ASCII_X  = 8'h58;
  localparam ASCII_Y  = 8'h59;
  localparam ASCII_Z  = 8'h5A;

  localparam CMD_MAX = 12;

  // State Machine States
  localparam IDLE          = 3'b000;
  localparam TX_START      = 3'b001;
  localparam TX_WAIT_READY = 3'b010;
  localparam TX_DONE       = 3'b011;
  localparam TX_WAIT_DONE  = 3'b100;

  reg [2:0] r_SM_Main;

  // TX/RX Command Signals
  reg [7:0]  r_RX_Cmd_Array[0:CMD_MAX-1], r_TX_Cmd_Array[0:CMD_MAX-1];
  reg        r_RX_Cmd_Done;
  reg        r_RX_Cmd_Rd, r_RX_Cmd_Wr;
  reg        r_RX_Cmd_Error;
  reg [15:0] r_RX_Cmd_Addr;
  reg [15:0] r_RX_Cmd_Data;
  reg        r_TX_Cmd_Start;
  reg [3:0]  r_Temp_Index;


  reg [$clog2(CMD_MAX)-1:0] r_RX_Index;
  reg [$clog2(CMD_MAX)-1:0] r_TX_Index;
  reg [$clog2(CMD_MAX)-1:0] r_TX_Cmd_Length;
  reg [$clog2(CMD_MAX)-1:0] r_RX_Cmd_Length;

  // Low Level UART TX/RX Signals
  wire       w_RX_DV;
  wire [7:0] w_RX_Byte;
  wire       w_TX_Done;
  wire       w_TX_Active;
  wire [7:0] w_TX_Byte_Mux;
  reg        r_TX_DV;
  reg  [7:0] r_TX_Byte;

  
  // Convert ASCII digit to Hex (upper and lowercase supported)
  // No error checking on invalid inputs.
  function [3:0] f_ASCII_To_Hex;
    input [7:0] i_ASCII;
    begin
      if (i_ASCII == ASCII_a || i_ASCII == ASCII_A)
        f_ASCII_To_Hex = 4'hA;
      else if (i_ASCII == ASCII_b || i_ASCII == ASCII_B)
        f_ASCII_To_Hex = 4'hB;
      else if (i_ASCII == ASCII_c || i_ASCII == ASCII_C)
        f_ASCII_To_Hex = 4'hC;
      else if (i_ASCII == ASCII_d || i_ASCII == ASCII_D)
        f_ASCII_To_Hex = 4'hD;
      else if (i_ASCII == ASCII_e || i_ASCII == ASCII_E)
        f_ASCII_To_Hex = 4'hE;
      else if (i_ASCII == ASCII_f || i_ASCII == ASCII_F)
        f_ASCII_To_Hex = 4'hF;
      else
        f_ASCII_To_Hex = i_ASCII[3:0];
    end
  endfunction


  // Convert 4-bit Hex Digit to ASCII digit/letter (lowercase)
  function [7:0] f_Hex_To_ASCII;
    input [3:0] i_Hex;
    begin
      if (i_Hex == 4'hA)
        f_Hex_To_ASCII = ASCII_a;
      else if (i_Hex == 4'hB)
        f_Hex_To_ASCII = ASCII_b;
      else if (i_Hex == 4'hC)
        f_Hex_To_ASCII = ASCII_c;
      else if (i_Hex == 4'hD)
        f_Hex_To_ASCII = ASCII_d;
      else if (i_Hex == 4'hE)
        f_Hex_To_ASCII = ASCII_e;
      else if (i_Hex == 4'hF)
        f_Hex_To_ASCII = ASCII_f;
      else
        f_Hex_To_ASCII = {4'h3, i_Hex[3:0]};
    end
  endfunction



  UART_RX #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_RX_Inst
    (.i_Rst_L(i_Bus_Rst_L),
     .i_Clock(i_Bus_Clk),
     .i_RX_Serial(i_UART_RX),
     .o_RX_DV(w_RX_DV),
     .o_RX_Byte(w_RX_Byte)
     );

  UART_TX #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_TX_Inst
    (.i_Rst_L(i_Bus_Rst_L),
     .i_Clock(i_Bus_Clk),
     .i_TX_DV(r_TX_DV | w_RX_DV),
     .i_TX_Byte(w_TX_Byte_Mux),
     .o_TX_Active(w_TX_Active),
     .o_TX_Serial(o_TX_Data),
     .o_TX_Done(w_TX_Done)
     );

  assign w_TX_Byte_Mux = w_RX_DV ? w_RX_Byte : r_TX_Byte;

  // Purpose: Buffer up a received command.  Will assert done signal when an
  // ASCII line feed is received via the UART.
  always @(posedge i_Bus_Clk or negedge i_Bus_Rst_L)
  begin
    if (~i_Bus_Rst_L)
    begin
      r_RX_Index <= 0;
    end
    else
    begin
      r_RX_Cmd_Done <= 1'b0; // Default Assignment

      if (w_RX_DV == 1'b1)
      begin
        r_RX_Cmd_Array[r_RX_Index] <= w_RX_Byte;

        // See if most recently received command is CR (Command Done)
        if (w_RX_Byte == ASCII_CR)
        begin
          r_RX_Cmd_Done   <= 1'b1;
          r_RX_Index      <= 0;
          r_RX_Cmd_Length <= r_RX_Index;
        end

        // See if most recently received comamnd is Backspace
        // If so, move pointer backward
        else if (w_RX_Byte == ASCII_BS)
          r_RX_Index    <= r_RX_Index - 1;

        // Normal Data
        else
          r_RX_Index    <= r_RX_Index + 1;
      end // if (w_RX_DV == 1'b1)
    end // else: !if(~i_Bus_Rst_L)
  end // always @ (posedge i_Bus_Clk or negedge i_Bus_Rst_L)



  // Decode received command.  Parses command and acts accordingly.
  always @(posedge i_Bus_Clk or negedge i_Bus_Rst_L)
  begin
    if (~i_Bus_Rst_L)
    begin
      r_RX_Cmd_Rd    <= 1'b0;
      r_RX_Cmd_Wr    <= 1'b0;
      r_RX_Cmd_Error <= 1'b0;
    end

    else
    begin
      // Default Assignments
      r_RX_Cmd_Rd    <= 1'b0;
      r_RX_Cmd_Wr    <= 1'b0;
      r_RX_Cmd_Error <= 1'b0;

      if (r_RX_Cmd_Done == 1'b1)
      begin

        // Decode Read Command
        if (r_RX_Cmd_Array[0] == ASCII_r &&
            r_RX_Cmd_Array[1] == ASCII_d &&
            r_RX_Cmd_Array[2] == ASCII_Sp)
          r_RX_Cmd_Rd <= 1'b1;

        // Decode Write Command
        else if (r_RX_Cmd_Array[0] == ASCII_w &&
                 r_RX_Cmd_Array[1] == ASCII_r &&
                 r_RX_Cmd_Array[2] == ASCII_Sp)
          r_RX_Cmd_Wr <= 1'b1;

        // Decode Failed, Erroneous Command
        else
          r_RX_Cmd_Error <= 1'b1;


        // Can parse addresses that are 1-4 digits long
        if (r_RX_Cmd_Array[4] == ASCII_Sp || r_RX_Cmd_Array[4] == ASCII_CR)
        begin
          r_Temp_Index  = 5; 
          r_RX_Cmd_Addr <= {12'h0, f_ASCII_To_Hex(r_RX_Cmd_Array[3])};
        end
        else if (r_RX_Cmd_Array[5] == ASCII_Sp || r_RX_Cmd_Array[5] == ASCII_CR)
        begin
          r_Temp_Index  = 6;
          r_RX_Cmd_Addr <= {8'h0, f_ASCII_To_Hex(r_RX_Cmd_Array[3]), 
                                  f_ASCII_To_Hex(r_RX_Cmd_Array[4])};
        end
        else if (r_RX_Cmd_Array[6] == ASCII_Sp || r_RX_Cmd_Array[6] == ASCII_CR)
        begin
          r_Temp_Index  = 7;
          r_RX_Cmd_Addr <= {4'h0, f_ASCII_To_Hex(r_RX_Cmd_Array[3]), 
                                  f_ASCII_To_Hex(r_RX_Cmd_Array[4]), 
                                  f_ASCII_To_Hex(r_RX_Cmd_Array[5])};
        end
        else
        begin
          r_Temp_Index  = 8; 
          r_RX_Cmd_Addr <= {f_ASCII_To_Hex(r_RX_Cmd_Array[3]),
                            f_ASCII_To_Hex(r_RX_Cmd_Array[4]),
                            f_ASCII_To_Hex(r_RX_Cmd_Array[5]),
                            f_ASCII_To_Hex(r_RX_Cmd_Array[6])};
        end

        if ($unsigned(r_RX_Cmd_Length)-$unsigned(r_Temp_Index) == 4)
          r_RX_Cmd_Data <= {f_ASCII_To_Hex(r_RX_Cmd_Array[r_Temp_Index]),
                            f_ASCII_To_Hex(r_RX_Cmd_Array[r_Temp_Index+1]),
                            f_ASCII_To_Hex(r_RX_Cmd_Array[r_Temp_Index+2]),
                            f_ASCII_To_Hex(r_RX_Cmd_Array[r_Temp_Index+3])};

        else if ($unsigned(r_RX_Cmd_Length)-$unsigned(r_Temp_Index) == 3)
          r_RX_Cmd_Data <= {4'h0, 
                            f_ASCII_To_Hex(r_RX_Cmd_Array[r_Temp_Index]),
                            f_ASCII_To_Hex(r_RX_Cmd_Array[r_Temp_Index+1]),
                            f_ASCII_To_Hex(r_RX_Cmd_Array[r_Temp_Index+2])};

        else if ($unsigned(r_RX_Cmd_Length)-$unsigned(r_Temp_Index) == 2)
          r_RX_Cmd_Data <= {4'h0, 4'h0,  
                            f_ASCII_To_Hex(r_RX_Cmd_Array[r_Temp_Index]),
                            f_ASCII_To_Hex(r_RX_Cmd_Array[r_Temp_Index+1])};

        else 
          r_RX_Cmd_Data <= {4'h0, 4'h0, 4'h0,
                            f_ASCII_To_Hex(r_RX_Cmd_Array[r_Temp_Index])};


      end // if (r_RX_Cmd_Done == 1'b1)
    end // else: !if(~i_Bus_Rst_L)
  end // always @ (posege i_Bus_Clk or negedge i_Bus_Rst_L)


  // Perform a read or write to Bus based on cmd from UART
  always @(posedge i_Bus_Clk or negedge i_Bus_Rst_L)
  begin
    if (~i_Bus_Rst_L)
    begin
      o_Bus_CS <= 1'b0;
    end

    else
    begin
      o_Bus_Addr8 <= r_RX_Cmd_Addr;

      if (r_RX_Cmd_Rd == 1'b1)
      begin
        o_Bus_CS      <= 1'b1;
        o_Bus_Wr_Rd_n <= 1'b0;
      end

      else if (r_RX_Cmd_Wr == 1'b1)
      begin
        o_Bus_CS      <= 1'b1;
        o_Bus_Wr_Rd_n <= 1'b1;
        o_Bus_Wr_Data <= r_RX_Cmd_Data;
      end
      else
      begin
        o_Bus_CS      <= 1'b0;
      end // else: !if(r_RX_Cmd_Wr == 1'b1)
    end // else: !if(~i_Bus_Rst_L)
  end // always @ (posege i_Bus_Clk or negedge i_Bus_Rst_L)


  // Form a command response to a Received Command
  always @(posedge i_Bus_Clk or negedge i_Bus_Rst_L)
  begin
    if (~i_Bus_Rst_L)
    begin
      r_TX_Cmd_Start <= 1'b0;
    end

    else
    begin
      r_TX_Cmd_Start <= 1'b0;

      // Erroneous Command Response
      if (r_RX_Cmd_Error == 1'b1)
      begin
        r_TX_Cmd_Array[0] <= ASCII_LF;
        r_TX_Cmd_Array[1] <= ASCII_e;
        r_TX_Cmd_Array[2] <= ASCII_r;
        r_TX_Cmd_Array[3] <= ASCII_r;
        r_TX_Cmd_Array[4] <= ASCII_Sp;
        r_TX_Cmd_Array[5] <= ASCII_CR;
        r_TX_Cmd_Array[6] <= ASCII_LF;
        r_TX_Cmd_Array[7] <= ASCII_LF;
        r_TX_Cmd_Length   <= 8;
        r_TX_Cmd_Start    <= 1'b1;
      end // if (r_RX_Cmd_Error == 1'b1)

      // Read Command Response
      else if (i_Bus_Rd_DV == 1'b1)
      begin
        r_TX_Cmd_Array[0] <= ASCII_LF;
        r_TX_Cmd_Array[1] <= ASCII_0;
        r_TX_Cmd_Array[2] <= ASCII_x;
        r_TX_Cmd_Array[3] <= f_Hex_To_ASCII(i_Bus_Rd_Data[15:12]);
        r_TX_Cmd_Array[4] <= f_Hex_To_ASCII(i_Bus_Rd_Data[11:8]);
        r_TX_Cmd_Array[5] <= f_Hex_To_ASCII(i_Bus_Rd_Data[7:4]);
        r_TX_Cmd_Array[6] <= f_Hex_To_ASCII(i_Bus_Rd_Data[3:0]);
        r_TX_Cmd_Array[7] <= ASCII_CR;
        r_TX_Cmd_Array[8] <= ASCII_LF;
        r_TX_Cmd_Array[9] <= ASCII_LF;
        r_TX_Cmd_Length   <= 10;
        r_TX_Cmd_Start    <= 1'b1;
      end // if (i_Bus_Rd_DV == 1'b1)

      // Write Command Response
      else if (r_RX_Cmd_Wr == 1'b1)
      begin
        r_TX_Cmd_Array[0] <= ASCII_CR;
        r_TX_Cmd_Array[1] <= ASCII_LF;
        r_TX_Cmd_Array[2] <= ASCII_LF;
        r_TX_Cmd_Length   <= 3;
        r_TX_Cmd_Start    <= 1'b1;
      end
    end // else: !if(~i_Bus_Rst_L)
  end // always @ (posege i_Bus_Clk or negedge i_Bus_Rst_L)


  // Simple State Machine to Transmit a command.
  always @(posedge i_Bus_Clk or negedge i_Bus_Rst_L)
  begin
    if (~i_Bus_Rst_L)
    begin
      r_SM_Main <= IDLE;
      r_TX_DV   <= 1'b0;
    end

    else
    begin

      // Default Assignments
      r_TX_DV <= 1'b0;

      case (r_SM_Main)
      IDLE :
        begin
          r_TX_Index <= 0;
          if (r_TX_Cmd_Start == 1'b1)
            r_SM_Main <= TX_WAIT_READY;
        end

      TX_WAIT_READY :
        begin
          if (w_TX_Active == 1'b0)
            r_SM_Main <= TX_START;
        end

      TX_START :
        begin
          r_TX_DV   <= 1'b1;
          r_TX_Byte <= r_TX_Cmd_Array[r_TX_Index];
          r_SM_Main <= TX_WAIT_DONE;
        end

      TX_WAIT_DONE :
        begin
          if (w_TX_Done == 1'b1)
          begin
            if (r_TX_Index == r_TX_Cmd_Length-1)
            begin
              r_SM_Main  <= TX_DONE;
            end
            else
            begin
              r_TX_Index <= r_TX_Index + 1;
              r_SM_Main  <= TX_START;
            end
          end // if (w_TX_Done == 1'b1)
        end // case: TX_WAIT_DONE

      TX_DONE :
        r_SM_Main <= IDLE;
          
      default :
        r_SM_Main <= IDLE;

      endcase

      end // else: !if(~i_Bus_Rst_L)
  end // always @ (posege i_Bus_Clk or negedge i_Bus_Rst_L)


  assign o_TX_Active = w_TX_Active;

endmodule // UART_To_Bus16
