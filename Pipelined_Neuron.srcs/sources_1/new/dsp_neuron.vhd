----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/09/2025 10:56:09 AM
-- Design Name: 
-- Module Name: dsp_neuron - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity dsp_neuron is
    generic(
        GEN_ADDR_WIDTH : natural := 2
    );
    
    Port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        stall               : in std_logic;
        i_valid             : in std_logic;
        i_V                 : in std_logic_vector(24 downto 0); -- input D
        i_T                 : in std_logic_vector(17 downto 0); -- input B
        i_Um                : in std_logic_vector(29 downto 0); -- input A and C
        i_neuron_addr       : in std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0);
        i_finished_layer    : in std_logic;
        o_Um                : out std_logic_vector(26 downto 0);
        o_neuron_addr       : out std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0);
        o_overflow          : out std_logic;
        o_valid             : out std_logic;
        o_finished_layer    : out std_logic
    );
end dsp_neuron;

architecture rtl of dsp_neuron is

signal result       : std_logic_vector(47 downto 0);
signal overflow     : std_logic;
signal underflow    : std_logic;
signal carryout     : std_logic_vector(3 downto 0);
signal c_d1         : std_logic_vector(47 downto 0);
signal c_d2         : std_logic_vector(47 downto 0);

signal dsp_clk      : std_logic;

signal v_1          : std_logic := '0';
signal v_2          : std_logic := '0';
signal v_3          : std_logic := '0';

signal finished_1   : std_logic := '0';
signal finished_2   : std_logic := '0';
signal finished_3   : std_logic := '0';

signal neuron_addr_1 : std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal neuron_addr_2 : std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0) := (others => '0');
signal neuron_addr_3 : std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0) := (others => '0');

-- unused tie off signals
signal u_acout          : std_logic_vector(29 downto 0);
signal u_bcout          : std_logic_vector(17 downto 0);
signal u_cascade_carry  : std_logic;
signal u_mult_cas_sign  : std_logic;
signal u_pcout          : std_logic_vector(47 downto 0);
signal u_patt_detect    : std_logic;
signal u_pattb_detect   : std_logic;

begin

    dsp_clk <= clk and not stall;
   
   DSP48E1_inst : DSP48E1
   generic map (
      -- Feature Control Attributes: Data Path Selection
      A_INPUT => "DIRECT",               -- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
      B_INPUT => "DIRECT",               -- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
      USE_DPORT => TRUE,                 -- Select D port usage (TRUE or FALSE)
      USE_MULT => "MULTIPLY",            -- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
      USE_SIMD => "ONE48",               -- SIMD selection ("ONE48", "TWO24", "FOUR12")
      -- Pattern Detector Attributes: Pattern Detection Configuration
      AUTORESET_PATDET => "NO_RESET",    -- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
      MASK => X"ffffffffffff",           -- 48-bit mask value for pattern detect (1=ignore)
      PATTERN => X"000000000000",        -- 48-bit pattern match for pattern detect
      SEL_MASK => "MASK",                -- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
      SEL_PATTERN => "PATTERN",          -- Select pattern value ("PATTERN" or "C")
      USE_PATTERN_DETECT => "NO_PATDET", -- Enable pattern detect ("PATDET" or "NO_PATDET")
      -- Register Control Attributes: Pipeline Register Configuration
      ACASCREG => 1,                     -- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
      ADREG => 1,                        -- Number of pipeline stages for pre-adder (0 or 1)
      ALUMODEREG => 0,                   -- Number of pipeline stages for ALUMODE (0 or 1)
      AREG => 1,                         -- Number of pipeline stages for A (0, 1 or 2)
      BCASCREG => 1,                     -- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
      BREG => 2,                         -- Number of pipeline stages for B (0, 1 or 2)
      CARRYINREG => 1,                   -- Number of pipeline stages for CARRYIN (0 or 1)
      CARRYINSELREG => 1,                -- Number of pipeline stages for CARRYINSEL (0 or 1)
      CREG => 1,                         -- Number of pipeline stages for C (0 or 1)
      DREG => 1,                         -- Number of pipeline stages for D (0 or 1)
      INMODEREG => 0,                    -- Number of pipeline stages for INMODE (0 or 1)
      MREG => 1,                         -- Number of multiplier pipeline stages (0 or 1)
      OPMODEREG => 0,                    -- Number of pipeline stages for OPMODE (0 or 1)
      PREG => 1                          -- Number of pipeline stages for P (0 or 1)
   )
   port map (
      -- Cascade: 30-bit (each) output: Cascade Ports
      ACOUT => u_acout,                   -- 30-bit output: A port cascade output
      BCOUT => u_bcout,                   -- 18-bit output: B port cascade output
      CARRYCASCOUT => u_cascade_carry,     -- 1-bit output: Cascade carry output
      MULTSIGNOUT => u_mult_cas_sign,       -- 1-bit output: Multiplier sign cascade output
      PCOUT => u_pcout,                   -- 48-bit output: Cascade output
      -- Control: 1-bit (each) output: Control Inputs/Status Bits
      OVERFLOW => overflow,             -- 1-bit output: Overflow in add/acc output
      PATTERNBDETECT => u_pattb_detect, -- 1-bit output: Pattern bar detect output
      PATTERNDETECT => u_patt_detect,   -- 1-bit output: Pattern detect output
      UNDERFLOW => underflow,           -- 1-bit output: Underflow in add/acc output
      -- Data: 4-bit (each) output: Data Ports
      CARRYOUT => carryout,             -- 4-bit output: Carry output
      P => result,                           -- 48-bit output: Primary data output
      -- Cascade: 30-bit (each) input: Cascade Ports
      ACIN => (others => '0'),                     -- 30-bit input: A cascade data input
      BCIN => (others => '0'),                     -- 18-bit input: B cascade input
      CARRYCASCIN => '0',       -- 1-bit input: Cascade carry input
      MULTSIGNIN => '0',         -- 1-bit input: Multiplier sign input
      PCIN => (others => '0'),                     -- 48-bit input: P cascade input
      -- Control: 4-bit (each) input: Control Inputs/Status Bits
      ALUMODE => "0000",               -- 4-bit input: ALU control input
      CARRYINSEL => (others => '0'),         -- 3-bit input: Carry select input
      CLK => dsp_clk,                       -- 1-bit input: Clock input
      INMODE => "01101",                -- 5-bit input: INMODE control input
      OPMODE => "0110101",              -- 7-bit input: Operation mode input
      -- Data: 30-bit (each) input: Data Ports
      A => i_Um,                         -- 30-bit input: A data input
      B => i_T,                         -- 18-bit input: B data input
      C => c_d2,     -- 48-bit input: C data input
      CARRYIN => '0',               -- 1-bit input: Carry input signal
      D => i_V,                           -- 25-bit input: D data input
      -- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
      CEA1 => '1',                     -- 1-bit input: Clock enable input for 1st stage AREG
      CEA2 => '1',                     -- 1-bit input: Clock enable input for 2nd stage AREG
      CEAD => '1',                     -- 1-bit input: Clock enable input for ADREG
      CEALUMODE => '1',           -- 1-bit input: Clock enable input for ALUMODE
      CEB1 => '1',                     -- 1-bit input: Clock enable input for 1st stage BREG
      CEB2 => '1',                     -- 1-bit input: Clock enable input for 2nd stage BREG
      CEC => '1',                       -- 1-bit input: Clock enable input for CREG
      CECARRYIN => '1',           -- 1-bit input: Clock enable input for CARRYINREG
      CECTRL => '1',                 -- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
      CED => '1',                       -- 1-bit input: Clock enable input for DREG
      CEINMODE => '1',             -- 1-bit input: Clock enable input for INMODEREG
      CEM => '1',                       -- 1-bit input: Clock enable input for MREG
      CEP => '1',                       -- 1-bit input: Clock enable input for PREG
      RSTA => rst,                     -- 1-bit input: Reset input for AREG
      RSTALLCARRYIN => rst,   -- 1-bit input: Reset input for CARRYINREG
      RSTALUMODE => rst,         -- 1-bit input: Reset input for ALUMODEREG
      RSTB => rst,                     -- 1-bit input: Reset input for BREG
      RSTC => rst,                     -- 1-bit input: Reset input for CREG
      RSTCTRL => rst,               -- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
      RSTD => rst,                     -- 1-bit input: Reset input for DREG and ADREG
      RSTINMODE => rst,           -- 1-bit input: Reset input for INMODEREG
      RSTM => rst,                     -- 1-bit input: Reset input for MREG
      RSTP => rst                      -- 1-bit input: Reset input for PREG
   );

   -- End of DSP48E1_inst instantiation		
				
   
   c_reg_delay : process(clk)
    begin
        if rising_edge(clk) and stall = '0' then
            c_d1(29 downto 0)   <= i_Um;
            c_d1(47 downto 30)  <= (others => '0');
            c_d2                <= c_d1;
        end if;
    end process;
    
    valid_delay : process(clk)
    begin
        if rst = '1' then
            v_1 <= '0';
            v_2 <= '0';
            v_3 <= '0';
        elsif rising_edge(clk) and stall = '0' then
            v_1 <= i_valid;
            v_2 <= v_1;
            v_3 <= v_2;
        end if;
    end process;
    
    finished_delay : process(clk)
    begin
        if rst = '1' then
            finished_1 <= '0';
            finished_2 <= '0';
            finished_3 <= '0';
        elsif rising_edge(clk) and stall = '0' then
            finished_1 <= i_finished_layer;
            finished_2 <= finished_1;
            finished_3 <= finished_2;
        end if;
    end process;
    
    neuron_addr_delay : process(clk)
    begin
        if rst = '1' then
            neuron_addr_1 <= (others => '0');
            neuron_addr_2 <= (others => '0');
            neuron_addr_3 <= (others => '0');
        elsif rising_edge(clk) and stall = '0' then
            neuron_addr_1 <= i_neuron_addr;
            neuron_addr_2 <= neuron_addr_1;
            neuron_addr_3 <= neuron_addr_2; 
        end if;
    end process;
    
    o_Um <= result(26 downto 0);
    o_overflow <= overflow;
    o_valid <= v_3;
    o_neuron_addr <= neuron_addr_3;
    o_finished_layer <= finished_3;

end rtl;
