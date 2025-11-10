----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2025 09:20:53 AM
-- Design Name: 
-- Module Name: Spike_Memory - rtl
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity Spike_Memory is
    generic(
        GEN_ADDR_WIDTH : natural := 2
    );
    Port ( 
        clk                     : in std_logic;
        rst                     : in std_logic;
        i_neuron_addr           : in std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0);
        i_spike                 : in std_logic;
        i_prev_layer_finished   : in std_logic;
        i_next_layer_finished   : in std_logic;
        o_spikes                : out std_logic_vector(2 ** GEN_ADDR_WIDTH - 1 downto 0);
        o_en                    : out std_logic;
        o_stall                 : out std_logic
    );
end Spike_Memory;

architecture rtl of Spike_Memory is

    constant max_addr : std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0) := (others => '1');

    signal new_spikes : std_logic_vector(2 ** GEN_ADDR_WIDTH - 1 downto 0);
    signal curr_spikes : std_logic_vector(2 ** GEN_ADDR_WIDTH - 1 downto 0);
    

begin
    
write_vector : process(clk, rst)
begin
    if rst = '1' then
        new_spikes <= (others => '0');
        curr_spikes <= (others => '0');
    elsif rising_edge(clk) then
        new_spikes(to_integer(unsigned(i_neuron_addr))) <= i_spike;
        if i_prev_layer_finished = '1' and i_next_layer_finished = '1' then
            curr_spikes <= new_spikes;
            curr_spikes(to_integer(unsigned(i_neuron_addr))) <= i_spike;
        end if;
    end if;
end process;

o_stall <= '1' when i_prev_layer_finished = '1' and i_next_layer_finished = '0' else '0';
o_en <= '0' when i_prev_layer_finished = '0' and i_next_layer_finished = '1' else '1';
o_spikes <= curr_spikes;

end rtl;
