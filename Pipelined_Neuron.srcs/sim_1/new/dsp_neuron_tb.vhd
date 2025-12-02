----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/10/2025 09:12:43 AM
-- Design Name: 
-- Module Name: dsp_neuron_tb - Behavioral
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

-- NOT WORKING RIGHT! NEED TO FIX!

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

library std;
    use std.textio.all;
    use std.env.finish;

entity dsp_neuron_tb is
end dsp_neuron_tb;

architecture sim of dsp_neuron_tb is

constant PERIOD     : time := 10 ns;
constant ADDR_WIDTH : natural := 2;
constant ADDR_RESET : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');

signal clk              : std_logic := '0';
signal rst              : std_logic := '0';
signal stall            : std_logic := '0';
signal i_valid          : std_logic := '0';
signal i_V              : std_logic_vector(24 downto 0) := (others => '0');
signal i_T              : std_logic_vector(17 downto 0) := (others => '0');
signal i_neuron_addr    : std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal i_finished_layer : std_logic := '0';
signal i_Um             : std_logic_vector(29 downto 0) := (others => '0'); -- input C and D
signal o_Um             : std_logic_vector(26 downto 0);
signal o_overflow       : std_logic;
signal o_valid          : std_logic;
signal o_neuron_addr    : std_logic_vector(ADDR_WIDTH - 1 downto 0);
signal o_finished_layer : std_logic;

constant RESET_ASSERT : std_logic_vector := "000000000000000000000000000";


begin

    dut : entity work.dsp_neuron(rtl)
        generic map(
            GEN_ADDR_WIDTH => ADDR_WIDTH
        )
        port map(
            clk                 => clk,
            rst                 => rst,
            stall               => stall,
            i_valid             => i_valid,
            i_V                 => i_V,
            i_T                 => i_T,
            i_Um                => i_Um,
            i_neuron_addr       => i_neuron_addr,
            i_finished_layer    => i_finished_layer,
            o_Um                => o_Um,
            o_overflow          => o_overflow,
            o_valid             => o_valid,
            o_neuron_addr       => o_neuron_addr,
            o_finished_layer    => o_finished_layer
        );
        
    clk <= not clk after PERIOD/2;
    
    sim_proc: process
    begin
        rst <= '1';
        i_V <= "0000000000000110011001101";
        i_T <= "000000001100110011";
        i_Um <= "000000000000000000101000010000";
        i_neuron_addr <= "00";
        stall <= '0';
        wait until rising_edge(clk); -- clk 1
        wait until falling_edge(clk);
        assert o_Um = RESET_ASSERT
            report "Reset Failed | Expected output: 0x0000000 | Actual output: " & to_hstring(to_bitvector(o_Um))
            severity error;
        assert o_valid = '0'
            report "Reset Failed | valid not set to 0"
            severity error;
        assert o_neuron_addr = ADDR_RESET
            report "Reset Failed | Neuron Address was not set to 0"
            severity error;
        rst <= '0';
        wait until rising_edge(clk); -- clk 2
        wait until falling_edge(clk);
        i_V <= "0000000000000111101101000";
        i_T <= "000000000011001101";
        i_Um <= "000000000000000000000001111111";
        i_valid <= '1';
        i_finished_layer <= '1';
        i_neuron_addr <= "10";
        wait until rising_edge(clk); -- clk 3
        wait until falling_edge(clk);
        assert o_valid = '0'
            report "Valid signal falsely output as 1"
            severity error;
        assert o_finished_layer = '0'
            report "Finished layer signal falsely output as 1"
            severity error;
        assert o_neuron_addr = "00"
            report "Neuron address output wrong | Expected value: 0 | Actual value: " & to_hstring(to_bitvector(o_neuron_addr))
            severity error;
        
        i_V <= "0000000000000011010111000";
        i_T <= "000000001100110011";
        i_Um <= "000000000000000000110101001100";
        wait until rising_edge(clk); -- clk 4
        wait until falling_edge(clk);
        assert o_valid = '0'
            report "Valid signal falsely output as 1"
            severity error;
        assert o_finished_layer = '0'
            report "Finished layer signal falsely output as 1"
            severity error;
        assert o_neuron_addr = "00"
            report "Neuron address output wrong | Expected value: 0 | Actual value: " & to_hstring(to_bitvector(o_neuron_addr))
            severity error;
        
        i_V <= (others => '0');
        i_T <= (others => '0');
        i_Um <= (others => '0');
        stall <= '1';
        wait until rising_edge(clk); -- clk 5
        wait until falling_edge(clk);
        assert o_valid = '0'
            report "Valid signal falsely output as 1"
            severity error;
        assert o_finished_layer = '0'
            report "Finished layer signal falsely output as 1"
            severity error;
        assert o_neuron_addr = "00"
            report "Neuron address output wrong | Expected value: 0 | Actual value: " & to_hstring(to_bitvector(o_neuron_addr))
            severity error;
        
        wait until rising_edge(clk); -- clk 6
        wait until falling_edge(clk);
        
        assert o_valid = '0'
            report "Valid signal failed to stall"
            severity error;
        assert o_finished_layer = '0'
            report "Finished layer signal failed to stall"
            severity error;
        assert o_neuron_addr = "00"
            report "Neuron address failed to stall | Expected value: 0 | Actual value: " & to_hstring(to_bitvector(o_neuron_addr))
            severity error;
            
        stall <= '0';
            
        wait until rising_edge(clk); -- clk 7
        wait until falling_edge(clk);

        assert o_Um = "000" & x"000A9C"
            report "First calcualtion failed | Expected output: 0x0000A9C | Actual output: " & to_hstring(to_bitvector(o_Um))
            severity error;
        assert o_valid = '0'
            report "Valid signal falsely output as 1"
            severity error;
        assert o_finished_layer = '1'
            report "Finished layer signal did not carry through with the um calculation"
            severity error;
        wait until rising_edge(clk); -- clk 8
        wait until falling_edge(clk);
        assert o_neuron_addr = "10"
            report "Neuron address output wrong | Expected value: 2 | Actual value: " & to_hstring(to_bitvector(o_neuron_addr))
            severity error;
        
        assert o_Um = "000" & x"00013E"
            report "Second calcualtion failed | Expected output: 0x000013E | Actual output: " & to_hstring(to_bitvector(o_Um))
            severity error;
        assert o_valid = '1'
            report "Valid signal did not carry through with the um calculation"
            severity error;
        assert o_finished_layer = '1'
            report "Finished layer signal did not carry through with the um calculation"
            severity error;
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert o_Um = "000" & x"000BFB"
            report "Third calcualtion failed | Expected output: 0x0000BFB | Actual output: " & to_hstring(to_bitvector(o_Um))
            severity error;
        assert o_valid = '1'
            report "Valid signal did not carry through with the um calculation"
            severity error;
        assert o_finished_layer = '1'
            report "Finished layer signal did not carry through with the um calculation"
            severity error;
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        
        report "Simulation Finished";
        finish;
    end process;
end sim;
