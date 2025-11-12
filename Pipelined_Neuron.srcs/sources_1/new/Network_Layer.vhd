----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/04/2025 01:56:11 PM
-- Design Name: 
-- Module Name: Network_Layer - Behavioral
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

library work;
use work.Neuron_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Network_Layer is

    generic(
        GEN_ADDR_WIDTH              : natural := 2;
        GEN_NUM_WEIGHTS_PER_NEURON  : natural := 2;
        GEN_INIT_WEIGHTS            : std_logic_vector(255 downto 0) := (others => '0');
        GEN_TAU                     : std_logic_vector(17 downto 0) := (others => '0')
    );

    port (
        clk                     : in std_logic;
        rst                     : in std_logic;
        i_prev_spikes           : in std_logic_vector(GEN_NUM_WEIGHTS_PER_NEURON - 1 downto 0);
        i_en                    : in std_logic;
        i_next_layer_finished   : in std_logic;
        o_spikes                : out std_logic_vector(2 ** GEN_ADDR_WIDTH - 1 downto 0);
        o_finished_layer        : out std_logic;
        o_en                    : out std_logic
    );
end Network_Layer;

architecture rtl of Network_Layer is

signal spike_Um             : std_logic_vector(UM_WIDTH - 1 downto 0);
signal spike_neuron_addr    : std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0);
signal spike_valid          : std_logic := '0';
signal mem_Um               : um_t;
signal mem_weight_sum       : std_logic_vector(WEIGHT_WIDTH downto 0);
signal mem_neuron_addr      : std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0);
signal mem_valid            : std_logic;
signal mem_Um_adj           : std_logic_vector(29 downto 0);
signal mem_weight_sum_adj   : std_logic_vector(24 downto 0);

signal dsp_um               : std_logic_vector(26 downto 0);
signal dsp_neuron_addr      : std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0);
signal dsp_overflow         : std_logic;
signal dsp_valid            : std_logic;

signal dsp_finished_layer   : std_logic;
signal mem_finished_layer   : std_logic;
signal spike_finished_layer : std_logic;

signal ctrl_spike           : std_logic;

signal stall                : std_logic;

begin

NEURON_MEM : entity work.Neuron_Memory(rtl)
    generic map(
        GEN_ADDR_WIDTH => GEN_ADDR_WIDTH,
        GEN_NUM_WEIGHTS_PER_NEURON => GEN_NUM_WEIGHTS_PER_NEURON,
        GEN_INIT_WEIGHTS => GEN_INIT_WEIGHTS
    )
    port map(
        clk                 => clk,
        rst                 => rst,
        i_prev_spikes       => i_prev_spikes,
        i_new_Um            => spike_Um,
        i_neuron_addr       => spike_neuron_addr,
        i_en                => i_en,
        i_valid             => spike_valid,
        i_stall             => stall,
        o_curr_Um           => mem_Um,
        o_weight_sum        => mem_weight_sum,
        o_finished_layer    => mem_finished_layer,
        o_neuron_addr       => mem_neuron_addr,
        o_valid             => mem_valid
    );

mem_Um_adj <= "000" & std_logic_vector(mem_Um);
mem_weight_sum_adj(WEIGHT_WIDTH downto 0) <= mem_weight_sum;
mem_weight_sum_adj(24 downto WEIGHT_WIDTH + 1) <= (others => '0');


DSP_BLOCK : entity work.dsp_neuron(rtl)
    generic map(
        GEN_ADDR_WIDTH => GEN_ADDR_WIDTH
    )
    port map(
        clk => clk,
        rst => rst,
        stall => stall,
        i_valid => mem_valid,
        i_V => mem_weight_sum_adj,
        i_T => GEN_TAU,
        i_Um => mem_Um_adj,
        i_neuron_addr => mem_neuron_addr,
        i_finished_layer => mem_finished_layer,
        o_um => dsp_um,
        o_neuron_addr => dsp_neuron_addr,
        o_overflow => dsp_overflow,
        o_valid => dsp_valid,
        o_finished_layer => dsp_finished_layer
    );
    
SPIKE_CTRL : entity work.Spike_Control_Unit(rtl)
    generic map(
        GEN_ADDR_WIDTH => GEN_ADDR_WIDTH
    )
    port map(
        i_neuron_voltage => dsp_um,
        i_overflow => dsp_overflow,
        i_valid => dsp_valid,
        i_neuron_addr => dsp_neuron_addr,
        i_finished_layer => dsp_finished_layer,
        o_spike => ctrl_spike,
        o_valid => spike_valid,
        o_neuron_addr => spike_neuron_addr,
        o_um => spike_um,
        o_finished_layer => spike_finished_layer
    );

SPIKE_MEM : entity work.Spike_Memory(rtl)
    generic map(
        GEN_ADDR_WIDTH => GEN_ADDR_WIDTH
    )
    port map(
        clk => clk,
        rst => rst,
        i_neuron_addr => spike_neuron_addr,
        i_spike => ctrl_spike,
        i_prev_layer_finished => spike_finished_layer,
        i_next_layer_finished => i_next_layer_finished,
        o_spikes => o_spikes,
        o_en => o_en,
        o_stall => stall,
        o_finished_layer => o_finished_layer
    );

end rtl;
