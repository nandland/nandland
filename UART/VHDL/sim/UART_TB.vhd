----------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity UART_TB is
end UART_TB;

architecture Behave of UART_TB is
  
  -- Test Bench uses a 25 MHz Clock
  constant c_CLK_PERIOD : time := 40 ns;
  
  -- Want to interface to 115200 baud UART
  -- 25000000 / 115200 = 217 Clocks Per Bit.
  constant c_CLKS_PER_BIT : integer := 217;

  constant c_BIT_PERIOD : time := 8680 ns;
  
  signal r_Clock     : std_logic                    := '0';
  signal r_TX_DV     : std_logic                    := '0';
  signal r_TX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
  signal w_TX_Serial : std_logic;
  signal w_TX_Done   : std_logic;
  signal w_RX_DV     : std_logic;
  signal w_RX_Byte   : std_logic_vector(7 downto 0);
  signal r_RX_Serial : std_logic := '1';

  
  -- Low-level byte-write
  procedure UART_WRITE_BYTE (
    i_Data_In       : in  std_logic_vector(7 downto 0);
    signal o_Serial : out std_logic) is
  begin

    -- Send Start Bit
    o_Serial <= '0';
    wait for c_BIT_PERIOD;

    -- Send Data Byte
    for ii in 0 to 7 loop
      o_Serial <= i_Data_In(ii);
      wait for c_BIT_PERIOD;
    end loop;  -- ii

    -- Send Stop Bit
    o_Serial <= '1';
    wait for c_BIT_PERIOD;
  end UART_WRITE_BYTE;

  
begin

  -- Instantiate UART transmitter
  UART_TX_INST : entity work.UART_TX
    generic map (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT
      )
    port map (
      i_Clk       => r_Clock,
      i_TX_DV     => r_TX_DV,
      i_TX_Byte   => r_TX_Byte,
      o_TX_Active => open,
      o_TX_Serial => w_TX_Serial,
      o_TX_Done   => w_TX_Done
      );

  -- Instantiate UART Receiver
  UART_RX_INST : entity work.uart_rx
    generic map (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT
      )
    port map (
      i_Clk       => r_Clock,
      i_RX_Serial => r_RX_Serial,
      o_RX_DV     => w_RX_DV,
      o_RX_Byte   => w_RX_Byte
      );

  r_Clock <= not r_Clock after c_CLK_PERIOD/2 ns;
  
  process is
  begin

    -- Tell the UART to send a command.
    wait until rising_edge(r_Clock);
    wait until rising_edge(r_Clock);
    r_TX_DV   <= '1';
    r_TX_Byte <= X"AB";
    wait until rising_edge(r_Clock);
    r_TX_DV   <= '0';
    wait until w_TX_Done = '1';

    
    -- Send a command to the UART
    wait until rising_edge(r_Clock);
    UART_WRITE_BYTE(X"37", r_RX_Serial);
    wait until rising_edge(r_Clock);

    -- Check that the correct command was received
    if w_RX_Byte = X"37" then
      report "Test Passed - Correct Byte Received" severity note;
    else 
      report "Test Failed - Incorrect Byte Received" severity note;
    end if;

    assert false report "Tests Complete" severity failure;
  end process;
end Behave;
