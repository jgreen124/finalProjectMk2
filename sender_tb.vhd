----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/19/2024 11:12:27 PM
-- Design Name: 
-- Module Name: sender_tb - sender_tb_arch
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

entity sender_tb is
    --  Port ( );
end sender_tb;

architecture sender_tb_arch of sender_tb is


    component sender port (
            reset, clk, clk_en, btn, ready : in STD_LOGIC;
            send : out STD_LOGIC;
            char : out STD_LOGIC_VECTOR (4 downto 0)
        );
    end component;

    signal rst : std_logic := '0';
    signal clk, clk_en, btn : std_logic := '0';
    signal ready : std_logic := '0';
    signal char : std_logic_vector(4 downto 0) := (others => '0');
    signal send : std_logic;
begin

    dut : sender port map(
            reset => rst,
            clk => clk,
            clk_en => clk_en,
            btn => btn,
            ready => ready,
            send => send,
            char => char

        );


    -- clock process @125 MHz
    process begin
        clk <= '0';
        wait for 4 ns;
        clk <= '1';
        wait for 4 ns;
    end process;

    -- en process @ 125 MHz / 1085 = ~115200 Hz
    process begin
        clk_en <= '0';
        wait for 8 ns;
        clk_en <= '1';
        wait for 8 ns;
    end process;
    
    -- ready process
    process begin
        ready <= '0';
        wait for 16 ns;
        ready <= '1';
        wait for 16 ns;
    end process;
    
    --button process
    process begin
        btn <='1';
        wait for 24 ns;
        btn <= '0';
        wait for 24 ns;
    end process;
    
    -- reset process
    process begin

        rst <= '1';
        wait for 1000 ns;
        rst <= '0';
        wait for 1000 ns;
    end process;

end sender_tb_arch;
