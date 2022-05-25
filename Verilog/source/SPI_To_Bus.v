///////////////////////////////////////////////////////////////////////////////
// Description: SPI To Local Bus
//              Main Command and Control Interface
//              Parses the SPI Interface and relays read and write
//              commands over the Local Bus interface.
// 
//              Note that due to a shortcoming in Verilog 2001, this module is 
//              currently hardcoded to use 4 chip-selects.
//
// Parameters:  ADDR8_PER_CS - Set to the number of byte addresses that are
//              supported for each chip-select on the FPGA.
//              This is almost always going to be set to 16 bits (65536).
//////////////////////////////////////////////////////////////////////////////

module SPI_To_Local_Bus
  #(parameter ADDR8_PER_CS = 65536)
  (
   // SPI Interface to Micro
   input      i_SPI_Clk_SW,
   output reg o_SPI_MISO_SW,
   input      i_SPI_MOSI_SW,
   input      i_SPI_CS_n_SW,

   // Local Bus Interface to FPGA
   input         i_Bus_Clk,
   output [3:0]  o_Bus_CS_Array, // Up to 4 chip selects supported (currently)
   output reg    o_Bus_Wr_Rd_n,
   output [$clog2(ADDR8_PER_CS)-1:0] o_Bus_Addr8,
   output [15:0] o_Bus_Wr_Data,
   input [15:0]  i_Bus_Rd_Data_CS0,
   input [15:0]  i_Bus_Rd_Data_CS1,
   input [15:0]  i_Bus_Rd_Data_CS2,
   input [15:0]  i_Bus_Rd_Data_CS3,
   input [3:0]   i_Bus_Rd_DV_Array,
   // debug:
   output [3:0] o_SM_Main,
   output reg [7:0] o_Debug_Byte,
   output reg [3:0] o_Debug_Count
   );

  parameter CMD_RD = 1;   // Read Command Type
  parameter CMD_WR = 2;   // Write Command Type
  parameter WD_LIMIT = 3; // Watchdog

  parameter IDLE                 = 4'b0000;
  parameter GET_ADDR_LOWER       = 4'b0001;
  parameter GET_ADDR_UPPER       = 4'b0010;
  parameter GET_WRITE_DATA_LOWER = 4'b0011;
  parameter GET_WRITE_DATA_UPPER = 4'b0100;
  parameter BUS_WRITE            = 4'b0101;
  parameter INCR_ADDR            = 4'b0110;
  parameter BUS_READ             = 4'b0111;
  parameter SEND_READ_DATA_LOWER = 4'b1000;
  parameter SEND_READ_DATA_UPPER = 4'b1001;
  parameter ERROR                = 4'b1010;

  reg [3:0] r_SM_Main;

  // SPI Interface (All Runs at SPI Clock Domain)
  reg [2:0]  r_SPI_RX_Bit_Count;
  reg [3:0]  r_SPI_TX_Bit_Count;
  reg [7:0]  r_Temp_RX_Byte;
  reg [15:0] r_Temp_Rd_Data;
  reg [7:0]  r_SPI_RX_Byte;
  reg r_SPI_RX_Done, r2_SPI_RX_Done, r3_SPI_RX_Done;
  reg [15:0] r_SPI_TX_Data;

  reg r_Byte_DV;
  reg [7:0]  r_Byte_Data;
  reg [3:0]  r_Cmd_Type;
  reg [15:0] r_Cmd_Addr8;

  reg [1:0] r_CS_Index;
  
  // Local Bus Signals
  reg [15:0] r_Bus_Rd_Data;
  reg [3:0]  r_Bus_CS_Array;
  reg [15:0] r_Bus_Wr_Data;

  // Watchdog Signals
  wire w_WD_Expired;
  reg [$clog2(WD_LIMIT):0] r_WD_Count;


  //DEBUG REMOVE ME
  assign o_SM_Main  = r_SM_Main;


  always @(posedge i_Bus_Clk)
  begin
    if (r_Byte_DV)
      o_Debug_Count <= o_Debug_Count + 1;
  end

  always @(posedge i_Bus_Clk)
  begin
    if (r_Byte_DV)
      o_Debug_Byte <= r_Bus_Rd_Data[7:0];
    // o_Debug_Byte <= r_Byte_Data; // shows write data on 7-seg

  end



  // Purpose: Recover SPI Byte in SPI Clock Domain
  // Samples line on falling edge of SPI Clock
  always @(negedge i_SPI_Clk_SW or posedge i_SPI_CS_n_SW)
  begin
    if (i_SPI_CS_n_SW)
    begin
      r_SPI_RX_Bit_Count <= 0;
      r_SPI_RX_Done      <= 1'b0;
    end
    else
    begin
      r_SPI_RX_Bit_Count <= r_SPI_RX_Bit_Count + 1;

      // Receive in LSB, shift up to MSB
      r_Temp_RX_Byte <= {r_Temp_RX_Byte[6:0], i_SPI_MOSI_SW};
    
      if (r_SPI_RX_Bit_Count == 3'b111)
      begin
        r_SPI_RX_Done <= 1'b1;
        r_SPI_RX_Byte <= {r_Temp_RX_Byte[6:0], i_SPI_MOSI_SW};
      end

      else if (r_SPI_RX_Bit_Count == 3'b010)
        r_SPI_RX_Done <= 1'b0;
    end // else: !if(i_SPI_CS_n_SW)
  end // always @ (negedge i_SPI_Clk_SW or posedge i_SPI_CS_n_SW)




  // Purpose: Transmits 2 SPI Bytes whenever SPI clock is toggling
  // Will transmit read data back to SW over MISO line.
  // Always works on 2 bytes, SW will never read just 1 byte.
  always @(posedge i_SPI_Clk_SW or posedge i_SPI_CS_n_SW)
  begin
    if (i_SPI_CS_n_SW)
    begin
      r_SPI_TX_Bit_Count <= 4'b1111;
      o_SPI_MISO_SW      <= 1'b1;
    end
    else
    begin
      r_SPI_TX_Bit_Count <= r_SPI_TX_Bit_Count - 1;

      if (r_SPI_TX_Bit_Count == 4'b0000)
      begin
        r_SPI_TX_Data <= r_Temp_Rd_Data;
      end

      o_SPI_MISO_SW <= r_SPI_TX_Data[r_SPI_TX_Bit_Count];
    end // else: !if(i_SPI_CS_n_SW)
  end // always @(posedge i_SPI_Clk_SW or posedge i_SPI_CS_n_SW)

  
  // Purpose: Cross from SPI Clock Domain to Local Bus Domain
  always @(posedge i_Bus_Clk)
  begin
    r2_SPI_RX_Done     <= r_SPI_RX_Done;
    r3_SPI_RX_Done     <= r2_SPI_RX_Done;
    if (r3_SPI_RX_Done == 1'b0 && r2_SPI_RX_Done == 1'b1)
    begin
      r_Byte_DV   <= 1'b1;
      r_Byte_Data <= r_SPI_RX_Byte;
    end
    else
      r_Byte_DV   <= 1'b0;
  end // always @ (posedge i_Bus_Clk)


  // Purpose: Cross from Bus to SPI Clock Domain (For Reg Reads)
  always @(posedge i_SPI_Clk_SW)
  begin
    r_Temp_Rd_Data <= r_Bus_Rd_Data;
  end

  
  // Purpose: Parses and acts on incoming commands.
  // Uses CS_n as an asynchronous reset to recover from any errors and to reset
  // the state machine after an SPI transaction is complete
  always @(posedge i_Bus_Clk or posedge i_SPI_CS_n_SW)
  begin
    if (i_SPI_CS_n_SW)
    begin
      r_SM_Main     <= IDLE;
      r_Bus_CS_Array <= 0;
    end
    else
    begin

      // Default Assignments
      r_Bus_CS_Array <= 0;
      
      case (r_SM_Main)

        // Stay in Idle State until a Byte Arrives (Command Byte)
        IDLE:
          begin
            if (r_Byte_DV)
            begin
              r_Cmd_Type <= r_Byte_Data[7:4];
              // Decode Command Type
              if (r_Byte_Data[7:4] == CMD_WR || r_Byte_Data[7:4] == CMD_RD)
                r_SM_Main <= GET_ADDR_LOWER;
              else
                r_SM_Main <= ERROR;
            end

            // Decode Chip-Select in Lower 4 Bits (currently only 4 are used)
            r_CS_Index <= r_Byte_Data[1:0];
          end // case: IDLE


      // Get Lower 8 Bits of Command Address (Byte Address)
      GET_ADDR_LOWER:
        begin
          if (r_Byte_DV)
          begin
            r_Cmd_Addr8[7:0] <= r_Byte_Data;
            r_SM_Main        <= GET_ADDR_UPPER;
          end
        end // case: GET_ADDR_LOWER


      // Get Lower 8 Bits of Command Address
      GET_ADDR_UPPER:
        begin
          if (r_Byte_DV)
          begin
            r_Cmd_Addr8[15:8] <= r_Byte_Data;
            if (r_Cmd_Type == CMD_WR)
              r_SM_Main <= GET_WRITE_DATA_LOWER;
            else if (r_Cmd_Type == CMD_RD)
              r_SM_Main <= BUS_READ;
            else 
              r_SM_Main <= ERROR;
          end
        end // case: GET_ADDR_UPPER

        
      // Read in Lower 8 Bits of Write Data.
      GET_WRITE_DATA_LOWER:
        begin
          if (r_Byte_DV)
          begin
            r_Bus_Wr_Data[7:0] <= r_Byte_Data;
            r_SM_Main         <= GET_WRITE_DATA_UPPER;
          end
        end


      // Read in Upper 8 Bits of Write Data.
      GET_WRITE_DATA_UPPER:
        begin
          if (r_Byte_DV)
          begin
            r_Bus_Wr_Data[15:8] <= r_Byte_Data;
            r_SM_Main           <= BUS_WRITE;
          end
        end

          
      // Write Data over Local Bus to Appropriate Addr/CS
      // Goes to increment Addr state for 1 clock (if Burst)
      // Then goes back to receiving write data (if Cmd is Burst)
      BUS_WRITE:
        begin
          o_Bus_Wr_Rd_n              <= 1'b1;
          r_Bus_CS_Array[r_CS_Index] <= 1'b1;
          r_SM_Main                 <= IDLE; //INCR_ADDR; (for bursts)
        end
      
      
      // Read Data over Local Bus from Appropriate Addr/CS
      // Then transmits data out over SPI Interface
      BUS_READ:
        begin
          o_Bus_Wr_Rd_n              <= 1'b0;
          r_Bus_CS_Array[r_CS_Index] <= 1'b1;
          r_SM_Main                 <= SEND_READ_DATA_LOWER;
        end

      
      SEND_READ_DATA_LOWER:
        begin
          if (r_Byte_DV)
            r_SM_Main <= SEND_READ_DATA_UPPER;
        end

          
      SEND_READ_DATA_UPPER:
        begin
          if (r_Byte_DV)
            r_SM_Main <= IDLE; //INCR_ADDR; (for bursts)
        end


      // This state is only used for burst transactions
      // Previously had all read & write transactions going to this state.
      // This was causing problems.
      // I was seeing DOUBLE reads occuring to the same address.  
      // Since bursts are not supported, going to just remove this state.
      /*
       INCR_ADDR:
        begin
          // Increment by 2, since each write is 2 bytes
          r_Cmd_Addr8 <= r_Cmd_Addr8 + 2;
          if (r_Cmd_Type == CMD_WR)
            r_SM_Main <= GET_WRITE_DATA_LOWER;
          else if (r_Cmd_Type == CMD_RD)
            r_SM_Main <= BUS_READ;
        end
       */
      
      ERROR:
        r_SM_Main <= IDLE;
          
      
      default
        r_SM_Main <= IDLE;

      endcase // case (r_SM_Main)
    end // else: !if(i_SPI_CS_n_SW)
  end // always @ (posedge i_Bus_Clk or posedge i_SPI_CS_n_SW)

  assign o_Bus_CS_Array = r_Bus_CS_Array;
  assign o_Bus_Addr8    = r_Cmd_Addr8;
  assign o_Bus_Wr_Data  = r_Bus_Wr_Data;
  ////////////////////////////////////////////////////////////////////////  
  // Handles readback data from the local bus.  Looks at the Read Address to
  // see where the read request came from, and samples data from the correct
  // chip select.  If nothing comes back, WD_Expired will be set, which will
  // put X"DEAD" onto the line to alert software.
  always @(posedge i_Bus_Clk)
  begin
    if (i_Bus_Rd_DV_Array[r_CS_Index])
    begin
      case (r_CS_Index)
      2'b00 : r_Bus_Rd_Data <= i_Bus_Rd_Data_CS0;
      2'b01 : r_Bus_Rd_Data <= i_Bus_Rd_Data_CS1;
      2'b10 : r_Bus_Rd_Data <= i_Bus_Rd_Data_CS2;
      2'b11 : r_Bus_Rd_Data <= i_Bus_Rd_Data_CS3;
      endcase // case (r_CS_Index)
    end
    else if (w_WD_Expired)
      r_Bus_Rd_Data <= 16'hDEAD;
 
  end


  // Kicks off a watchdog counter when a Local Bus Read is performed.
  // Watchdog is not tripped if DV comes back in time.
  always @(posedge i_Bus_Clk or posedge i_SPI_CS_n_SW)
  begin
    if (i_SPI_CS_n_SW)
      r_WD_Count <= WD_LIMIT;
    else
    begin
      if (|r_Bus_CS_Array & ~o_Bus_Wr_Rd_n)  // CS and Read
        r_WD_Count <= 0;
      else if (i_Bus_Rd_DV_Array[r_CS_Index])
        r_WD_Count <= WD_LIMIT;
      else if (r_WD_Count < WD_LIMIT)
        r_WD_Count <= r_WD_Count + 1;
    end // else: !if(i_SPI_CS_n_SW)
  end // always @ (posedge i_Bus_Clk or posedge i_SPI_CS_n_SW)

  assign w_WD_Expired = (r_WD_Count == WD_LIMIT-1) ? 1'b1 : 1'b0;

endmodule // SPI_To_Local_Bus

