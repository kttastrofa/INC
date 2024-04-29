-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author: Katarína Mečiarová (xmeciak00)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity UART_RX_FSM is
    port(
--inputs default
       CLK      : in std_logic;
       RST      : in std_logic;
--inputs
       DIN      : in std_logic;
       MIDBIT   : in std_logic;
       FIN      : in std_logic; --as RST in scheme
--OUTPUTs
       VLDT     : out std_logic;
       DATA     : out std_logic;
       CLK_CNT  : out std_logic

end entity;


architecture behavioral of UART_RX_FSM is
--local variables
    signal  OUTPUT : std_logic_vector (2 downto 0);
    type    STATE_T is(S_IDLE, S_START, S_DATA, S_STOP);
    signal  ACT : STATE_T;
--start the process (fsm resolving)
begin

    

--resolve the states
    ACTit: process
    begin

        case OUTPUT is
            when "000" =>

                ACT <= S_IDLE;
                if DIN = '0' then
                    OUTPUT <= "001";
                end if;

            when "001" =>

                ACT <= S_START;
                if MIDBIT = '1' then
                    OUTPUT <= "001";
                end if;

            when "011" =>

                ACT <= S_DATA;
                if MIDBIT = '1' and FIN = '1' then
                    OUTPUT <= "001";
                end if;

            when "101" =>

                ACT <= S_STOP;
                if MIDBIT = '1' and DIN = '1' then
                    OUTPUT <= "001";
                end if;
--default
            when others =>
                ACT <= S_IDLE;
        end case;

    end process;

--put the OUTPUTs to the right holes :)
    OUTit: process
    begin
                                                --SPAWN NA CHYBY
        VLDT <= OUTPUT(0);
        DATA <= OUTPUT(1);
        CLK_CNT <= OUTPUT(2);

    end process;

end architecture;