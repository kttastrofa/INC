-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Martin Zůbek (x253206)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
        --INPUTS
        CLK : in std_logic;
        DIN : in std_logic;
        WORD : in std_logic;
        BIT_FIN : in std_logic;
        ENABLED : in std_logic;
        --OUTPUTS
        CLK_EN : inout std_logic;
        DATA_BIT : inout std_logic;
        VLD : inout std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is

    type STATE is (S_IDLE, S_BEGIN, S_DATA, S_WAIT ,S_STOP);
    signal NEXT_STATE : STATE;
begin

    process (CLK, DIN, WORD, BIT_FIN, ENABLED, CLK_EN, DATA_BIT, VLD) is
    
    begin

        --CLK_EN
        CLK_EN <= not(DIN);

        if CLK_EN = '1'  then
            NEXT_STATE <= S_IDLE;
        end if;


        case NEXT_STATE is

            --S_IDLE
            when S_IDLE =>
                
                DATA_BIT <= '0';
                VLD <= '0';

                --S_IDLE -> S_BEGIN
                if DIN = '0' then

                    NEXT_STATE <= S_BEGIN;

                end if;


            --S_BEGIN
            when S_BEGIN =>

                --S_BEGIN -> S_DATA
                if BIT_FIN = '1' then

                    NEXT_STATE  <= S_DATA;
                    DATA_BIT <= '1';

                end if;


            --S_DATA
            when S_DATA =>

                --S_DATA -> S_WAIT
                if BIT_FIN = '1' then

                    NEXT_STATE <= S_WAIT;
                    DATA_BIT <= '0';

                end if;


            --S_WAIT
            when S_WAIT =>
            
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
                
                --S_STOP -> S_IDLE
                if BIT_FIN = '1'and DIN = '1' then

                    NEXT_STATE <= S_IDLE;
                    VLD <= '0';
                    CLK_EN <= '0';

                end if;

        end case;
        
    end process;
end architecture;
