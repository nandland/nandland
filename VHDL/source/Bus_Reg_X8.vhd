-------------------------------------------------------------------------------
-- FPGA Bus Registers
-- Contains 8 Readable/Writable Registers
--
-- Generics:
-- g_BUS_WIDTH - Recommended to set to 8, 16, or 32.
-- g_INIT_XX   - Used to initalize registers to non-zero values.
-- 
-- Note: Address is used to increment into entire word of g_BUS_WIDTH
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Bus_Reg_X8 is
  generic (
    g_BUS_WIDTH : integer := 8;
    g_INIT_00   : std_logic_vector(g_BUS_WIDTH-1 downto 0) := (others => '0');
    g_INIT_02   : std_logic_vector(g_BUS_WIDTH-1 downto 0) := (others => '0');
    g_INIT_04   : std_logic_vector(g_BUS_WIDTH-1 downto 0) := (others => '0');
    g_INIT_06   : std_logic_vector(g_BUS_WIDTH-1 downto 0) := (others => '0');
    g_INIT_08   : std_logic_vector(g_BUS_WIDTH-1 downto 0) := (others => '0');
    g_INIT_0A   : std_logic_vector(g_BUS_WIDTH-1 downto 0) := (others => '0');
    g_INIT_0C   : std_logic_vector(g_BUS_WIDTH-1 downto 0) := (others => '0');
    g_INIT_0E   : std_logic_vector(g_BUS_WIDTH-1 downto 0) := (others => '0')
    );
  port (
    i_Bus_Clk     : in  std_logic;
    i_Bus_CS      : in  std_logic;
    i_Bus_Wr_Rd_n : in  std_logic;
    i_Bus_Addr    : in  std_logic_vector(2 downto 0);
    i_Bus_Wr_Data : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    o_Bus_Rd_Data : out std_logic_vector(g_BUS_WIDTH-1 downto 0) := (others => '0');
    o_Bus_Rd_DV   : out std_logic;
    -- 
    i_Reg_00      : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    i_Reg_02      : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    i_Reg_04      : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    i_Reg_06      : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    i_Reg_08      : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    i_Reg_0A      : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    i_Reg_0C      : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    i_Reg_0E      : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    --
    o_Reg_00      : out std_logic_vector(g_BUS_WIDTH-1 downto 0) := g_INIT_00;
    o_Reg_02      : out std_logic_vector(g_BUS_WIDTH-1 downto 0) := g_INIT_02;
    o_Reg_04      : out std_logic_vector(g_BUS_WIDTH-1 downto 0) := g_INIT_04;
    o_Reg_06      : out std_logic_vector(g_BUS_WIDTH-1 downto 0) := g_INIT_06;
    o_Reg_08      : out std_logic_vector(g_BUS_WIDTH-1 downto 0) := g_INIT_08;
    o_Reg_0A      : out std_logic_vector(g_BUS_WIDTH-1 downto 0) := g_INIT_0A;
    o_Reg_0C      : out std_logic_vector(g_BUS_WIDTH-1 downto 0) := g_INIT_0C;
    o_Reg_0E      : out std_logic_vector(g_BUS_WIDTH-1 downto 0) := g_INIT_0E
    );
end Bus_Reg_X8;

architecture RTL of Bus_Reg_X8 is

begin

  p_Reg : process (i_Bus_Clk) is
  begin
    if rising_edge(i_Bus_Clk) then
      o_Bus_Rd_DV <= '0';

      if i_Bus_CS = '1' then
        if i_Bus_Wr_Rd_n = '1' then
          
          case to_bit(i_Bus_Addr) is
            when "000" =>
              o_Reg_00 <= i_Bus_Wr_Data;
            when "001" =>
              o_Reg_02 <= i_Bus_Wr_Data;
            when "010" =>
              o_Reg_04 <= i_Bus_Wr_Data;
            when "011" =>
              o_Reg_06 <= i_Bus_Wr_Data;
            when "100" =>
              o_Reg_08 <= i_Bus_Wr_Data;
            when "101" =>
              o_Reg_0A <= i_Bus_Wr_Data;
            when "110" =>
              o_Reg_0C <= i_Bus_Wr_Data;
            when "111" =>
              o_Reg_0E <= i_Bus_Wr_Data;
          end case;

        else
          o_Bus_Rd_DV   <= '1';
          
          case to_bit(i_Bus_Addr) is
            when "000" =>
              o_Bus_Rd_Data <= i_Reg_00;
            when "001" =>
              o_Bus_Rd_Data <= i_Reg_02;
            when "010" =>
              o_Bus_Rd_Data <= i_Reg_04;
            when "011" =>
              o_Bus_Rd_Data <= i_Reg_06;
            when "100" =>
              o_Bus_Rd_Data <= i_Reg_08;
            when "101" =>
              o_Bus_Rd_Data <= i_Reg_0A;
            when "110" =>
              o_Bus_Rd_Data <= i_Reg_0C;
            when "111" =>
              o_Bus_Rd_Data <= i_Reg_0E;
          end case;
        end if;
      end if;
    end if;
  end process p_Reg;

end architecture RTL;
