----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2024 01:20:39 AM
-- Design Name: 
-- Module Name: randomNumGenerator - randomNumGenerator_arch
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

entity randomNumGenerator is
    Port ( randomNum : out STD_LOGIC_vector(5 downto 0);
         clk : in STD_LOGIC);
end randomNumGenerator;

architecture randomNumGenerator_arch of randomNumGenerator is

    signal lfsr : std_logic_vector(5 downto 0) := "101010";
    signal shift : std_logic := '0';
    signal clk_en : std_logic;

    component clock_div is
        port (
            clk : in std_logic;
            en  : out std_logic
        );
    end component clock_div;
begin

    shift <= not(lfsr(3) xor lfsr(2));

    lfsr_proc : process(clk)
    begin
        if(rising_edge(clk)) then
            if(clk_en = '1') then
                lfsr <= lfsr(4 downto 0) & shift;
            end if;
        end if;
    end process lfsr_proc;


    process(clk_en) begin
        if(clk_en = '1') then
            randomNum <= lfsr;
        end if;
    end process;


    clock_enable : clock_div port map(
            clk => clk,
            en => clk_en
        );
end randomNumGenerator_arch;
