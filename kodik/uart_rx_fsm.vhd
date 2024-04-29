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
       CLK_CNT  : out std_logic);

end entity;


architecture behavioral of UART_RX_FSM is
--local variables
    type STATE_T is (S_IDLE, S_START, S_DATA, S_STOP);
    signal PRE : STATE_T;
    signal NEX : STATE_T;
--start the process (fsm resolving)
begin
--resolve the states based on previous and next states
    process(RST, CLK, PRE, DIN, MIDBIT, FIN)
    begin
        if RST='1' then
            PRE <= S_IDLE;
        elsif rising_edge(CLK) then
            PRE <= NEX;
        end if;
--changing states    
        case PRE is
            when S_IDLE =>
                NEX <= S_IDLE;
                if DIN='0' then
                    NEX <= S_START;
                end if;
            when S_START =>
                NEX <= S_START;
                if MIDBIT='1' then
                    NEX <= S_DATA;
                end if;
            when S_DATA =>
                NEX <= S_DATA;
                if MIDBIT='1' and FIN='1' then
                    NEX <= S_STOP;
                end if;
            when S_STOP =>
                NEX <= S_STOP;
                if MIDBIT='1' and DIN='1' then
                    NEX <= S_IDLE;
                end if;
            when others => 
                NEX <= S_IDLE;
        end case;
--setting values
        case PRE is
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