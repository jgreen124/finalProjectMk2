----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2024 08:58:22 PM
-- Design Name: 
-- Module Name: moneyManager - Behavioral
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

entity moneyManager is
  Port (
    clk : in std_logic;
    player1Bid, player2Bid : in std_logic_vector(3 downto 0); --max bid will be 15, a 4 bit number
    player1Turn, player2Turn : in std_logic;
    player1Data, player2Data : out std_logic_vector(7 downto 0) --max money will be 127
  );
end moneyManager;

architecture Behavioral of moneyManager is

signal player1Money, player2Money : std_logic_vector(7 downto 0);

   

begin
player1Data <= player1Money;
player2Data <= player2Money;

player1Action : process(clk)
begin
if(rising_edge(clk)) then
    if(rising_edge(player1Turn)) then
        player1Money <= std_logic_vector(signed(player1Money) - signed(player1Bid));
    end if;
    end if;
    end process;
    
player2Action : process(clk)
begin
if(rising_edge(player2Turn)) then
    if(rising_edge(player2Turn)) then
        player2Money <= std_logic_vector(signed(player2Money) - signed(player2Bid));
    end if;
    end if;
    end process;    

end Behavioral;
