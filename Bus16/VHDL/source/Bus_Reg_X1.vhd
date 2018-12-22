-------------------------------------------------------------------------------
-- FPGA Bus Registers
-- Contains 1 Readable/Writable Register.
--
-- Generics:
-- g_BUS_WIDTH - Recommended to set to 8, 16, or 32.
-- g_INIT_XX   - Used to initalize registers to non-zero values.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Bus_Reg_X1 is
  generic (
    g_BUS_WIDTH : integer := 8;
    g_INIT_00   : std_logic_vector(g_BUS_WIDTH-1 downto 0) := (others => '0')
    );
  port (
    i_Bus_Clk     : in  std_logic;
    i_Bus_CS      : in  std_logic;
    i_Bus_Wr_Rd_n : in  std_logic;
    i_Bus_Wr_Data : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    o_Bus_Rd_Data : out std_logic_vector(g_BUS_WIDTH-1 downto 0) := (others => '0');
    o_Bus_Rd_DV   : out std_logic;
    -- 
    i_Reg_00     : in  std_logic_vector(g_BUS_WIDTH-1 downto 0);
    --
    o_Reg_00     : out std_logic_vector(g_BUS_WIDTH-1 downto 0) := g_INIT_00
    );
end Bus_Reg_X1;

architecture RTL of Bus_Reg_X1 is

begin

  p_Reg : process (i_Bus_Clk) is
  begin
    if rising_edge(i_Bus_Clk) then
      o_Bus_Rd_DV   <= '0';

      if i_Bus_CS = '1' then
        if i_Bus_Wr_Rd_n = '1' then
          o_Reg_00 <= i_Bus_Wr_Data;
        else
          o_Bus_Rd_Data <= i_Reg_00;
          o_Bus_Rd_DV   <= '1';
        end if;
      end if;
    end if;
  end process p_Reg;

end architecture RTL;

