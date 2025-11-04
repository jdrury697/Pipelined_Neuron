----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/12/2025 08:58:41 AM
-- Design Name: 
-- Module Name: Neuron_pkg - Behavioral
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

package Neuron_pkg is
    
    constant UM_WIDTH       : natural := 27;
    constant WEIGHT_WIDTH   : natural := 16;
    constant NEURON_ADDR_WIDTH : natural := 6;
    
    subtype weight_t is std_logic_vector(WEIGHT_WIDTH - 1 downto 0);
    subtype um_t          is signed(UM_WIDTH - 1 downto 0);
    subtype neuron_addr_t is unsigned;
    
    type weight_array_t is array(natural range <>) of weight_t;
    
    
    type neuron_t is record
        addr    : neuron_addr_t;
        Um      : um_t;
        weights : weight_array_t;
        valid   : std_logic;
    end record;
    
    type neuron_array_t is array(natural range <>) of neuron_t;
    

end package;
