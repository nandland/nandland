library ieee;
use ieee.std_logic_1164.all;

entity Register_Build_Top is
  port (
    i_Clk     : in  std_logic;
    i_UART_RX : in  std_logic;
    o_UART_TX : out std_logic
    );
end entity Register_Build_Top;

architecture RTL of Register_Build_Top is

  constant c_BUS_WIDTH : integer := 8;

  signal w_Bus_CS      : std_logic;
  signal w_Bus_Wr_Rd_n : std_logic;
  signal w_Bus_Addr    : std_logic_vector(15 downto 0);
  signal w_Bus_Wr_Data : std_logic_vector(c_BUS_WIDTH-1 downto 0);
  signal w_Bus_Rd_Data : std_logic_vector(c_BUS_WIDTH-1 downto 0);
  signal w_Bus_Rd_DV   : std_logic;
  signal w_TX_Active   : std_logic;
  signal w_TX_Data     : std_logic;

  signal w_Reg_00 : std_logic_vector(c_BUS_WIDTH-1 downto 0);
  signal w_Reg_02 : std_logic_vector(c_BUS_WIDTH-1 downto 0);
  signal w_Reg_04 : std_logic_vector(c_BUS_WIDTH-1 downto 0);
  signal w_Reg_06 : std_logic_vector(c_BUS_WIDTH-1 downto 0);
  
begin

  UART_To_Bus_inst : entity work.UART_To_Bus
    generic map (
      g_BUS_WIDTH    => c_BUS_WIDTH,
      g_CLKS_PER_BIT => 217)          -- 25000000/115200 = 217
    port map (
      i_Bus_Clk     => i_Clk,
      o_Bus_CS      => w_Bus_CS,    
      o_Bus_Wr_Rd_n => w_Bus_Wr_Rd_n,
      o_Bus_Addr    => w_Bus_Addr,
      o_Bus_Wr_Data => w_Bus_Wr_Data,
      i_Bus_Rd_Data => w_Bus_Rd_Data,
      i_Bus_Rd_DV   => w_Bus_Rd_DV,
      i_UART_RX     => i_UART_RX,
      o_TX_Active   => w_TX_Active,
      o_TX_Data     => w_TX_Data
      );

  o_UART_TX <= w_TX_Data when w_TX_Active = '1' else '1';

  Bus_Reg_X4_inst : entity work.Bus_Reg_X4
    generic map (
      g_BUS_WIDTH => c_BUS_WIDTH,
      g_INIT_00   => (others => '0'),
      g_INIT_02   => X"01",
      g_INIT_04   => X"AA",
      g_INIT_06   => X"55")
    port map (
      i_Bus_Clk     => i_Clk,
      i_Bus_CS      => w_Bus_CS,
      i_Bus_Wr_Rd_n => w_Bus_Wr_Rd_n,
      i_Bus_Addr    => w_Bus_Addr,
      i_Bus_Wr_Data => w_Bus_Wr_Data,
      o_Bus_Rd_Data => w_Bus_Rd_Data,
      o_Bus_Rd_DV   => w_Bus_Rd_DV,
      i_Reg_00      => w_Reg_00,
      i_Reg_02      => w_Reg_02,
      i_Reg_04      => w_Reg_04,
      i_Reg_06      => w_Reg_06,
      o_Reg_00      => w_Reg_00,
      o_Reg_02      => w_Reg_02,
      o_Reg_04      => w_Reg_04,
      o_Reg_06      => w_Reg_06
      );
  
end architecture RTL;
