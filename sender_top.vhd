----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/20/2024 12:00:47 AM
-- Design Name: 
-- Module Name: sender_top - sender_top_arch
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

entity sender_top is
    Port ( TXD : in STD_LOGIC;
         btn : in STD_LOGIC_VECTOR (1 downto 0);
         clk : in STD_LOGIC;
         RXD : out STD_LOGIC;
         CTS : out STD_LOGIC := '0';
         RTS : out STD_LOGIC := '0');
end sender_top;

architecture sender_top_arch of sender_top is

    signal btn0Debounced : std_logic;
    signal btn1Debounced: std_logic;
    signal clk_en : std_logic;
    signal ready : std_logic;
    signal send : std_logic;
    signal char : std_logic_vector(7 downto 0);


    component clock_div port (
            clk : in std_logic;
            en  : out std_logic
        );
    end component;

    component debouncer  port (
            in0 : in STD_LOGIC;
            out0 : out STD_LOGIC := '0';
            clk : in STD_LOGIC
        );
    end component;

    component sender port (
            reset, clk, clk_en, btn, ready : in STD_LOGIC;
            send : out STD_LOGIC;
            char : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    component uart port (
            clk, en, send, rx, rst      : in std_logic;
            charSend                    : in std_logic_vector (7 downto 0);
            ready, tx, newChar          : out std_logic;
            charRec                     : out std_logic_vector (7 downto 0)
        );
    end component;
begin

    u1 : debouncer port map( --button 0
            in0 => btn(0),
            out0 => btn0Debounced,
            clk => clk
        );

    u2 : debouncer port map( --button 1
            in0 => btn(1),
            out0 => btn1Debounced,
            clk => clk
        );

    u3 : clock_div port map(
            clk => clk,
            en => clk_en
        );
    u4 : sender port map(
        reset => btn0Debounced,
        clk => clk,
        clk_en => clk_en,
        btn => btn1Debounced,
        ready => ready,
        send => send,
        char => char
    );
    
    u5 : uart port map( --newChar, charRec are not needed for the port map
        clk => clk,
        en => clk_en,
        send => send,
        rx => TXD,
        rst => btn0Debounced,
        charSend => char,
        ready => ready,
        tx => RXD
    );
end sender_top_arch;