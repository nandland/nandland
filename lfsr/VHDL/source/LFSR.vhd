-- Description:
-- A LFSR or Linear Feedback Shift Register is a quick and easy
-- way to generate pseudo-random data inside of an FPGA.  The LFSR can be used
-- for things like counters, test patterns, scrambling of data, and others.
-- This module creates an LFSR whose width gets set by a generic.  The
-- o_LFSR_Done will pulse once all combinations of the LFSR are complete.  The
-- number of clock cycles that it takes o_LFSR_Done to pulse is equal to
-- 2^NUM_BITS-1.  For example, setting NUM_BITS to 5 means that o_LFSR_Done
-- will pulse every 2^5-1 = 31 clock cycles.  o_LFSR_Data will change on each
-- clock cycle that the module is enabled, which can be used if desired.
--
-- Generics:
-- NUM_BITS - Set to the integer number of bits wide to create your LFSR.

library ieee;
use ieee.std_logic_1164.all;

entity LFSR is
  generic (
    NUM_BITS : integer := 5);
  port (
    i_Clk    : in std_logic;
    i_Enable : in std_logic;

    -- Optional Seed Value
    i_Seed_DV   : in std_logic;
    i_Seed_Data : in std_logic_vector(NUM_BITS-1 downto 0);
    
    o_LFSR_Data : out std_logic_vector(NUM_BITS-1 downto 0);
    o_LFSR_Done : out std_logic);
end entity LFSR;

architecture RTL of LFSR is

  signal r_LFSR : std_logic_vector(NUM_BITS downto 1) := (others => '0');
  signal w_XNOR : std_logic;
  
begin

  -- Purpose: Load up LFSR with Seed if Data Valid (DV) pulse is detected.
  -- Othewise just run LFSR when enabled.
  process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      if i_Enable = '1' then
        if i_Seed_DV = '1' then
          r_LFSR <= i_Seed_Data;
        else
          r_LFSR <= r_LFSR(r_LFSR'left-1 downto 1) & w_XNOR;
        end if;
      end if;
    end if;
  end process; 

  -- Create Feedback Polynomials.  Based on Application Note XAPP052.PDF
  g_LFSR_3 : if NUM_BITS = 3 generate
    w_XNOR <= r_LFSR(3) xnor r_LFSR(2);
  end generate g_LFSR_3;

  g_LFSR_4 : if NUM_BITS = 4 generate
    w_XNOR <= r_LFSR(4) xnor r_LFSR(3);
  end generate g_LFSR_4;

  g_LFSR_5 : if NUM_BITS = 5 generate
    w_XNOR <= r_LFSR(5) xnor r_LFSR(3);
  end generate g_LFSR_5;

  g_LFSR_6 : if NUM_BITS = 6 generate
    w_XNOR <= r_LFSR(6) xnor r_LFSR(5);
  end generate g_LFSR_6;

  g_LFSR_7 : if NUM_BITS = 7 generate
    w_XNOR <= r_LFSR(7) xnor r_LFSR(6);
  end generate g_LFSR_7;

  g_LFSR_8 : if NUM_BITS = 8 generate
    w_XNOR <= r_LFSR(8) xnor r_LFSR(6) xnor r_LFSR(5) xnor r_LFSR(4);
  end generate g_LFSR_8;

  g_LFSR_9 : if NUM_BITS = 9 generate
    w_XNOR <= r_LFSR(9) xnor r_LFSR(5);
  end generate g_LFSR_9;

  g_LFSR_10 : if NUM_BITS = 10 generate
    w_XNOR <= r_LFSR(10) xnor r_LFSR(7);
  end generate g_LFSR_10;

  g_LFSR_11 : if NUM_BITS = 11 generate
    w_XNOR <= r_LFSR(11) xnor r_LFSR(9);
  end generate g_LFSR_11;

  g_LFSR_12 : if NUM_BITS = 12 generate
    w_XNOR <= r_LFSR(12) xnor r_LFSR(6) xnor r_LFSR(4) xnor r_LFSR(1);
  end generate g_LFSR_12;

  g_LFSR_13 : if NUM_BITS = 13 generate
    w_XNOR <= r_LFSR(13) xnor r_LFSR(4) xnor r_LFSR(3) xnor r_LFSR(1);
  end generate g_LFSR_13;

  g_LFSR_14 : if NUM_BITS = 14 generate
    w_XNOR <= r_LFSR(14) xnor r_LFSR(5) xnor r_LFSR(3) xnor r_LFSR(1);
  end generate g_LFSR_14;

  g_LFSR_15 : if NUM_BITS = 15 generate
    w_XNOR <= r_LFSR(15) xnor r_LFSR(14);
  end generate g_LFSR_15;

  g_LFSR_16 : if NUM_BITS = 16 generate
    w_XNOR <= r_LFSR(16) xnor r_LFSR(15) xnor r_LFSR(13) xnor r_LFSR(4);
  end generate g_LFSR_16;

  g_LFSR_17 : if NUM_BITS = 17 generate
    w_XNOR <= r_LFSR(17) xnor r_LFSR(14);
  end generate g_LFSR_17;

  g_LFSR_18 : if NUM_BITS = 18 generate
    w_XNOR <= r_LFSR(18) xnor r_LFSR(11);
  end generate g_LFSR_18;

  g_LFSR_19 : if NUM_BITS = 19 generate
    w_XNOR <= r_LFSR(19) xnor r_LFSR(6) xnor r_LFSR(2) xnor r_LFSR(1);
  end generate g_LFSR_19;

  g_LFSR_20 : if NUM_BITS = 20 generate
    w_XNOR <= r_LFSR(20) xnor r_LFSR(17);
  end generate g_LFSR_20;

  g_LFSR_21 : if NUM_BITS = 21 generate
    w_XNOR <= r_LFSR(21) xnor r_LFSR(19);
  end generate g_LFSR_21;

  g_LFSR_22 : if NUM_BITS = 22 generate
    w_XNOR <= r_LFSR(22) xnor r_LFSR(21);
  end generate g_LFSR_22;

  g_LFSR_23 : if NUM_BITS = 23 generate
    w_XNOR <= r_LFSR(23) xnor r_LFSR(18);
  end generate g_LFSR_23;

  g_LFSR_24 : if NUM_BITS = 24 generate
    w_XNOR <= r_LFSR(24) xnor r_LFSR(23) xnor r_LFSR(22) xnor r_LFSR(17);
  end generate g_LFSR_24;

  g_LFSR_25 : if NUM_BITS = 25 generate
    w_XNOR <= r_LFSR(25) xnor r_LFSR(22);
  end generate g_LFSR_25;

  g_LFSR_26 : if NUM_BITS = 26 generate
    w_XNOR <= r_LFSR(26) xnor r_LFSR(6) xnor r_LFSR(2) xnor r_LFSR(1);
  end generate g_LFSR_26;

  g_LFSR_27 : if NUM_BITS = 27 generate
    w_XNOR <= r_LFSR(27) xnor r_LFSR(5) xnor r_LFSR(2) xnor r_LFSR(1);
  end generate g_LFSR_27;

  g_LFSR_28 : if NUM_BITS = 28 generate
    w_XNOR <= r_LFSR(28) xnor r_LFSR(25);
  end generate g_LFSR_28;

  g_LFSR_29 : if NUM_BITS = 29 generate
    w_XNOR <= r_LFSR(29) xnor r_LFSR(27);
  end generate g_LFSR_29;

  g_LFSR_30 : if NUM_BITS = 30 generate
    w_XNOR <= r_LFSR(30) xnor r_LFSR(6) xnor r_LFSR(4) xnor r_LFSR(1);
  end generate g_LFSR_30;

  g_LFSR_31 : if NUM_BITS = 31 generate
    w_XNOR <= r_LFSR(31) xnor r_LFSR(28);
  end generate g_LFSR_31;

  g_LFSR_32 : if NUM_BITS = 32 generate
    w_XNOR <= r_LFSR(32) xnor r_LFSR(22) xnor r_LFSR(2) xnor r_LFSR(1);
  end generate g_LFSR_32;
  
  
  o_LFSR_Data <= r_LFSR(r_LFSR'left downto 1);
  o_LFSR_Done <= '1' when r_LFSR(r_LFSR'left downto 1) = i_Seed_Data else '0';
  
end architecture RTL;
