----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2024 08:53:49 PM
-- Design Name: 
-- Module Name: playerBoard - Behavioral
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

entity playerBoard is
  Port (
    clk : in std_logic;
    RXD : out std_logic;
    TXD : in std_logic;
    CS, SDIN, SCLK, DC, RES, VBAT, VDD : out std_logic
   );
end playerBoard;

architecture Behavioral of playerBoard is

signal clk_en : std_logic;
signal send : std_logic;
signal ready : std_logic;
signal uartReset : std_logic;
signal charSend : std_logic_vector(7 downto 0);
signal charRecInter : std_logic_vector(7 downto 0);
signal newChar : std_logic;

signal oledReset : std_logic;

component uart is
    port (

    clk, en, send, rx, rst      : in std_logic;
    charSend                    : in std_logic_vector (7 downto 0);
    ready, tx, newChar          : out std_logic;
    charRec                     : out std_logic_vector (7 downto 0)
);
end component uart;

component clock_div is
port (
    clk : in std_logic;
    en : out std_logic
);
end component clock_div;

component PmodOLEDCtrl is
	Port ( 
		CLK 	: in  STD_LOGIC;
		RST 	: in  STD_LOGIC;
		uartDataIn : in std_logic_vector(7 downto 0);
		--newCardOut : out std_logic_vector(87 downto 0);
		CS  	: out STD_LOGIC;
		SDIN	: out STD_LOGIC;
		SCLK	: out STD_LOGIC;
		DC		: out STD_LOGIC;
		RES	: out STD_LOGIC;
		VBAT	: out STD_LOGIC;
		VDD	: out STD_LOGIC);
end component PmodOLEDCtrl;
begin

OLED : PmodOLEDCtrl port map(
    clk => clk,
    rst => oledReset,
    uartDataIn => charRecInter,
    CS => CS,
    SDIN => SDIN,
    SCLK => SCLK,
    DC => DC,
    Res => RES,
    VBAT => VBAT,
    VDD => VDD
);

uartComms : uart port map(
    clk => clk,
    en => clk_en,
    send => send,
    rx => TXD,
    rst => uartReset,
    charSend => charSend,
    ready => ready,
    tx => RXD,
    newChar => newChar,
    charRec => charRecInter
);

clock_divider : clock_div port map(
    clk => clk,
    en => clk_en
);
end Behavioral;
