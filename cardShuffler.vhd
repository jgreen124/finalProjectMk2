library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Deck_Shuffler is
    generic(
        DECK_SIZE : integer := 52
    );
    port(
        clk : in std_logic;
        reset : in std_logic;
        shuffle_trigger : in std_logic;
        deck_out : out std_logic_vector(5 downto 0) -- assuming 6 bits to represent card index
    );
end Deck_Shuffler;

architecture Behavioral of Deck_Shuffler is
    type card_array is array (0 to DECK_SIZE-1) of integer range 0 to DECK_SIZE-1;
    signal deck : card_array := (others => 0);
    signal shuffle_done : std_logic := '0';
    signal index : integer range 0 to DECK_SIZE-1;

    -- Linear Feedback Shift Register (LFSR) for pseudo-random number generation
    signal lfsr : std_logic_vector(31 downto 0) := (others => '0');
    signal lfsr_out : std_logic_vector(5 downto 0);

    -- Counter for deck shuffling
    signal shuffle_counter : integer range 0 to DECK_SIZE-1 := DECK_SIZE-1;
begin
    -- LFSR process for pseudo-random number generation
    lfsr_process : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                lfsr <= (others => '0');
            else
                lfsr(0) <= lfsr(0) xor (lfsr(1) xor lfsr(2) xor lfsr(3) xor lfsr(4));
                lfsr <= '0' & lfsr(lfsr'high downto 1);
            end if;
        end if;
    end process;

    -- Shuffle process
    shuffle_process : process(clk, reset)
    begin
        if reset = '1' then
            deck <= (others => 0);
            shuffle_done <= '0';
            index <= 0;
            shuffle_counter <= DECK_SIZE-1;
        elsif rising_edge(clk) then
            if shuffle_trigger = '1' then
                if shuffle_counter > 0 then
                    -- Swap current card with a random card from the unshuffled portion of the deck
                    index <= to_integer(unsigned(lfsr_out)) mod shuffle_counter;
                    deck(index) <= shuffle_counter;
                    deck(shuffle_counter) <= deck(shuffle_counter-1);
                    deck(shuffle_counter-1) <= 0;
                    shuffle_counter <= shuffle_counter - 1;
                else
                    shuffle_done <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Output the shuffled deck
    deck_out <= std_logic_vector(to_unsigned(deck(index), deck_out'length));

    -- Output the LFSR value for debug
    lfsr_out <= lfsr(lfsr'high downto lfsr'high-5);
end Behavioral;
