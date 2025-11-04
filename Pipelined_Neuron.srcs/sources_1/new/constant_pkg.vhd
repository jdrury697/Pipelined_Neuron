----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2025 10:56:25 AM
-- Design Name: 
-- Module Name: constant_pkg - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package constant_pkg is
    
    constant UM_WIDTH       : natural := 27;
    constant WEIGHT_WIDTH   : natural := 16;
    constant NEURON_ADDR_WIDTH : natural := 6;
    
    type um_array_t is array(natural range <>) of std_logic_vector(UM_WIDTH - 1 downto 0);
    
end package;