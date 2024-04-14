-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Martin Zůbek (x253206)

library ieee;
use ieee.std_logic_1164.all;
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



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)

architecture behavioral of UART_RX is

        --signal CLK : std_logic;
        --signal WORD : std_logic;
        signal BIT_FIN              : std_logic;
        signal ENABLED              : std_logic;
        signal CLK_EN               : std_logic;
        signal BIT                  : std_logic;
        signal VLD                  : std_logic;
        signal COUNTER_SEVEN_OUT    : std_logic_vector(2 downto 0);
        signal COUNTER_FIFTEEN_OUT  : std_logic_vector(3 downto 0);
        signal COUNTER_WORD         : std_logic(2 downto 0);
        signal TICK_COUNT_SEVEN     : std_logic;
        signal TICK_COUNT_FIFTEEN   : std_logic;
        signal MID_BIT              : std_logic;
        signal DECODER_OUT          : std_logic_vector(7 downto 0);
        --signal VLD_OUT : std_logic;
        --signal DATA_OUT : std_logic;
    
    begin
    
        COUNTER_SEVEN : process (CLK)
        begin
            if rising_edge(CLK) then
                if( TICK_COUNT_SEVEN = '1') then
                    COUNTER_SEVEN_OUT <= COUNTER_SEVEN_OUT  + 1;
                else
                    COUNTER_SEVEN_OUT <= "000";
                end if;
            end if;
        end process;

        -- určení mid bitu
        MID_BIT <= '1'  when COUNTER_SEVEN_OUT = "111" else '0';
        
        
        COUNTER_FIFTEEN : process (CLK)
        begin
            if rising_edge(CLK) then
                if(TICK_COUNT_FIFTEEN  = '1') then
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
                if BIT = '1' then
                    if BIT_FIN = '1' then
                        COUNTER_WORD <= COUNTER_WORD  + 1;
                    end if;
                else
                    COUNTER_WORD <= "000";
                end if;
            end if;
        end process;
    
        RST <= '0'  when COUNTER_WORD  = "111" else '0';

        DECODER : process(CLK, DIN, RST)
        begin
            if rising_edge(clk) then
                if RST = '1' then
                    DECODER_OUT  <= "00000000";
                else
                    if (MID_BIT = '1' and BIT = '1') then
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
    
        DOUT_VLD <= '0'  when VLD = '1' and MID_BIT = '1' else '0';
        DOUT <= DECODER_OUT when VLD = '1' and MID_BIT = '1' else "00000000";
    
        -- Instance of RX FSM
        fsm: entity work.UART_RX_FSM
        port map (
            CLK => CLK,
            RST => WORD,
            DIN => DIN,
            BIT_FIN => BIT_FIN,
            ENABLED => ENABLED,
            VLD => VLD,
            BIT => BIT,
            CLK_EN =>CLK_EN
        );

end architecture;
