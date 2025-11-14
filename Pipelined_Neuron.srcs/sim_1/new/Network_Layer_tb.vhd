----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2025 01:34:48 PM
-- Design Name: 
-- Module Name: Network_Layer_tb - sim
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

entity Network_Layer_tb is
end Network_Layer_tb;

architecture sim of Network_Layer_tb is

constant ADDR_WIDTH : natural := 2;
constant NUM_WEIGHTS_PER_NEURON : natural := 4;

constant PERIOD : time := 10 ns;


signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal i_prev_spikes : std_logic_vector(NUM_WEIGHTS_PER_NEURON - 1 downto 0) := (others => '0');
signal i_en : std_logic := '0';
signal i_next_layer_finished : std_logic := '0';
signal o_spikes : std_logic_vector(2 ** ADDR_WIDTH - 1 downto 0) := (others => '0');
signal o_finished_layer : std_logic := '0';
signal o_en : std_logic := '0';

begin

dut : entity work.Network_Layer(rtl)
    generic map(
        GEN_ADDR_WIDTH              => ADDR_WIDTH,
        GEN_NUM_WEIGHTS_PER_NEURON  => NUM_WEIGHTS_PER_NEURON,
        -- All 1s for neuron 0 all 2s for neuron 1 all 3s for neuron 2 and all 4s for neuron 3
        GEN_INIT_WEIGHTS            => "0000000000000100000000000000010000000000000001000000000000000100000000000000001100000000000000110000000000000011000000000000001100000000000000100000000000000010000000000000001000000000000000100000000000000001000000000000000100000000000000010000000000000001",
        GEN_TAU                     => "00" & x"0002"
    )
    port map(
        clk => clk,
        rst => rst,
        i_prev_spikes => i_prev_spikes,
        i_en => i_en,
        i_next_layer_finished => i_next_layer_finished,
        o_spikes => o_spikes,
        o_finished_layer => o_finished_layer,
        o_en => o_en
    );
    
clk <= not clk after PERIOD/2;

sim_proc: process
begin
    rst <= '1';
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    rst <= '0';
    i_en <= '1';
    i_prev_spikes <= (others => '1');
    i_next_layer_finished <= '1';
    
    wait for 80ns;
    
    i_next_layer_finished <= '1';
    
    wait for PERIOD;
    
    --i_next_layer_finished <= '0';
    
    wait for 200ns;
    
    finish;
    
end process;

end sim;
