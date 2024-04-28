----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/19/2024 09:45:46 PM
-- Design Name: 
-- Module Name: sender - sender_arch
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

entity sender is
    Port ( reset, clk, clk_en, btn, ready : in STD_LOGIC;
         send : out STD_LOGIC;
         char : out STD_LOGIC_VECTOR (7 downto 0));
end sender;

architecture sender_arch of sender is

    -- n-long array that contains NetID in ASCII: my netID is jfg129, so n is 6: assign to NETID bus
    --type str is array (0 to 5) of std_logic_vector(7 downto 0);
    --signal netID : str := (x"4A", x"46", x"47", x"31", x"32", x"39");
    signal netID : std_logic_vector(47 downto 0) := (x"4A4647313239");
    signal transmission : std_logic := '0';
    signal btnPressed : std_logic := '0';
    --initialize counter
    signal i : std_logic_vector(2 downto 0) := (others => '0'); -- will count up to 7, more than the 6 I need for my netID
    --intialize states
    type state is (idle, busyA, busyB, busyC, paused);
    signal PS : state := idle;
    



begin

    process(clk) begin
    if(rising_edge(clk)) then
        if(btn = '0') then
        transmission <= '0';
        end if;
        end if;
    end process;
    
    state_machine_proc : process(clk)
    begin
        if rising_edge(clk) and clk_en = '1' then --all actions occur on rising clock edge and clock enable high

            if reset = '1' then --reset is asserted
                send <= '0';
                char <= (others => '0');
                i <= "000";
                PS <= paused;
            else

                case PS is
                    when paused => 
                    if (btn = '1') then
                        ps <= idle;
                        else
                        ps <= paused;
                    end if;
                    when idle =>
                        if ready = '1' and unsigned(i)< 6  then
                            send <= '1';
                            --char <= netID((47 - (7 * unsigned(i))) downto (41 - (7 * unsigned(i)))); 
                            char <= netID ((47 - 8 * to_integer(unsigned(i))) downto (40 - 8 * to_integer(unsigned(i))));
                            i <= std_logic_vector(unsigned(i) + 1);
                            PS <= busyA;
                        elsif ready = '1' and btn = '1' and unsigned(i)=6  then
                            i <= (others => '0');
                            PS <= idle;
                        end if;
                    when busyA =>
                        PS <= busyB;

                    when busyB =>
                        send <= '0';
                        PS <= busyC;

                    when busyC =>
                        if ready = '1' and unsigned(i) < 6 then
                            PS <= idle;
                        elsif ready = '1' and btn = '0' and unsigned(i) =6 then
                            PS <= paused;
                        else
                            PS <= busyC;
                        end if;
                end case;
            end if;
        end if;
    end process state_machine_proc;



end sender_arch;