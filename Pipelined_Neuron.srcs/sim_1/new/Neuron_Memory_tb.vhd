----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2025 10:32:09 AM
-- Design Name: 
-- Module Name: Neuron_Memory_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Neuron_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library std;
    use std.textio.all;
    use std.env.finish;


entity Neuron_Memory_tb is
end Neuron_Memory_tb;

architecture sim of Neuron_Memory_tb is

constant NUM_WEIGHTS_PER_NEURON : natural := 4;
constant ADDR_WIDTH             : natural := 2;
constant NUM_NEURONS            : natural := 2 ** ADDR_WIDTH;
constant PERIOD : time := 10 ns;

constant RESET_UM : um_t := (others => '0');
constant RESET_ADDR : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
constant TEST_4_SUM : std_logic_vector(WEIGHT_WIDTH downto 0) := "11111111111111011";

signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal prev_spikes : std_logic_vector(NUM_WEIGHTS_PER_NEURON - 1 downto 0) := (others => '0');
signal new_Um : std_logic_vector(UM_WIDTH - 1 downto 0) := (others => '0');
signal in_neuron_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
signal en : std_logic := '0';
signal in_valid : std_logic := '0';
signal curr_Um : um_t := (others => '0');
signal weight_sum : std_logic_vector(WEIGHT_WIDTH downto 0) := (others => '0');
signal finished_layer : std_logic := '0';
signal out_neuron_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
signal out_valid : std_logic := '0';

begin

dut : entity work.Neuron_Memory(rtl)
    generic map(
        GEN_ADDR_WIDTH => ADDR_WIDTH,
        GEN_NUM_WEIGHTS_PER_NEURON => NUM_WEIGHTS_PER_NEURON,
        GEN_INIT_WEIGHTS => "0000000000000011000000000000101011111111111110000000000000001100000000000000001100000000000010101111111111111000000000000000110000000000000000110000000000001010111111111111100000000000000011000000000000000011000000000000101011111111111110000000000000001100"
    )
    port map(
        clk => clk,
        rst => rst,
        i_prev_spikes => prev_spikes,
        i_new_Um => new_Um,
        i_neuron_addr => in_neuron_addr,
        i_en => en,
        i_valid => in_valid,
        o_curr_Um => curr_Um,
        o_weight_sum => weight_sum,
        o_finished_layer => finished_layer,
        o_neuron_addr => out_neuron_addr,
        o_valid => out_valid
    );

    clk <= not clk after PERIOD/2;
    
    sim_proc: process
    begin
        rst <= '1';
        prev_spikes <= (others => '0');
        new_Um <= (others => '0');
        en <= '1';
        in_valid <= '1';
        in_neuron_addr <= "00";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        report "Test 1";
        assert curr_Um = RESET_UM
            report "Um Reset Failed at neuron address:" & to_hstring(to_bitvector(out_neuron_addr)) & " | Expected output: " & to_hstring(to_bitvector(std_logic_vector(RESET_UM))) & " | Actual output: " & to_hstring(to_bitvector(std_logic_vector(curr_um)))
            severity error;
        assert out_neuron_addr = RESET_ADDR
            report "o_neuron_addr Reset Failed | Expected output: " & to_hstring(to_bitvector(RESET_ADDR)) & " | Actual output: " & to_hstring(to_bitvector(out_neuron_addr))
            severity error;
        assert out_valid = '0'
            report "o_valid did not correctly output on a reset | Expected value: 0 | Actual value: " & std_logic'image(out_valid)
            severity error;
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        
        rst <= '0';
        prev_spikes <= (others => '1');
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        --Test all weights added (3, 10, -8, 12)
        --Sum should be 17 (decimal)
        report "Test 2";
        assert curr_Um = RESET_UM
            report "Um updated when it shouldn't be at neuron address: " & to_hstring(to_bitvector(out_neuron_addr)) & " | Expected output: " & to_hstring(to_bitvector(std_logic_vector(RESET_UM))) & " | Actual output: " & to_hstring(to_bitvector(std_logic_vector(curr_um)))
            severity error;
        assert weight_sum = "00000000000010001"
            report "Weight sum was not calculated correctly at neuron address: " & to_hstring(to_bitvector(out_neuron_addr)) & " | Expected sum: "  & to_hstring("00000000000010001") &  " | Actual output: " & to_hstring(to_bitvector(std_logic_vector(weight_sum)))
            severity error;
        assert out_neuron_addr = "00"
            report "Neuron address output incorrectly | Expected address: 0b00 | Actual address: " & to_hstring(to_bitvector(out_neuron_addr))
            severity error;
        assert out_valid = '1'
            report "o_valid did not correctly output on a valid computation | Expected value: 1 | Actual value: " & std_logic'image(out_valid)
            severity error;
        
        --Reset Everything again
        rst <= '1';
        en <= '0';
        prev_spikes <= (others => '0');
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        rst <= '0';
        --Set internal U_m values
        report "Setting neuron 0 U_m value";
        in_valid <= '1';
        in_neuron_addr <= "00";
        new_Um <= "000000000000000000000000001";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        report "Setting neuron 1 U_m value";
        in_valid <= '1';
        in_neuron_addr <= "01";
        new_Um <= "000000000000000000000000010";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        report "Setting neuron 2 U_m value";
        in_valid <= '1';
        in_neuron_addr <= "10";
        new_Um <= "000000000000000000000000100";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        report "Setting neuron 3 U_m value";
        in_valid <= '1';
        in_neuron_addr <= "11";
        new_Um <= "000000000000000000000001000";
        
        report "Test valid with en = 0";
        assert out_valid = '0'
            report "o_valid did not correctly output when enable = 0 | Expected value: 0 | Actual value: " & std_logic'image(out_valid)
            severity error;

        wait until rising_edge(clk);
        wait until falling_edge(clk);
        
        --Check U_m values
        in_valid <= '0';
        new_Um <= (others => '0');
        en <= '1';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        report "Test 3";
        assert out_neuron_addr = "00"
            report "Neuron address output incorrectly | Expected address: 0x0 | Actual address: " & to_hstring(to_bitvector(out_neuron_addr))
            severity error;
        assert curr_Um = "000000000000000000000000001"
            report "Um at neuron address 0 not updated correctly | Expected value: 0x0000001 | Acutal value: " & to_hstring(to_bitvector(std_logic_vector(curr_Um)))
            severity error;
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_neuron_addr = "01"
            report "Neuron address output incorrectly | Expected address: 0x1 | Actual address: " & to_hstring(to_bitvector(out_neuron_addr))
            severity error;
        assert curr_Um = "000000000000000000000000010"
            report "Um at neuron address 1 not updated correctly | Expected value: 0x0000002 | Acutal value: " & to_hstring(to_bitvector(std_logic_vector(curr_Um)))
            severity error;
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_neuron_addr = "10"
            report "Neuron address output incorrectly | Expected address: 0x2 | Actual address: " & to_hstring(to_bitvector(out_neuron_addr))
            severity error;
        assert curr_Um = "000000000000000000000000100"
            report "Um at neuron address 2 not updated correctly | Expected value: 0x0000004 | Acutal value: " & to_hstring(to_bitvector(std_logic_vector(curr_Um)))
            severity error;
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_neuron_addr = "11"
            report "Neuron address output incorrectly | Expected address: 0x3 | Actual address: " & to_hstring(to_bitvector(out_neuron_addr))
            severity error;
        assert curr_Um = "000000000000000000000001000"
            report "Um at neuron address 3 not updated correctly | Expected value: 0x0000001 | Acutal value: " & to_hstring(to_bitvector(std_logic_vector(curr_Um)))
            severity error;
            
        --Test diff combinations of prev_spikes
        prev_spikes <= "1010"; --3 and -8 should be spiking so sum is -5
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        report "Test 4";
        assert weight_sum = TEST_4_SUM
            report "Sum with in spikes = 1010 incorrectly calculated | Expected value: " & to_hstring(to_bitvector(TEST_4_SUM)) & " | Actual value: " & to_hstring(to_bitvector(weight_sum))
            severity error;
            
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_valid = '0'
            report "Valid not correctly set to 0 when neuron not written to"
            severity error;
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_neuron_addr = "00"
            report "Neuron address incremented when neuron should be invalid | Expected value 0x0 | Actual value: " & to_hstring(to_bitvector(out_neuron_addr))
            severity error;
        
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        report "Simulation Finished";
        finish;
    end process;
end sim;
