///////////////////////////////////////////////////////////////////////////////
// Contains simulation code for CRC calculations
// Performs CRC-16-CCITT.  Could be modified to suppot other CRCs.
// Init value = 0xFFFF
//
// To Use:
// Instantiate An Instance as follows:
// CRC_Class CRC_Inst = new();   // CRC_Inst can be anything you like.
// 
// The Following Tasks are supported.  
// Should be called as follows:
// CRC_Inst.Init();   // Will Initialize CRC to 0xFFFF
//
//  task Init()
//    Initializes the CRC back to 0xFFFF
//
//  task AddByte(input [7:0] i_Data)
//    Calculates running CRC with i_Data added to CRC calc
//
//  function GetCrc()
//    Returns the 16-bit calculated CRC value
//
///////////////////////////////////////////////////////////////////////////////


package CRC_Pkg;

  // Main CRC Class
  class CRC_Class;

    logic [15:0] RunningCRC;
    
    // Constructor, no input
    function new();
    endfunction : new

    // Initializes the CRC back to 0xFFFF
    task Init();
      RunningCRC = 16'hFFFF;
    endtask // tInit
      
    // Returns the 16-bit calculated CRC value
    function [15:0] GetCrc();
      return RunningCRC;
    endfunction // f_Get_CRC
    

    // Calculates running CRC with i_Data added to CRC calc
    // Currently not working!
    task AddByteParallel(input [7:0] D);
      logic [15:0] C;
      C = RunningCRC; // store previous value before modifying
      // ONLINE CALC VERSION 
      /*
      RunningCRC[15] = C[7] ^ D[4] ^ C[11] ^ D[0] ^ C[15];
      RunningCRC[14] = C[6] ^ D[5] ^ C[10] ^ D[1] ^ C[14];          
      RunningCRC[13] = C[5] ^ D[6] ^ C[9]  ^ D[2] ^ C[13]; 
      RunningCRC[12] = C[4] ^ D[0] ^ C[15] ^ D[7] ^ C[8] ^ D[3] ^ C[12];      
      RunningCRC[11] = C[3] ^ D[1] ^ C[14];                    
      RunningCRC[10] = C[2] ^ D[2] ^ C[13];                     
      RunningCRC[9]  = C[1] ^ D[3] ^ C[12];                     
      RunningCRC[8]  = C[0] ^ D[4] ^ C[11] ^ D[0] ^ C[15];          
      RunningCRC[7]  = D[0] ^ C[15] ^ D[5] ^ C[10] ^ D[1] ^ C[14];    
      RunningCRC[6]  = D[1] ^ C[14] ^ D[6] ^ C[9] ^ D[2] ^ C[13];     
      RunningCRC[5]  = D[2] ^ C[13] ^ D[7] ^ C[8] ^ D[3] ^ C[12];     
      RunningCRC[4]  = D[3] ^ C[12];                       
      RunningCRC[3]  = D[4] ^ C[11] ^ D[0] ^ C[15];              
      RunningCRC[2]  = D[5] ^ C[10] ^ D[1] ^ C[14];             
      RunningCRC[1]  = D[6] ^ C[9] ^ D[2]^ C[13];             
      RunningCRC[0]  = D[7] ^ C[8] ^ D[3] ^ C[12];  
       */

      RunningCRC[0] = C[8] ^ C[12] ^ D[0] ^ D[4];
      RunningCRC[1] = C[9] ^ C[13] ^ D[1] ^ D[5];
      RunningCRC[2] = C[10] ^ C[14] ^ D[2] ^ D[6];
      RunningCRC[3] = C[11] ^ C[15] ^ D[3] ^ D[7];
      RunningCRC[4] = C[12] ^ D[4];
      RunningCRC[5] = C[8] ^ C[12] ^ C[13] ^ D[0] ^ D[4] ^ D[5];
      RunningCRC[6] = C[9] ^ C[13] ^ C[14] ^ D[1] ^ D[5] ^ D[6];
      RunningCRC[7] = C[10] ^ C[14] ^ C[15] ^ D[2] ^ D[6] ^ D[7];
      RunningCRC[8] = C[0] ^ C[11] ^ C[15] ^ D[3] ^ D[7];
      RunningCRC[9] = C[1] ^ C[12] ^ D[4];
      RunningCRC[10] = C[2] ^ C[13] ^ D[5];
      RunningCRC[11] = C[3] ^ C[14] ^ D[6];
      RunningCRC[12] = C[4] ^ C[8] ^ C[12] ^ C[15] ^ D[0] ^ D[4] ^ D[7];
      RunningCRC[13] = C[5] ^ C[9] ^ C[13] ^ D[1] ^ D[5];
      RunningCRC[14] = C[6] ^ C[10] ^ C[14] ^ D[2] ^ D[6];
      RunningCRC[15] = C[7] ^ C[11] ^ C[15] ^ D[3] ^ D[7];
    endtask // AddByte


    // Calculates running CRC by adding single bit to CRC calc
    task AddBit(input D);
      logic [15:0] C;
      C               = RunningCRC; // store previous value before modifying
      RunningCRC[15]  = C[14];  
      RunningCRC[14]  = C[13];
      RunningCRC[13]  = C[12];
      RunningCRC[12]  = C[11] ^ C[15] ^ D;
      RunningCRC[11]  = C[10];
      RunningCRC[10]  = C[9];
      RunningCRC[9]   = C[8];
      RunningCRC[8]   = C[7];
      RunningCRC[7]   = C[6];
      RunningCRC[6]   = C[5];
      RunningCRC[5]   = C[4] ^ C[15] ^ D;
      RunningCRC[4]   = C[3];
      RunningCRC[3]   = C[2];
      RunningCRC[2]   = C[1];
      RunningCRC[1]   = C[0];
      RunningCRC[0]   = C[15] ^ D;
    endtask // AddBit

    task ReverseFinalCrc();
      int ii;
      logic [15:0] tempCrc;
      for (ii=0; ii<16; ii=ii+1)
      begin
        tempCrc[ii]  = RunningCRC[15-ii];
      end
      RunningCRC = tempCrc;
    endtask // RunFinalXorFFFF


    task XorFinalCrc();
      RunningCRC ^= 16'hFFFF;
    endtask // XorFinalCrc
    

    task AddByteSerial(input [7:0] D);
      int ii=0;
      for (ii=0; ii<8; ii=ii+1)
        begin
          AddBit(D[ii]);
        end
    endtask // AddByteSerial

    

  endclass // CRC_Class
    
endpackage : CRC_Pkg
