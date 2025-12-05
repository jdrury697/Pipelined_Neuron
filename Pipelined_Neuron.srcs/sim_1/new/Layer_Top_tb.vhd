----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/05/2025 01:58:08 PM
-- Design Name: 
-- Module Name: Layer_Top_tb - Behavioral
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

library std;
    use std.textio.all;
    use std.env.finish;

entity Layer_Top_tb is
--  Port ( );
end Layer_Top_tb;

architecture sim of Layer_Top_tb is

signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal i_en : std_logic := '0';
signal i_next_layer_finished : std_logic := '0';
signal o_spikes : sfixed(1 downto 0) := (others => '0');
signal o_finished_layer : std_logic := '0';
signal o_en : std_logic := '0';

constant PERIOD : time := 10ns;

begin

dut : entity work.Layer_Top(rtl)
    port map(
        clk => clk,
        rst => rst,
        i_en => i_en,
        i_next_layer_finished => i_next_layer_finished,
        o_spikes => o_spikes,
        o_finished_layer => o_finished_layer,
        o_en => o_en
    );

clk <= not clk after PERIOD/2;

sim_proc : process
begin
    rst <= '1';
    i_en <= '1';
    i_next_layer_finished <= '1';
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    rst <= '0';
    
    wait for 100ns;
    report "Simualtion Finished";
    finish;
end process;

end Behavioral;
