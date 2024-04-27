library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity cardDeck is
Port (
        clk : in std_logic;
        rst : in std_logic := '0'--input from game board that will tell this entity to reshuffle
        --player1CardsToChange, player2CardstoChange : in std_logic_vector(4 downto 0) := "00000"; -- 10101 means that the first, third, and fifth cards will be replaced
        --player1RequestCards, player2RequestCards : in std_logic --tells this entity when to give new cards
        
        
--        --uart signals
--        uartSend : out std_logic; --both UARTS and both boards can use same send and data can be updated across all boards at the same time
--        txCards1, txCards2, txNums1, txNums2 : out std_logic; --transmits data to respective UARTS and boards
--        uartRST : out std_logic; --just resets UART modules, all of which can be reset on same terminal
--        --player1NumCharSend, player2NumCharSend : out std_logic_vector(7 downto 0);
--        --player1CardCharSend, player2CardCharSend : out std_logic_vector(79 downto 0);
--        uartReady : in std_logic; --all the UARTs can run on the same ready
--        rxCards1, rxCards2, rxNums1, rxNums2 : in std_logic --receive the card data
    );


end cardDeck;

architecture cardDeck_arch of cardDeck is

    type cardsDeck is array (0 to 51) of std_logic_vector(15 downto 0); --a brute force way of storing cards, first 8 bits are rank, next 8 bits are suit
    signal deck : cardsDeck := (x"3243", x"3343", x"3443", x"3543", x"3643", x"3743", x"3843", x"3943", x"5443", x"4A43", x"5143", x"4B43", x"4143",x"3248", x"3348",
                                         x"3448", x"3548", x"3648", x"3748", x"3848", x"3948", x"5448", x"4A48", x"5148", x"4B48", x"4148",x"3253", x"3353", x"3453", x"3553", x"3653", x"3753", x"3853", x"3953",
                                         x"5453", x"4A53", x"5153", x"4B53", x"4153",x"3244", x"3344", x"3444", x"3544", x"3644", x"3744", x"3844", x"3944", x"5444", x"4A44", x"5144", x"4B44", x"4144");
    
    
    type cardHand is array (0 to 4) of std_logic_vector(15 downto 0);
    signal playerHand1 : cardHand; --player 1 hand
    signal playerHand2 : cardHand; --player 2 hand
    signal Player1CardHand, Player2CardHand : std_logic_vector(79 downto 0); --can be used to transmit all card data
    signal cardsDealt : std_logic_vector(5 downto 0) := (others => '0'); --keeps track of cards dealt
    signal cardsDrawn : std_logic_vector(19 downto 0) := (others => '0'); --used to count how many cards signal
    signal cardsExchanged : std_logic_vector(2 downto 0):= "000";
    signal psuedoRanNum : std_logic_vector(5 downto 0);
    signal player1CardstoChange, player2CardsToChange: std_logic_vector(4 downto 0) := "01010";
        signal player1RequestCards, player2RequestCards : std_logic := '1';
    type state is (reset, shuffle, deal1, deal2, player1FirstExchange, wait1, player2FirstExchange, player1SecondExchange, player2SecondExchange, end_state);
    signal presentState : state := reset;

 
    
    
    --used for testing right now

    signal clk_en : std_logic;
    
    component randomNumGenerator is
        Port ( randomNum : out STD_LOGIC_vector(5 downto 0);
             clk : in STD_LOGIC
            );
    end component randomNumGenerator;
    
    component clock_div is
        port (
        clk : in std_logic;
        en : out std_logic
        );
        end component clock_div;
    
    


    
begin

    RanNumGenerator : randomNumGenerator port map(
        clk => clk,
        randomNum => psuedoRanNum
    );
    en_gen : clock_div port map(
        clk => clk,
        en => clk_en
    );
    


    player1CardHand <= playerHand1(0) & playerHand1(1) & playerHand1(2) & playerHand1(3) & playerHand1(4);
    player2CardHand <= playerHand2(0) & playerHand2(1) & playerHand2(2) & playerHand2(3) & playerHand2(4);




    state_proc : process(clk)
    begin
        if rising_edge(clk) then
            if(clk_en = '1') then
                        if rst = '1' then
            presentState <= reset;
            playerHand1 <= (others => (others => '0'));
            playerHand2 <= (others => (others => '0'));
            cardsDealt <= (others => '0');
            cardsDrawn <= (others =>'0');
        end if;
                case presentState is
                    when reset =>
                        if(clk_en = '1') then
                            presentState <= shuffle;
                        end if;


                    when shuffle =>
                        if(unsigned(cardsDrawn) < 1000) then
                                Deck <= Deck(25 to 51) & Deck(0 to 24);
                            if(unsigned(psuedoRanNum) < 51 and unsigned(psuedoRanNum) > 0) then
                                Deck <= Deck(0 to to_integer(unsigned(psuedoRanNum) - 1)) & Deck(to_integer(unsigned(psuedoRanNum)+1) to 51) & Deck(to_integer(unsigned(psuedoRanNum)));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn)+1);

                            else
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn)+1);
                            end if;
                        else
                            Deck <= Deck(37 to 47) & Deck(0 to 36) & Deck(48 to 51);
                            cardsDrawn <= (others => '0');
                            presentState <= deal1;
                        end if;


                    when deal1 =>
                        if(unsigned(cardsDealt)<5) then
                            playerHand1(to_integer(unsigned(cardsDealt))) <= Deck(to_integer(unsigned(cardsDrawn)));
                            cardsDealt <= std_logic_vector(unsigned(cardsDealt) + 1);
                            cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                        else
                            presentState <= deal2;
                            cardsDealt <= (others => '0');
                        end if;    


                    when deal2 =>
                                if(unsigned(cardsDealt)<5) then
                            playerHand2(to_integer(unsigned(cardsDealt))) <= Deck(to_integer(unsigned(cardsDrawn)));
                            cardsDealt <= std_logic_vector(unsigned(cardsDealt) + 1);
                            cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                        else
                            presentState <= wait1;
                            cardsDealt <= (others => '0');
                        end if;


                    when wait1 =>
                        if(player1RequestCards = '1') then
                        presentState <= player1FirstExchange;
                        else
                        presentState <= wait1;
                        end if;
                    when player1FirstExchange =>
                        case player1CardsToChange is
                            when "00000" =>
                                presentState <= player2FirstExchange;
                            when "00001" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                            when "00010" =>
                                presentState <= player2FirstExchange;
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn)));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                            when "00011" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "00100" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                            when "00101" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "00110" =>
                                presentState <= player2FirstExchange;
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "00111" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "01000" =>
                                presentState <= player2FirstExchange;
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn)));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                            when "01001" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "01010" =>
                                presentState <= player2FirstExchange;
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "01011" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "01100" =>
                                presentState <= player2FirstExchange;
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "01101" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "01110" =>
                                presentState <= player2FirstExchange;
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "01111" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 3));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 4);
                            when "10000" =>
                                presentState <= player2FirstExchange;
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                            when "10001" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "10010" =>
                                presentState <= player2FirstExchange;
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "10011" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "10100" =>
                                presentState <= player2FirstExchange;
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "10101" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "10110" =>
                                presentState <= player2FirstExchange;
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "10111" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "11000" =>
                                presentState <= player2FirstExchange;
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "11001" =>
                                presentState <= player2FirstExchange;
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "11010" =>
                                presentState <= player2FirstExchange;
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "11011" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 3));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 4);
                            when "11100" =>
                                presentState <= player2FirstExchange;
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "11101" =>
                                presentState <= player2FirstExchange;
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 3));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 4);
                            when "11110" =>
                                presentState <= player2FirstExchange;
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 3));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 4);
                            when "11111" =>
                                playerHand1(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand1(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand1(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                playerHand1(3) <= deck(to_integer(unsigned(cardsDrawn) + 3));
                                playerHand1(0) <= deck(to_integer(unsigned(cardsDrawn) + 4));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 5);
                            when others =>
                                presentState <= player2FirstExchange;
                            end case;
            when player2FirstExchange =>
                case player2CardsToChange is
                            when "00000" =>
                                presentState <= end_state;
                            when "00001" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                            when "00010" =>
                                presentState <= end_state;
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn)));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                            when "00011" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "00100" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                            when "00101" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "00110" =>
                                presentState <= end_state;
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "00111" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "01000" =>
                                presentState <= end_state;
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn)));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                            when "01001" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "01010" =>
                                presentState <= end_state;
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "01011" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "01100" =>
                                presentState <= end_state;
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "01101" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "01110" =>
                                presentState <= end_state;
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "01111" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "10000" =>
                                presentState <= end_state;
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 1);
                            when "10001" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "10010" =>
                                presentState <= end_state;
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "10011" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "10100" =>
                                presentState <= end_state;
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "10101" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "10110" =>
                                presentState <= end_state;
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "10111" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "11000" =>
                                presentState <= end_state;
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 2);
                            when "11001" =>
                                presentState <= end_state;
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "11010" =>
                                presentState <= end_state;
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "11011" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn) + 3));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 4);
                            when "11100" =>
                                presentState <= end_state;
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 3);
                            when "11101" =>
                                presentState <= end_state;
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn) + 3));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 4);
                            when "11110" =>
                                presentState <= end_state;
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn) + 3));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 4);
                            when "11111" =>
                                playerHand2(4) <= deck(to_integer(unsigned(cardsDrawn)));
                                playerHand2(1) <= deck(to_integer(unsigned(cardsDrawn) + 1));
                                playerHand2(2) <= deck(to_integer(unsigned(cardsDrawn) + 2));
                                playerHand2(3) <= deck(to_integer(unsigned(cardsDrawn) + 3));
                                playerHand2(0) <= deck(to_integer(unsigned(cardsDrawn) + 4));
                                cardsDrawn <= std_logic_vector(unsigned(cardsDrawn) + 5);
                            when others =>
                                presentState <= end_state;
                            end case;
            when end_state =>
            when others =>
                
            end case;
            end if;
            end if;
                end process;

end architecture; 
                    
