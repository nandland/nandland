///////////////////////////////////////////////////////////////////////////////
// Description:       SystemVerilog Package for Bus Simulation.
//                    Includes Bus transactor classes which improves
//                    reusability.
//
// The Following Tasks are supported.  Note that these exist in the Driver
// Class.  Should be called as follows:
//  Bus_Driver D1 = new(Hook);  // (Where Hook is the Bus Interface hook)
//  D1.t_Bus_Wr(0x0, 0xABCD);   // Example write to addr 0 with data ABCD
//
//  task t_Bus_Print_Enable;
//    Enables printing to console of Bus transactions
//
//  task t_Bus_Print_Disable;
//    Disables printing to console of Bus transactions
//
//  task t_Bus_Wr(input [15:0] i_Addr8, input [15:0] i_Data) 
//    Write Data at location Addr (byte address)
//
//  task t_Bus_Rd(input [15:0] i_Addr8, output [15:0] o_Data)
//    Reads Data at location Addr (byte address)
//
//  task t_Bus_Text_Cmd(input string i_Cmd);
//    Sends a single command to Bus (e.g. poke 2 D1000 ABCD)
//
//  Driver Class: t_Bus_Text_Cmd_From_File(input string s_File);
//    User Specifies input file, will execute all string commands in file
//
//  Driver Class: t_Bus_Print_Driver_History;
//    Prints out a history of all Bus transactions
//
///////////////////////////////////////////////////////////////////////////////


interface Bus_Interface (input bit i_Bus_Clk);

  logic [15:0] r_Bus_Addr8, r_Bus_Rd_Data, r_Bus_Wr_Data;
  logic        r_Bus_CS=1'b0, r_Bus_Wr_Rd_n, r_Bus_Rd_DV;

  task t_Clock_Cycles(int N);
    repeat (N) @(posedge i_Bus_Clk);
  endtask : t_Clock_Cycles

  // Master Modport will almost always be Testbench
  // Import gives Testbench access to Tasks
  modport MP_Master (input i_Bus_Clk, r_Bus_Rd_Data, r_Bus_Rd_DV,
                     output r_Bus_Addr8, r_Bus_Wr_Data, r_Bus_CS, r_Bus_Wr_Rd_n,
                     import t_Clock_Cycles);

  // Slave Modport will almost always be UUT
  // Import gives Testbench access to Tasks
  modport MP_Slave (input i_Bus_Clk, r_Bus_Addr8, r_Bus_Wr_Data, r_Bus_CS, 
                    r_Bus_Wr_Rd_n, output r_Bus_Rd_Data, r_Bus_Rd_DV,
                    import t_Clock_Cycles);
  
endinterface : Bus_Interface



package Sim_Bus_Pkg;

  // Contains the individual Bus transaction information (read/write,
  // addr, data, etc).  Also contains the ID of the transaction
  class Bus_Trans;
    static int n_Next_ID;
    const int  n_ID;
    
    logic r_Wr_Rd_n;
    logic [15:0] r_Addr8;
    logic [15:0] r_Data;
    
    // Class constructor function.
    function new();
      n_ID = n_Next_ID++;
    endfunction : new


    // Function that returns a string of the transaction data.  Doesn't print 
    // it to console, returns it as a string type.
    function string f_Print_Trans();
      string   s_Dir, s_Output;
      s_Dir = (r_Wr_Rd_n == 1'b0) ? " Read" : "Write";
      $sformat(s_Output, "Bus_Transaction #%0d: %s, Addr=%4h, Data=%4h", 
               n_ID, s_Dir, r_Addr8, r_Data);
      return s_Output;
    endfunction : f_Print_Trans;


    // Takes input Addr/Data to create new Read transaction
    function Bus_Trans f_Bus_Rd_Trans(logic [15:0] i_Addr8,
                                    logic [15:0] i_Data);

      Bus_Trans trans;      
      trans = new;
      
      trans.r_Wr_Rd_n = 1'b0;
      trans.r_Addr8   = i_Addr8;
      trans.r_Data    = i_Data;

      return trans;
    endfunction : f_Bus_Rd_Trans

    
    // Takes input Addr/Data to create new Write transaction
    function Bus_Trans f_Bus_Wr_Trans(logic [15:0] i_Addr8,
                                    logic [15:0] i_Data);
      Bus_Trans trans;
      trans = new;
      
      trans.r_Wr_Rd_n = 1'b1;
      trans.r_Addr8   = i_Addr8;
      trans.r_Data    = i_Data;

      return trans;
    endfunction : f_Bus_Wr_Trans


    // Function to take input peek/poke command in a string format, 
    // parse it, and return a Bus transaction
    /*
    function Bus_Trans f_Bus_Text_Cmd(string i_Cmd);
      Bus_Trans trans;
      string s_Sub;
      int    n_Index;

      trans = new;
      
      i_Cmd = i_Cmd.tolower(); // make command all lowercase
      
      if (i_Cmd[0:6] == "peek 2 ")
        trans.r_Wr_Rd_n = 1'b0;
      else if (i_Cmd[0:6] == "poke 2 ")
        trans.r_Wr_Rd_n = 1'b1;

      // Look for Address, if it's a peek, addr is the next set of data.
      // If it's a write, we need to parse the string a bit
      if (trans.r_Wr_Rd_n == 1'b0)
        trans.r_Addr8 = i_Cmd.substr(7, i_Cmd.len()-1).atohex();
      else
      begin
        s_Sub = i_Cmd.substr(7, i_Cmd.len()-1);
        n_Index = Sim_Support_Pkg::f_String_Search(s_Sub, " ");
        trans.r_Addr8 = i_Cmd.substr(7, 7+n_Index-1).atohex();
      end
                     
      // Look for Data (if poke command)
      if (trans.r_Wr_Rd_n == 1'b1)
        trans.r_Data = i_Cmd.substr(7+n_Index+1, i_Cmd.len()-1).atohex();

      return trans;

    endfunction : f_Bus_Text_Cmd
     */
  endclass : Bus_Trans



  // This class represents the Bus Functional Model that can drive Bus
  // Transactions through a Virtual Interface.  This occurs when the Testbench
  // calls the t_Bus_Drive method in this class. 
  class Bus_Driver;

    logic b_Print; // Printing Turned on by Default
    virtual Bus_Interface.MP_Master hook;

    Bus_Trans History[$];   // Transaction History Queue
    
    // Constructor, sets up virtual interface variable to reference the 
    // interface instance specified in the call to new(...)
    function new(virtual Bus_Interface.MP_Master hook);
      this.hook = hook;
    endfunction : new


    // Actually drives the Bus via the Interface.  This is the BFM.
    // Input is a Bus Transaction, Can override data in this transaction (if
    // it is read transaction).
    task t_Bus_Drive (Bus_Trans trans);
      hook.t_Clock_Cycles(1); // Wait 1 clock cycle
      hook.r_Bus_CS    <= 1'b1;
      hook.r_Bus_Addr8 <= trans.r_Addr8;
      if (trans.r_Wr_Rd_n == 1'b1) // Write
      begin
        hook.r_Bus_Wr_Rd_n <= 1'b1;
        hook.r_Bus_Wr_Data <= trans.r_Data;
      end
      else // Read
        hook.r_Bus_Wr_Rd_n <= 1'b0;

      hook.t_Clock_Cycles(1); // Wait 1 clock cycle

      // Deassert chip select
      hook.r_Bus_CS <= 1'b0;
   
      hook.t_Clock_Cycles(1); // Wait 1 clock cycle
   
      if (trans.r_Wr_Rd_n == 1'b0) // Read
        trans.r_Data = hook.r_Bus_Rd_Data;
    
      if (this.b_Print == 1'b1)
        $display(trans.f_Print_Trans());

      // Push transaction data onto History Queue
      History.push_back(trans);
      
    endtask : t_Bus_Drive


    // Perform a single transaction write.  Drives it immediately.
    // Optional input argument can be set to display transaction data
    task t_Bus_Wr(input logic [15:0] i_Addr8, input logic [15:0] i_Data);
      Bus_Trans trans;
      trans = trans.f_Bus_Wr_Trans(i_Addr8, i_Data);
      this.t_Bus_Drive(trans);
    endtask : t_Bus_Wr

    
    // Perform a single transaction read.  Drives it immediately.
    // Optional input argument can be set to display transaction data
    task t_Bus_Rd(input  logic [15:0] i_Addr8, output logic [15:0] o_Data);
      Bus_Trans trans;
      trans = trans.f_Bus_Rd_Trans(i_Addr8, o_Data);
      this.t_Bus_Drive(trans);
      o_Data = trans.r_Data;
    endtask : t_Bus_Rd


    // Task to read in a string command, then drive it to the bus.
    /*
    task t_Bus_Text_Cmd(input string i_Cmd);
      Bus_Trans trans;
      trans = trans.f_Bus_Text_Cmd(i_Cmd);
      this.t_Bus_Drive(trans);
    endtask : t_Bus_Text_Cmd
    */

    // Task to read in a file which contains peek/poke commands,
    // parse it, then drive the commands on the Bus
    /*
    task t_Bus_Text_Cmd_From_File(input string s_File);
      string s_Cmd;
      int    n_Matches = 1, n_File_ID;
      
      n_File_ID = $fopen(s_File, "r");
      
      if (n_File_ID == 0)
      begin
        $display("Could not open file, file not found");
        return;
      end
      else
      begin
        while (n_Matches > 0)
        begin
          n_Matches = $fgets(s_Cmd, n_File_ID);
          t_Bus_Text_Cmd(s_Cmd);
        end
      end // else: !if(n_File_ID == 0)
      
      $fclose(n_File_ID);
      
    endtask : t_Bus_Text_Cmd_From_File
    */
    
    // Prints out all Bus transactions that have been driven.
    task t_Bus_Print_Driver_History;
      for (int i=0; i<History.size(); i++)
        $display(History[i].f_Print_Trans);
    endtask : t_Bus_Print_Driver_History


    // Enables Printing of Bus transactions to Console
    task t_Bus_Print_Enable;
      this.b_Print = 1'b1;
    endtask : t_Bus_Print_Enable

    
    // Disables Printing of Bus transactions to Console
    task t_Bus_Print_Disable;
      this.b_Print = 1'b0;
    endtask : t_Bus_Print_Disable

  endclass : Bus_Driver
  
endpackage : Sim_Bus_Pkg
