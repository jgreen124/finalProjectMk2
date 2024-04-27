----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2024 03:38:36 PM
-- Design Name: 
-- Module Name: oledInputData - Behavioral
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

entity oledInputData is
Port (
    clk : in std_logic;
    sw : in std_logic;
    displayInfo : out std_logic_vector(87 downto 0):= (others =>'0') );
end oledInputData;

architecture Behavioral of oledInputData is

begin

    process(clk) begin
        if rising_edge(clk) then
            if(sw = '1') then
                displayInfo <= (others => '1');
            else
                displayInfo <= (others => '0');
                
            end if;
        end if;
    end process;

end Behavioral;
