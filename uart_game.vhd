--
-- written by Gregory Leonberg
-- fall 2017
--
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity uart_game is
    port (

    clk, en, send, rx, rst      : in std_logic;
    charSend                    : in std_logic_vector (87 downto 0);
    ready, tx, newChar          : out std_logic;
    charRec                     : out std_logic_vector (4 downto 0)

);
end uart_game;

architecture structural of uart_game is
    component uart_tx_game port
    (
        clk, en, send, rst  : in std_logic;
        char                : in std_logic_vector (87 downto 0);
        ready, tx           : out std_logic
    );
    end component;

    component uart_rx_game port
    (
        clk, en, rx, rst    : in std_logic;
        newChar             : out std_logic;
        char                : out std_logic_vector (4 downto 0)
    );
    end component;

begin

    r_x: uart_rx_game port map(
        clk => clk,
        en => en,
        rx => rx,
        rst => rst,
        newChar => newChar,
        char => charRec);

    t_x: uart_tx_game port map(
        clk => clk,
        en => en,
        send => send,
        rst => rst,
        char => charSend,
        ready => ready,
        tx => tx);

end structural;