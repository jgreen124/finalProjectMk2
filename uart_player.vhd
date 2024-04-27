----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2024 05:25:32 PM
-- Design Name: 
-- Module Name: uart_player - Behavioral
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

--
-- written by Gregory Leonberg
-- fall 2017
--
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity uart_player is
    port (

    clk, en, send, rx, rst      : in std_logic;
    charSend                    : in std_logic_vector (4 downto 0);
    ready, tx, newChar          : out std_logic;
    charRec                     : out std_logic_vector (87 downto 0)

);
end uart_player;

architecture structural of uart_player is
    component uart_tx_player port
    (
        clk, en, send, rst  : in std_logic;
        char                : in std_logic_vector (4 downto 0);
        ready, tx           : out std_logic
    );
    end component;

    component uart_rx_player port
    (
        clk, en, rx, rst    : in std_logic;
        newChar             : out std_logic;
        char                : out std_logic_vector (87 downto 0)
    );
    end component;

begin

    r_x: uart_rx_player port map(
        clk => clk,
        en => en,
        rx => rx,
        rst => rst,
        newChar => newChar,
        char => charRec);

    t_x: uart_tx_player port map(
        clk => clk,
        en => en,
        send => send,
        rst => rst,
        char => charSend,
        ready => ready,
        tx => tx);

end structural;
