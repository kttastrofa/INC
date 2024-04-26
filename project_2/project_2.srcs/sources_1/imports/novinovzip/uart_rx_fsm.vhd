-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Ondřej Novotný (xnovot2p)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       RST : in std_logic;
       DIN : in std_logic;
       BIT_FIN : in std_logic;
       WORD_FIN : in std_logic;
       VALIDITY : out std_logic;
       DATA : out std_logic;
       CLK_COUNT : out std_logic 
    );
end entity;

architecture behavioral of UART_RX_FSM is
    type t_state is (S_idle, S_start, S_data, S_stop);
    signal pstate : t_state;
    signal nstate : t_state;

begin

    pstateRegister: process(RST, CLK)
    begin
        if(RST='1') then
            pstate <= S_idle;
        elsif rising_edge(CLK) then
            pstate <= nstate;
        end if;
    end process;
    
    nstate_logic: process(pstate, DIN, BIT_FIN, WORD_FIN)
    begin
        case pstate is
            when S_idle =>
                nstate <= S_idle;
                if(DIN='0') then
                    nstate <= S_start;
                end if;
            when S_start =>
                nstate <= S_start;
                if(BIT_FIN='1') then
                    nstate <= S_data;
                end if;
            when S_data =>
                nstate <= S_data;
                if(BIT_FIN='1' and WORD_FIN='1') then
                    nstate <= S_stop;
                end if;
            when S_stop =>
                nstate <= S_stop;
                if(BIT_FIN='1' and DIN='1') then
                    nstate <= S_idle;
                end if;
            when others => 
                nstate <= S_idle;
        end case;
    end process;

    output_logic: process(pstate)
    begin
        case pstate is
            when S_idle =>
                VALIDITY <= '0';
                DATA <= '0';
                CLK_COUNT <= '0';
            when S_start =>
                CLK_COUNT <= '1';
            when S_data =>
                DATA <= '1';
            when S_stop =>
                DATA <= '0';
                VALIDITY <= '1';
            end case;
    end process;
end architecture;
