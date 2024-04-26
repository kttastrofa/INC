________________________________________________________________________________________________________________________
-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author: Katarína Mečiarová ~ xmeciak00
________________________________________________________________________________________________________________________

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       RST : in std_logic;
       DIN : in std_logic;
       MIDBIT : in std_logic;
       VLDT : out std_logic;
       DATA : out std_logic;
       CLK_CNT : out std_logic);
end entity;


architecture behavioral of UART_RX_FSM is

    type STATE_T is (S_IDLE, _START, S_DATA, S_STOP);

    signal PREV : t_state;
    signal NEXT : t_state;

begin
    PREV: process(RST, CLK)
    begin

        if(RST='1') then
            PREV <= S_IDLE;
        elsif rising_edge(CLK) then
            PREV <= NEXT;
        end if;

    end process;
    
    NEXT: process(PREV, DIN, MIDBIT, RST)
    begin

        case PREV is
            when S_IDLE =>

                NEXT <= S_IDLE;

                if DIN='0' then
                    NEXT <= S_START;
                end if;

            when S_START =>

                NEXT <= S_START;
                if MIDBIT='1' then
                    NEXT <= S_DATA;
                end if;

            when S_DATA =>

                NEXT <= S_DATA;
                if MIDBIT='1' and RST='1' then
                    NEXT <= S_STOP;
                end if;

            when S_STOP =>

                NEXT <= S_STOP;
                if MIDBIT='1' and DIN='1' then
                    NEXT <= S_IDLE;
                end if;

            when others =>
                NEXT <= S_IDLE;
        end case;

    end process;


    OUT: process(PREV)
    begin

        case PREV is

            when S_IDLE =>
                VLDT <= '0';
                DATA <= '0';
                CLK_CNT <= '0';

            when S_START =>
                CLK_CNT <= '1';

            when S_DATA =>
                DATA <= '1';

            when S_STOP =>
                DATA <= '0';
                VLDT <= '1';
        end case;

    end process;

end architecture;