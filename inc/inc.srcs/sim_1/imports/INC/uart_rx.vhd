-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Martin Zůbek (x253206)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;
        --ENABLED
        --BIT_FIN



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)

architecture behavioral of UART_RX is

        --INPUTS
        signal BIT_FIN              : std_logic;
        signal ENABLED              : std_logic;
        --OUTPUTS
        signal CLK_EN               : std_logic;
        signal DATA_BIT             : std_logic;
        signal VLD                  : std_logic;
        --COUNTERS
        signal COUNTER_SEVEN_OUT    : std_logic_vector(2 downto 0);
        signal COUNTER_FIFTEEN_OUT  : std_logic_vector(3 downto 0);
        signal COUNTER_WORD         : std_logic_vector(2 downto 0);
        --TO COMPARE
        signal TICK_COUNT_SEVEN     : std_logic;
        signal TICK_COUNT_FIFTEEN   : std_logic;
        --TEMPORARY VARIABLES
        signal MID_BIT              : std_logic;
        signal DECODER_OUT          : std_logic_vector(7 downto 0);
    
    begin
    
        COUNTER_SEVEN : process (CLK)
        begin
            if rising_edge(CLK) then
                if TICK_COUNT_SEVEN = '1' then
                    COUNTER_SEVEN_OUT <= COUNTER_SEVEN_OUT  + 1;
                else
                    COUNTER_SEVEN_OUT <= "000";
                end if;
            end if;
        end process;

        -- určení mid bitu a kontrola
        MID_BIT <= '1'  when COUNTER_SEVEN_OUT = "111" else '0';
        ENABLED <= '1'  when COUNTER_SEVEN_OUT = "111" and DATA_BIT = '1' else '0';
        
        
        COUNTER_FIFTEEN : process (CLK)
        begin
            if rising_edge(CLK) then
                if TICK_COUNT_FIFTEEN  = '1' then
                    COUNTER_FIFTEEN_OUT <= COUNTER_FIFTEEN_OUT  + 1;
                else
                    COUNTER_FIFTEEN_OUT <= "0000";
                end if;
            end if;
        end process;

        -- Compare 
        BIT_FIN <= '1'  when COUNTER_FIFTEEN_OUT  = "1111" else '0';
    
        
    
        COUNTER_W  : process(CLK)
        begin
            if rising_edge(CLK) then
                if BIT_FIN = '1' then
                    COUNTER_WORD <= COUNTER_WORD  + 1;
                end if;
            end if;
        end process;
    
        --RST <= '1'  when COUNTER_WORD  = "111" else '0'; --RST nastavujeme na 1, slovo konci

        DECODER : process(CLK, DIN, RST)
        begin
            if rising_edge(CLK) then
                if RST = '1' then
                    DECODER_OUT  <= "00000000";
                else
                    if MID_BIT = '1' and DATA_BIT = '1' then
                        case COUNTER_WORD is
                            when "000" => DECODER_OUT (0) <= DIN;
                            when "001" => DECODER_OUT (1) <= DIN;
                            when "010" => DECODER_OUT (2) <= DIN;
                            when "011" => DECODER_OUT (3) <= DIN;
                            when "100" => DECODER_OUT (4) <= DIN;
                            when "101" => DECODER_OUT (5) <= DIN;
                            when "110" => DECODER_OUT (6) <= DIN;
                            when "111" => DECODER_OUT (7) <= DIN;
                            when others => NULL;
                        end case;
                    end if;
                end if;
            end if;
        end process;
    
        DOUT_VLD <= '1'  when VLD = '1' and MID_BIT = '1' and DATA_BIT = '1' else '0';
        DOUT <= DECODER_OUT when MID_BIT = '1' and DATA_BIT = '1' else "00000000";
    
        -- Instance of RX FSM
        fsm: entity work.UART_RX_FSM
        port map (
            --INPUTS
            CLK => CLK,
            DIN => DIN,
            RST => WORD,
            BIT_FIN => BIT_FIN,
            ENABLED => ENABLED,
            --OUTPUTS
            CLK_EN => CLK_EN,
            DATA_BIT => DATA_BIT,
            VLD => VLD

        );

end architecture;
