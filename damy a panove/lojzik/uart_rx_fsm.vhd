-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
        --INPUTS
        CLK         : in std_logic;
        DIN         : in std_logic;
        WORD        : in std_logic;
        BIT_FIN     : in std_logic;
        ENABLED     : in std_logic;
        --OUTPUTS
        CLK_EN      : out std_logic;
        DATA_BIT    : out std_logic;
        VLD         : out std_logic;
        DATA_OUT    : out std_logic
       
    );
end entity;



architecture behavioral of UART_RX_FSM is

    --SIGNAL CLK, WORD, BIT_FIN, ENABLED, CLK_EN, DATA_BIT, VLD : STD_LOGIC; ASI SMAZAT!!!!!!!
    type STATE is (S_IDLE, S_BEGIN, S_DATA, S_WAIT ,S_STOP);
    signal NEXT_STATE : STATE;
    begin

        process (CLK, DIN, WORD, BIT_FIN, ENABLED) is
        
        begin

            --CLK_EN
            


            case NEXT_STATE is

                --S_IDLE
                when S_IDLE =>
                    
                    NEXT_STATE <= S_IDLE;
                    DATA_BIT <= '0';
                    VLD <= '0';
                    CLK_EN <= '0';

                    --S_IDLE -> S_BEGIN
                    if DIN = '0' then

                        NEXT_STATE <= S_BEGIN;
                        CLK_EN <= '1';

                    end if;


                --S_BEGIN
                when S_BEGIN =>
                    
                    NEXT_STATE <= S_BEGIN;
                    --S_BEGIN -> S_DATA
                    if BIT_FIN = '1' then

                        NEXT_STATE  <= S_DATA;
                        DATA_BIT <= '1';

                    end if;


                --S_DATA
                when S_DATA =>
                        
                    NEXT_STATE  <= S_DATA;
                    --S_DATA -> S_WAIT
                    if BIT_FIN = '1' then

                        NEXT_STATE <= S_WAIT;
                        DATA_BIT <= '0';

                    end if;


                --S_WAIT
                when S_WAIT =>
                        
                    NEXT_STATE <= S_WAIT;
                    --S_WAIT -> S_STOP
                    if BIT_FIN = '1' and WORD = '1' then

                        NEXT_STATE <= S_STOP;
                        VLD <= '1';

                    end if;

                    --S_WAIT -> S_DATA
                    if BIT_FIN = '1' then
                        
                        NEXT_STATE <= S_DATA; 
                        DATA_BIT <= '1';
                        
                    end if;
                

                --S_STOP
                when S_STOP =>
                    NEXT_STATE <= S_STOP;
                    --S_STOP -> S_IDLE
                    if BIT_FIN = '1'and DIN = '1' then

                        NEXT_STATE <= S_IDLE;
                        VLD <= '0';
                        CLK_EN <= '0';

                    end if;

            end case;
            
        end process;
    end architecture;

--TODO insert output DATA, *and* it with CNT3