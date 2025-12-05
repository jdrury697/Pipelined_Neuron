----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/18/2025 09:22:44 AM
-- Design Name: 
-- Module Name: Layer_Top - rtl
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
use IEEE.FIXED_PKG.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Layer_Top is
    port(
        clk : in std_logic;
        rst : in std_logic;
        --i_prev_spikes : in sfixed(7 downto 0);
        i_en : in std_logic;
        i_next_layer_finished : in std_logic;
        o_spikes : out sfixed(1 downto 0);
        o_finished_layer : out std_logic;
        o_en : out std_logic
    );
end Layer_Top;

architecture rtl of Layer_Top is

--constant ADDR_WIDTH : natural := 3;
--constant NUM_WEIGHTS_PER_NEURON : natural := 8;
--constant INIT_WEIGHTS : std_logic_vector(1023 downto 0) := "0000000001000000000000000011111100000000001111100000000000111101000000000011110000000000001110110000000000111010000000000011100100000000001110000000000000110111000000000011011000000000001101010000000000110100000000000011001100000000001100100000000000110001000000000011000000000000001011110000000000101110000000000010110100000000001011000000000000101011000000000010101000000000001010010000000000101000000000000010011100000000001001100000000000100101000000000010010000000000001000110000000000100010000000000010000100000000001000000000000000011111000000000001111000000000000111010000000000011100000000000001101100000000000110100000000000011001000000000001100000000000000101110000000000010110000000000001010100000000000101000000000000010011000000000001001000000000000100010000000000010000000000000000111100000000000011100000000000001101000000000000110000000000000010110000000000001010000000000000100100000000000010000000000000000111000000000000011000000000000001010000000000000100000000000000001100000000000000100000000000000001";
constant ADDR_WIDTH : natural := 1;
constant NUM_WEIGHTS_PER_NEURON : natural := 1;
constant INIT_WEIGHTS : std_logic_vector(31 downto 0) := "00000000000000000001000000000000";
constant TAU : std_logic_vector(17 downto 0) := "000000000000000010";

signal spikes : std_logic_vector(1 downto 0);
constant polynomial : std_logic_vector(15 downto 0) := (15 => '1', 14 => '1', 12 => '1', 3 =>'1', others => '0'); 
constant seed : std_logic_vector(15 downto 0) := (others => '1');
signal pr_num : std_logic_vector(15 downto 0) := (others => '0');
signal feedback : std_logic_vector(0 downto 0) := (others => '0');

begin

LFSR_UNIT : entity work.lfsr(structural)
    port map(
        clk => clk,
        rst => rst,
        poly_mask => polynomial,
        seed => seed,
        feedin => feedback,
        feedout => feedback,
        history => pr_num
    );

NEURON_LAYER : entity work.Network_Layer(rtl)
    generic map(
        GEN_ADDR_WIDTH => ADDR_WIDTH,
        GEN_NUM_WEIGHTS_PER_NEURON => NUM_WEIGHTS_PER_NEURON,
        GEN_INIT_WEIGHTS => INIT_WEIGHTS,
        GEN_TAU => TAU
    )
    port map(
        clk => clk,
        rst => rst,
        --i_prev_spikes => std_logic_vector(i_prev_spikes),
        i_prev_spikes => feedback,
        i_en => i_en,
        i_next_layer_finished => i_next_layer_finished,
        o_spikes => spikes,
        o_finished_layer => o_finished_layer,
        o_en => o_en  
    );
    
o_spikes <= to_sfixed(spikes, o_spikes'high, o_spikes'low);
    
end rtl;
