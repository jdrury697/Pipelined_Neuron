----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/11/2025 10:21:37 AM
-- Design Name: 
-- Module Name: Neuron_Memory - rtl
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
    
library ieee;
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Neuron_Memory is
    generic(
        GEN_ADDR_WIDTH              : natural := 2;
        GEN_NUM_WEIGHTS_PER_NEURON  : natural := 4;
        GEN_INIT_WEIGHTS            : std_logic_vector(255 downto 0) := (others => '0')
    );

    Port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        i_prev_spikes       : in std_logic_vector(GEN_NUM_WEIGHTS_PER_NEURON - 1 downto 0);
        i_new_Um            : in std_logic_vector(UM_WIDTH - 1 downto 0);
        i_neuron_addr       : in std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0);
        i_en                : in std_logic;
        i_valid             : in std_logic;
        
        o_curr_Um           : out um_t;
        o_weight_sum        : out std_logic_vector(WEIGHT_WIDTH downto 0); --Extra bit for overflow
        o_finished_layer    : out std_logic := '0';
        o_neuron_addr       : out std_logic_vector(GEN_ADDR_WIDTH - 1 downto 0);
        o_valid             : out std_logic
    );
end Neuron_Memory;

architecture rtl of Neuron_Memory is
        
constant NUM_NEURONS : natural := 2 ** GEN_ADDR_WIDTH;

subtype neuron_addr_t_l is unsigned(GEN_ADDR_WIDTH - 1 downto 0);
subtype weight_array_t_l is weight_array_t(0 to GEN_NUM_WEIGHTS_PER_NEURON - 1);

type neuron_t_l is record
    addr    : neuron_addr_t_l;
    Um      : um_t;
    weights : weight_array_t_l;
    valid   : std_logic;
end record;

type neuron_array_l_t is array(0 to NUM_NEURONS - 1) of neuron_t_l;

function init_neurons (
    constant GEN_INIT_WEIGHTS : std_logic_vector;
    constant NUM_NEURONS      : natural;
    constant GEN_NUM_WEIGHTS_PER_NEURON : natural
) return neuron_array_l_t is
    variable tmp : neuron_array_l_t;
    variable base_idx : integer;
    variable packed_idx : integer;
begin
    for n in 0 to NUM_NEURONS - 1 loop
        tmp(n).addr := to_unsigned(n, tmp(n).addr'length);
        for w in 0 to GEN_NUM_WEIGHTS_PER_NEURON - 1 loop
            packed_idx := n * GEN_NUM_WEIGHTS_PER_NEURON + w;
            base_idx := packed_idx * WEIGHT_WIDTH;
            tmp(n).weights(w) := GEN_INIT_WEIGHTS(base_idx + WEIGHT_WIDTH - 1 downto base_idx);
        end loop;
        tmp(n).Um := (others => '0');
        tmp(n).valid := '1';
    end loop;
    return tmp;
end function;

constant EXPECTED_WEIGHTS_LENGTH    : natural := NUM_NEURONS * GEN_NUM_WEIGHTS_PER_NEURON * WEIGHT_WIDTH;
constant TOTAL_NUM_WEIGHTS          : natural := NUM_NEURONS * GEN_NUM_WEIGHTS_PER_NEURON;

--signal neuron_idx : natural := 0;
signal neuron_idx : natural range 0 to NUM_NEURONS - 1 := 0;
signal neurons : neuron_array_l_t := init_neurons(GEN_INIT_WEIGHTS, NUM_NEURONS, GEN_NUM_WEIGHTS_PER_NEURON);

begin
    
assert GEN_INIT_WEIGHTS'length = EXPECTED_WEIGHTS_LENGTH
    report  "FATAL: Generic GEN_INIT_WEIGHTS has incorrect length | Expected: " &
            integer'image(EXPECTED_WEIGHTS_LENGTH) & " | Actual length: " &
            integer'image(GEN_INIT_WEIGHTS'length)
    severity failure;    

compute_weight_sum : process(clk, rst)
variable sum : signed(WEIGHT_WIDTH downto 0) := (others => '0');
begin
    if rst = '1' then
        neuron_idx <= 0;
        o_weight_sum <= (others => '0');
        o_curr_Um <= (others => '0');
        o_neuron_addr <= std_logic_vector(neurons(neuron_idx).addr);
        o_finished_layer <= '0';
        o_valid <= '0';
        
        for n in 0 to NUM_NEURONS - 1 loop
            neurons(n).Um <= (others => '0');
            neurons(n).valid <= '1';
        end loop;
    
    elsif rising_edge(clk) then
            
        o_valid          <= '0';
        o_finished_layer <= '0';
        
        if i_valid = '1' then
            neurons(to_integer(unsigned(i_neuron_addr))).um <= signed(i_new_Um);
            --Ensures that the neuron is written to before new um is calculated each time
            neurons(to_integer(unsigned(i_neuron_addr))).valid <= '1';
        end if;
        
        if i_en = '1' then  
            sum := (others => '0');
            for w in 0 to GEN_NUM_WEIGHTS_PER_NEURON - 1 loop
                if i_prev_spikes(w) = '1' then
                    sum := sum + signed(neurons(neuron_idx).weights(w));
                end if;
            end loop;
            o_weight_sum <= std_logic_vector(sum);
            o_curr_Um <= neurons(neuron_idx).Um;
            o_neuron_addr <= std_logic_vector(neurons(neuron_idx).addr);
            -- Valid here is in case the number of neurons is smaller than the number of cycles it takes to get through the pipeline
            if neurons(neuron_idx).valid = '1' then
                o_valid <= '1';
                if neuron_idx = NUM_NEURONS - 1 then
                    neuron_idx <= 0;
                    o_finished_layer <= '1';
                else
                    neuron_idx <= neuron_idx + 1;
                    o_finished_layer <= '0';
                end if;
            end if;
            neurons(neuron_idx).valid <= '0';
        end if;
    end if;
end process;

end rtl;