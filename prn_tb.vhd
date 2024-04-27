library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.ALL;
    
entity prn_tb is
end entity;

architecture test of prn_tb is

signal randomNum : std_logic_vector(5 downto 0);
signal clk : std_logic := '0'; 
signal outputCard : std_logic_vector(15 downto 0);
signal player1RequestCards, player2RequestCards : std_logic := '1';

  component randomNumGenerator is
    port (
                             
      clk       : in  std_logic;               
      randomNum      : out std_logic_vector(5 downto 0)   
    );
  end component;
  
  component cardDeck is
    Port (
        clk : in std_logic
        --rst : in std_logic; --input from game board that will tell this entity to reshuffle
        --requestCard : in std_logic;
        --outputCard : out std_logic_vector(15 downto 0) --transmits card data
        --player1RequestCards, player2RequestCards : in std_logic
    );


end component cardDeck;
    

begin

 clock_gen : process begin
    clk <= '1';
    wait for 4 ns;
    clk <= '0';
    wait for 4 ns;
 end process;

 dut : randomNumGenerator 
 port map (
   clk      => clk,
   randomNum => randomNum
 );
 
 dut2 : cardDeck port map(
    clk => clk
   -- outputCard => outputCard
   --player1RequestCards => player1RequestCards,
   --player2RequestCards => player2RequestCards 
 );

end architecture;