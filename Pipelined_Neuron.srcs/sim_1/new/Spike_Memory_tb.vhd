----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2025 10:40:57 AM
-- Design Name: 
-- Module Name: Spike_Memory_tb - Behavioral
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

entity Spike_Memory_tb is
end Spike_Memory_tb;

architecture sim of Spike_Memory_tb is

    constant ADDR_WIDTH : natural := 2;
    constant PERIOD : time := 10 ns;
    
    constant SPIKE_RESET : std_logic_vector(2 ** ADDR_WIDTH - 1 downto 0) := (others => '0');
    
    signal clk                      : std_logic := '0';
    signal rst                      : std_logic := '0';
    signal i_neuron_addr            : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal i_spike                  : std_logic := '0';
    signal i_prev_layer_finished    : std_logic := '0';
    signal i_next_layer_finished    : std_logic := '0';
    signal o_spikes                 : std_logic_vector(2 ** ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal o_en                     : std_logic := '0';
    signal o_stall                  : std_logic := '0';
    signal o_finished_layer         : std_logic := '0';
    

begin

dut : entity work.Spike_Memory(rtl)
    generic map(
        GEN_ADDR_WIDTH => ADDR_WIDTH
    )
    port map(
        clk => clk,
        rst => rst,
        i_neuron_addr => i_neuron_addr,
        i_spike => i_spike,
        i_prev_layer_finished => i_prev_layer_finished,
        i_next_layer_finished => i_next_layer_finished,
        o_spikes => o_spikes,
        o_en => o_en,
        o_stall => o_stall,
        o_finished_layer => o_finished_layer
    );

clk <= not clk after PERIOD/2;

sim_proc: process
begin
    rst <= '1';
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    assert o_spikes = SPIKE_RESET
        report "Output spike vector did not reset correctly | Expected Value: 0x0 | Actual Value: " & to_hstring(to_bitvector(o_spikes))
        severity error;
    assert o_stall = '0'
        report "Stall did not reset to 0"
        severity error;
    assert o_en = '1'
        report "Enable did not reset to 1"
        severity error;
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    
    rst <= '0';
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    i_prev_layer_finished <= '0';
    i_next_layer_finished <= '0';
    wait for PERIOD/4;
    assert o_en = '1'
        report "Enable did not output 1 when both layers are not finished"
        severity error;
    assert o_stall = '0'
        report "Stalled when both layers are not finshed"
        severity error;
    assert o_finished_layer = '0'
        report "Finished layer did not properly pass through"
        severity error;
    i_prev_layer_finished <= '1';
    i_next_layer_finished <= '0';
    wait for PERIOD/4;
    assert o_en = '1'
        report "Enable set to 0 when next layer was still computing"
        severity error;
    assert o_stall = '1'
        report "Did not stall when previous layer finished but next layer still computing"
        severity error;
    assert o_finished_layer = '1'
        report "Finished layer did not properly pass through"
        severity error;
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    i_prev_layer_finished <= '0';
    i_next_layer_finished <= '1';
    wait for PERIOD/4;
    assert o_en = '0'
        report "Enable not set to 0 when next layer finished but previous layer still computing"
        severity error;
    assert o_stall = '0'
        report "Stalled when previous layer still computing"
        severity error;
    assert o_finished_layer = '0'
        report "Finished layer did not properly pass through"
        severity error;
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    i_prev_layer_finished <= '1';
    i_next_layer_finished <= '1';
    wait for PERIOD/4;
    assert o_en = '1'
        report "Enable falsely set to 0 when both layers finished"
        severity error;
    assert o_stall = '0'
        report "Stalled when both layers finished"
        severity error;
    assert o_finished_layer = '1'
        report "Finished layer did not properly pass through"
        severity error;
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    --Put 1001 into spikes
    i_prev_layer_finished <= '0';
    i_next_layer_finished <= '0';
    i_spike <= '1';
    i_neuron_addr <= "00";
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    assert o_spikes = SPIKE_RESET
        report "o_spikes updated before both layers finished"
        severity error;
    assert o_finished_layer = '0'
        report "Finished layer did not properly pass through"
        severity error;
    i_spike <= '0';
    i_neuron_addr <= "01";
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    assert o_spikes = SPIKE_RESET
        report "o_spikes updated before both layers finished"
        severity error;
    i_spike <= '0';
    i_neuron_addr <= "10";
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    assert o_spikes = SPIKE_RESET
        report "o_spikes updated before both layers finished"
        severity error;
    i_spike <= '1';
    i_neuron_addr <= "11";
    i_prev_layer_finished <= '1';
    i_next_layer_finished <= '1';
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    assert o_spikes = "1001"
        report "o_spikes did not update when both layers finished | Expected value: 0x9 | Actual value: " & to_hstring(to_bitvector(o_spikes))
        severity error;
    assert o_finished_layer = '1'
        report "Finished layer did not properly pass through"
        severity error;
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    assert o_spikes = SPIKE_RESET
        report "o_spikes did not properly reset after being set"
        severity error;
    assert o_en = '1'
        report "Enable not properly reset"
        severity error;
    assert o_stall = '0'
        report "Stall not properly reset"
        severity error;
        
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    report "Simulation Finished";
    finish;
    
end process;

end sim;
