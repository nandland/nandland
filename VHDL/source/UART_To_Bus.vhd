-------------------------------------------------------------------------------
-- Description:  Creates an interface from a UART to the Bus
--               Allows reading and writing of registers.
--               Commands: 
--               rd {4 Hex Digit Addr} {CR}
--               Will perform a Bus Read and report the data back.
--               wr {4 Hex Digit Addr} {4 Digit Hex Data} {CR}
--               Will perform a Bus Write of the input data.
--
-- Note:         This module will only assert ONE chip-select!  If UART needs
--               to talk to multiple modules, chip-select decoding must be
--               done at a higher level. 
--               
-- Generics:     g_BUS_WIDTH - Set to width of FPGA Bus in bits.
--                
--               g_CLKS_PER_BIT - Set to (i_Bus_Clk Freq)/(UART Freq)
--               Example: 25 MHz Bus Clock, 115200 baud UART
--               (25000000)/(115200) = 217
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.UART_Pkg.all;

entity UART_To_Bus is
  generic (
    g_BUS_WIDTH    : integer := 8;
    g_CLKS_PER_BIT : integer := 217
    );
  port (
    i_Bus_Clk     : in  std_logic;
    o_Bus_CS      : out std_logic;
    o_Bus_Wr_Rd_n : out std_logic;
    o_Bus_Addr    : out std_logic_vector(15 downto 0);
    o_Bus_Wr_Data : out std_logic_vector(g_BUS_WIDTH-1 downto 0);
    i_Bus_Rd_Data : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    i_Bus_Rd_DV   : in  std_logic;
    -- 
    i_UART_RX     : in  std_logic;
    --
    o_TX_Active  : out std_logic;
    o_TX_Data    : out std_logic
    );
end UART_To_Bus;

architecture RTL of UART_To_Bus is

  -- Max Length of Allowed Received & Transmitted Commands
  constant c_CMD_MAX : integer := 12;
  type t_Cmd is array (0 to c_CMD_MAX-1) of std_logic_vector(7 downto 0);

  type t_SM_Main is (IDLE, TX_START, TX_WAIT_FOR_READY, TX_DONE,
                     TX_WAIT_FOR_DONE);
  signal r_SM_Main : t_SM_Main := IDLE;
  
  -- RX Command Signals
  signal r_RX_Cmd       : t_Cmd := (others => (others => '0'));
  signal r_RX_Index     : integer range 0 to c_CMD_MAX-1 := 0; 
  signal r_RX_Cmd_Done  : std_logic                     := '0';
  signal r_RX_Cmd_Rd    : std_logic                     := '0';
  signal r_RX_Cmd_Wr    : std_logic                     := '0';
  signal r_RX_Cmd_Error : std_logic                     := '0';
  signal r_RX_Cmd_Addr  : std_logic_vector(15 downto 0) := (others => '0');
  signal r_RX_Cmd_Data  : std_logic_vector(15 downto 0) := (others => '0');

  -- TX Command Signals
  signal r_TX_Cmd        : t_Cmd := (others => (others => '0'));
  signal r_TX_Cmd_Length : integer range 0 to c_CMD_MAX-1 := 0;
  signal r_TX_Cmd_Start  : std_logic                      := '0';
  signal r_TX_Index      : integer range 0 to c_CMD_MAX-1 := 0;
  
  -- Low Level UART RX Signals
  signal w_RX_DV    : std_logic;
  signal w_RX_Byte  : std_logic_vector(7 downto 0);

  -- Low Level UART TX Signals
  signal w_TX_Done     : std_logic;
  signal w_TX_Active   : std_logic;
  signal r_TX_DV       : std_logic                    := '0';
  signal r_TX_Byte     : std_logic_vector(7 downto 0) := (others => '0');
  signal w_TX_Byte_Mux : std_logic_vector(7 downto 0);
    
begin

  UART_RX_inst : entity work.UART_RX
    generic map (
      g_CLKS_PER_BIT => g_CLKS_PER_BIT
      )
    port map (
      i_Clk       => i_Bus_Clk,
      i_RX_Serial => i_UART_RX,
      o_RX_DV     => w_RX_DV,
      o_RX_Byte   => w_RX_Byte
      );

  UART_TX_inst : entity work.UART_TX
    generic map (
      g_CLKS_PER_BIT => g_CLKS_PER_BIT
      )
    port map (
      i_Clk       => i_Bus_Clk,
      i_TX_DV     => r_TX_DV or w_RX_DV,
      i_TX_Byte   => w_TX_Byte_Mux,
      o_TX_Active => w_TX_Active,
      o_TX_Serial => o_TX_Data,
      o_TX_Done   => w_TX_Done
      );

  w_TX_Byte_Mux <= w_RX_Byte when w_RX_DV = '1' else r_TX_Byte;
  

  -- Purpose: Buffer up a received command.  Will assert done signal when an
  -- ASCII line feed is received via the UART.
  p_RX_Cmd_Buffer : process (i_Bus_Clk) is
  begin
    if rising_edge(i_Bus_Clk) then

      r_RX_Cmd_Done <= '0';             -- Default Assignment
      
      if w_RX_DV = '1' then
        r_RX_Cmd(r_RX_Index) <= w_RX_Byte;

        -- See if most recently received command is CR (Command Done)
        if w_RX_Byte = c_ASCII_CR then
          r_RX_Cmd_Done <= '1';
          r_RX_Index    <= 0;
          
        -- See if most recently received comamnd is Backspace
        -- If so, move pointer backward
        elsif w_RX_Byte = c_ASCII_BS then
          r_RX_Index    <= r_RX_Index - 1;

        -- Normal Data
        else
          r_RX_Index    <= r_RX_Index + 1;
        end if;
      end if;
    end if;
  end process p_RX_Cmd_Buffer;

    
  
  -- Decode received command.  Parses command and acts accordingly.
  -- Supports Peek, Poke, and $ commands currently.
  p_RX_Cmd_Decode : process (i_Bus_Clk) is
  begin
    if rising_edge(i_Bus_Clk) then

      -- Default Assignments
      r_RX_Cmd_Rd    <= '0';
      r_RX_Cmd_Wr    <= '0';
      r_RX_Cmd_Error <= '0';
      
      if r_RX_Cmd_Done = '1' then

        -- Decode Read Command
        if (r_RX_Cmd(0) = c_ASCII_r and
            r_RX_Cmd(1) = c_ASCII_d and
            r_RX_Cmd(2) = c_ASCII_Sp) then
          r_RX_Cmd_Rd <= '1';

        -- Decode Write Command
        elsif (r_RX_Cmd(0) = c_ASCII_w and
               r_RX_Cmd(1) = c_ASCII_r and
               r_RX_Cmd(2) = c_ASCII_Sp) then
          r_RX_Cmd_Wr <= '1';

        -- Decode Failed, Erroneous Command
        else
          r_RX_Cmd_Error <= '1';
        end if;

        -- Can drop most significant nibble, since it's a digit
        r_RX_Cmd_Addr <= r_RX_Cmd(3)(3 downto 0) &
                         r_RX_Cmd(4)(3 downto 0) &
                         r_RX_Cmd(5)(3 downto 0) &
                         r_RX_Cmd(6)(3 downto 0);

        -- Only use data up to Carriage Return for Poke
        r_RX_Cmd_Data <= r_RX_Cmd(8)(3 downto 0) &
                         r_RX_Cmd(9)(3 downto 0) & 
                         r_RX_Cmd(10)(3 downto 0) & 
                         r_RX_Cmd(11)(3 downto 0);
        
      end if;                           -- r_RX_Cmd_Done = '1'
    end if;                             -- rising_edge(i_Bus_Clk)
  end process p_RX_Cmd_Decode;


  -- Perform a peek or poke to Bus based on Addr from UART
  p_Bus_Access : process (i_Bus_Clk) is
  begin
    if rising_edge(i_Bus_Clk) then
      o_Bus_Addr <= r_RX_Cmd_Addr;
      if r_RX_Cmd_Rd = '1' then
        o_Bus_CS      <= '1';
        o_Bus_Wr_Rd_n <= '0';
      elsif r_RX_Cmd_Wr = '1' then
        o_Bus_CS      <= '1';
        o_Bus_Wr_Rd_n <= '1';
        o_Bus_Wr_Data <= r_RX_Cmd_Data(g_BUS_WIDTH-1 downto 0);
      else
        o_Bus_CS      <= '0';
        o_Bus_Wr_Rd_n <= '0';
      end if;
    end if;
  end process p_Bus_Access;
  

  
  -- Form a command response to a Received Command
  p_TX_Build_Cmd : process (i_Bus_Clk) is
  begin
    if rising_edge(i_Bus_Clk) then

      r_TX_Cmd_Start  <= '0';
      
      -- Erroneous Command Response
      if r_RX_Cmd_Error = '1' then
        r_TX_Cmd(0)     <= c_ASCII_LF;
        r_TX_Cmd(1)     <= c_ASCII_e;
        r_TX_Cmd(2)     <= c_ASCII_r;
        r_TX_Cmd(3)     <= c_ASCII_r;
        r_TX_Cmd(4)     <= c_ASCII_Sp;
        r_TX_Cmd(5)     <= c_ASCII_CR;
        r_TX_Cmd(6)     <= c_ASCII_LF;
        r_TX_Cmd(7)     <= c_ASCII_LF;
        r_TX_Cmd_Length <= 8;
        r_TX_Cmd_Start  <= '1';
        
      -- Read Command Response
      elsif i_Bus_Rd_DV = '1' then
        r_TX_Cmd(0)     <= c_ASCII_LF;
        r_TX_Cmd(1)     <= c_ASCII_0;
        r_TX_Cmd(2)     <= c_ASCII_x;
        r_TX_Cmd(3)     <= X"3" & i_Bus_Rd_Data(15 downto 12);
        r_TX_Cmd(4)     <= X"3" & i_Bus_Rd_Data(11 downto 8);
        r_TX_Cmd(5)     <= X"3" & i_Bus_Rd_Data(7 downto 4);
        r_TX_Cmd(6)     <= X"3" & i_Bus_Rd_Data(3 downto 0);
        r_TX_Cmd(7)     <= c_ASCII_CR;
        r_TX_Cmd(8)     <= c_ASCII_LF;
        r_TX_Cmd(9)     <= c_ASCII_LF;        
        r_TX_Cmd_Length <= 10;
        r_TX_Cmd_Start  <= '1';

      -- Write Command Response
      elsif r_RX_Cmd_Wr = '1' then
        r_TX_Cmd(0)     <= c_ASCII_CR;
        r_TX_Cmd(1)     <= c_ASCII_LF;
        r_TX_Cmd(2)     <= c_ASCII_LF;
        r_TX_Cmd_Length <= 3;
        r_TX_Cmd_Start  <= '1';
      end if;
    end if;
  end process p_TX_Build_Cmd;
  


  -- Simple State Machine to Transmit a command.
  p_SM_Main : process (i_Bus_Clk) is
  begin
    if rising_edge(i_Bus_Clk) then

      r_TX_DV <= '0';                   -- Default Assignment

      case (r_SM_Main) is
        
        when IDLE =>
          if r_TX_Cmd_Start = '1' then
            r_SM_Main <= TX_WAIT_FOR_READY;
          end if;
            
        when TX_WAIT_FOR_READY =>
          if w_TX_Active = '0' then
            r_SM_Main <= TX_START;
          end if;

        when TX_START =>
          r_TX_DV   <= '1';
          r_TX_Byte <= r_TX_Cmd(r_TX_Index);
          r_SM_Main <= TX_WAIT_FOR_DONE;

        when TX_WAIT_FOR_DONE =>
          if w_TX_Done = '1' then
            if r_TX_Index = r_TX_Cmd_Length-1 then
              r_TX_Index <= 0;
              r_SM_Main  <= TX_DONE;
            else
              r_TX_Index <= r_TX_Index + 1;
              r_SM_Main  <= TX_START;
            end if;
          end if;

        when TX_DONE =>
          r_SM_Main <= IDLE;
          
        when others =>
          r_SM_Main <= IDLE;
          
      end case;
    end if;                             -- rising_edge(i_Bus_Clk)
  end process p_SM_Main;

  o_TX_Active  <= w_TX_Active;
  
end RTL;
