-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Róbert Gonda (xgondar00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       RST : in std_logic;
       DIN : in std_logic;
       CLK_CNT: in std_logic_vector(4 downto 0);
       DATA_CNT: in std_logic_vector(3 downto 0);
       CLK_CNT_EN : out std_logic;
       DATA_READ_EN : out std_logic;
       DATA_VLD : out std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is
    type states is (WAIT_START_BIT, WAIT_MIDBIT, READ_DATA, WAIT_STOP_BIT, VALID);
    signal state : states := WAIT_START_BIT; --TODO inicializuj az po deklaracii
begin
    CLK_CNT_EN <= '1' when state = WAIT_MIDBIT or state = READ_DATA or state = WAIT_STOP_BIT else '0';
    DATA_READ_EN <= '1' when state = READ_DATA else '0';
    DATA_VLD <= '1' when state = VALID else '0';

    process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                state <= WAIT_START_BIT;
            else
                case state is
                    when WAIT_START_BIT => 
                        if (DIN = '0') then
                            state <= WAIT_MIDBIT;
                        end if;
                    when WAIT_MIDBIT => 
                        if (CLK_CNT = "10111") then
                            state <= READ_DATA;
                        end if;
                    when READ_DATA => 
                        if (DATA_CNT = "1000") then
                            state <= WAIT_STOP_BIT;
                        end if;
                    when WAIT_STOP_BIT => 
                        if (DIN = '1' and CLK_CNT = "10000") then
                            state <= VALID;
                        end if;
                    when VALID => 
                        state <= WAIT_START_BIT;
                    when others => null;
                end case;
            end if;
        end if;
    end process;
end architecture;
--TODO nestiham cele cekovat, cize neviem zarucit cistotu. seems ok tho (dalo by sa zjednodusit)