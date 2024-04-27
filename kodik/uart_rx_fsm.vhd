________________________________________________________________________________________________________________________
-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author: Katarína Mečiarová ~ xmeciak00
________________________________________________________________________________________________________________________

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       FIN : in std_logic; --as RST in draft
       DIN : in std_logic;
       MIDBIT : in std_logic;
       VLDT : out std_logic;
       DATA : out std_logic;
       CLK_CNT : out std_logic);
end entity;


architecture behavioral of UART_RX_FSM is

    signal OUT : std_logic_vector (2 downto 0);
    type STATE_T is (S_IDLE, _START, S_DATA, S_STOP);
    signal ACT : t_state;

begin
    OUT: process(OUT, VLDT, DATA, CLK_CNT)
    begin

        OUT[0] =: VLDT;
        OUT[1] =: DATA;
        OUT[2] =: CLK_CNT;

    end process;


    ACT: process(ACT, DIN, MIDBIT, FIN, OUT)
    begin

        case OUT is
            when '000' =>

                ACT =: S_IDLE;
                if DIN = '0' then
                    OUT <= '001';
                end if;

            when '001' =>

                ACT =: S_START;
                if MIDBIT = '1' then
                    OUT <= '001';
                end if;

            when '011' =>

                ACT =: S_DATA;
                if MIDBIT = '1' and FIN = '1' then
                    OUT <= '001';
                end if;

            when '101' =>

                ACT =: S_STOP;
                if MIDBIT = '1' and DIN = '1' then
                    OUT <= '001';
                end if;

            when others =>
                ACT <= S_IDLE;
        end case;

    end process;


    OUTPUT: process(ACT, OUT)
    begin
--SPAWN NA CHYBY
        VLDT <= OUT[0];
        DATA <= OUT[1];
        CLK_CNT <= OUT[2];

    end process;

end architecture;