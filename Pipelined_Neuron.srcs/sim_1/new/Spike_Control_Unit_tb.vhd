----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/11/2025 09:36:06 AM
-- Design Name: 
-- Module Name: Spike_Control_Unit_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library std;
    use std.textio.all;
    use std.env.finish;

entity Spike_Control_Unit_tb is
end Spike_Control_Unit_tb;

architecture sim of Spike_Control_Unit_tb is

signal neuron_voltage   : std_logic_vector(26 downto 0) := (others => '0');
signal overflow         : std_logic := '0';
signal spike            : std_logic := '0';
signal um               : std_logic_vector(26 downto 0) := (others => '0');
signal i_valid          : std_logic := '0';
signal o_valid          : std_logic := '0';

constant delay          : time := 10 ns;
constant ZERO           : std_logic_vector(26 downto 0) := (others => '0');

begin

    dut : entity work.Spike_Control_Unit(rtl)
        port map(
            i_neuron_voltage    => neuron_voltage,
            i_overflow          => overflow,
            i_valid             => i_valid,
            o_valid             => o_valid,
            o_spike             => spike,
            o_um                => um
        );

    sim_proc : process
    begin
        wait for delay;
        neuron_voltage <= "000" & x"00000A";
        i_valid <= '1';
        wait for delay;
        assert spike = '0'
            report "Spike incorrectly detected when neuron_voltage = 0x000000A"
            severity error;
        assert um = neuron_voltage
            report "Membrane potential did not output the correct value | Expected 0x000000A | Actual Result:" & to_hstring(to_bitvector(um))
            severity error;
        wait for delay;
        overflow <= '1';
        wait for delay;
        assert spike = '1'
            report "Spike did not fire when overflow occured"
            severity error;
        assert um = ZERO
            report "Membrane potential did not output the correct value | Expected 0x0000000 | Actual Result:" & to_hstring(to_bitvector(um))
            severity error;
        wait for delay;
        overflow <= '0';
        wait for delay;
        assert spike = '0'
            report "Spike continued to fire even after overflow was set back to 0"
            severity error;
        assert um = neuron_voltage
            report "Membrane potential did not output the correct value | Expected 0x000000A | Actual Result:" & to_hstring(to_bitvector(um))
            severity error;
        wait for delay;
        neuron_voltage <= "000" & x"0000FF";
        wait for delay;
        assert spike = '0'
            report "Spike fired when neuron voltage equaled threshold voltage (0x00000FF)"
            severity error;
        assert um = neuron_voltage
            report "Membrane potential did not output the correct value | Expected 0x00000FF | Actual Result:" & to_hstring(to_bitvector(um))
            severity error;
        wait for delay;
        neuron_voltage <= "000" & x"000100";
        wait for delay;
        assert spike = '1'
            report "Spike faield to fire when neuron voltage was 0x0000100 which is larger than the threshold"
            severity error;
        assert um = ZERO
            report "Membrane potential did not output the correct value | Expected 0x0000000 | Actual Result:" & to_hstring(to_bitvector(um))
            severity error;
        wait for delay;
        i_valid <= '0';
        wait for delay;
        assert spike = '0'
            report "Spike fired when i_valid = 0"
            severity error;
        wait for delay;
        overflow <= '1';
        wait for delay;
        assert spike = '0'
            report "Spike fired when i_valid = 0"
            severity error;
        wait for delay;
        i_valid <= '1';
        wait for delay;
        assert spike = '1'
            report "Spike didn't fire when valid was set back to 1"
            severity error;
        wait for delay;
        report "Simulation Finished";
        finish;
    end process;
end sim;
