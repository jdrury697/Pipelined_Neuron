----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/11/2025 08:15:58 AM
-- Design Name: 
-- Module Name: Spike_Control_Unit - rtl
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

entity Spike_Control_Unit is
    generic(
        GEN_ADDR_WIDTH : natural := 2
    );
    Port (
        i_neuron_voltage    : in std_logic_vector(26 downto 0);
        i_overflow          : in std_logic;
        i_valid             : in std_logic;
        i_neuron_addr       : in std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0);
        i_finished_layer    : in std_logic;
        o_spike             : out std_logic;
        o_valid             : out std_logic;
        o_neuron_addr       : out std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0);
        o_um                : out std_logic_vector(26 downto 0);
        o_finished_layer    : out std_logic
    );
end Spike_Control_Unit;

architecture rtl of Spike_Control_Unit is

-- Output a spike if the incoming voltage overflowed, or was higher than the spiking threshold
constant spike_threshold    : signed(26 downto 0) := "000" & x"0000FF";
signal is_spiking           : boolean := FALSE;

begin

    is_spiking <= (i_overflow = '1' or (signed(i_neuron_voltage) > spike_threshold)) and (i_valid = '1');
    o_valid <= i_valid;
    o_neuron_addr <= i_neuron_addr;
    o_spike <=  '1' when is_spiking else '0';
    o_um <= (others => '0') when is_spiking else i_neuron_voltage;
    o_finished_layer <= i_finished_layer;
end rtl;
