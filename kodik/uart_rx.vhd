-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author: Katarína Mečiarová (xmeciak00)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


--entity declaration (NOT ALTERED)
entity UART_RX is
    port(
--inputs
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
--outputs
        DOUT     : out std_logic_vector (7 downto 0);
        DOUT_VLD : out std_logic);

end entity;


--implementation of architecture (ALTERED)
architecture behavioral of UART_RX is
--local signals ~ variables
    signal MIDBIT           : std_logic;
    --signal FIN              : std_logic; -- ~ RST
    signal VLDT             : std_logic;
    signal DATA             : std_logic;
    signal CLK_CNT          : std_logic;
    signal IN_THE_MIDDLE    : std_logic;
    signal CNT_CLK_EN       : std_logic_vector (3 downto 0);
    signal CNT_DATA         : std_logic_vector (2 downto 0);
    signal DECODER          : std_logic_vector (7 downto 0);

begin
--countering based on CLK signal, counting till 15 || 7 ~ based on the what counter is meant
    COUNT_CLK : process (CLK)
    begin
        if rising_edge(CLK) then
--if CLK signal is '1' then increment the counter, else reset the counter
            if CLK_CNT = '1' then
                CNT_CLK_EN <= CNT_CLK_EN + 1;
            else
                CNT_CLK_EN <= "0000";
            end if;

        end if;
    end process;

--if the counter is equal to 15, then set the DATA signal to '1', else to '0'
    MIDBIT <= '1' when CNT_CLK_EN = "1111" else '0';
--if the counter is equal to 7, then set the DATA signal to '1', else to '0'
    IN_THE_MIDDLE <= '1' when CNT_CLK_EN = "0111" else '0';

--countering based on DATA signal, counting till 3
    COUNT_DATA : process (CLK)
    begin
        if rising_edge(CLK) then
--if DATA signal is '1' then increment the counter, else reset the counter
            if DATA = '1' then
--if the counter is equal to 3, then reset the counter
                if MIDBIT = '1' then
                    CNT_DATA <= CNT_DATA + 1;
                end if;
--if the counter is not equal to 3, then reset the counter
            else
                CNT_DATA <= "000";
            end if;

        end if;
    end process;

--if the counter is equal to 3, then set the FIN signal to '1', else to '0'
    FIN <= '1' when CNT_DATA = "111" else '0';

--if the counter is equal to 3, then set the VLDT signal to '1', else to '0'
    DECODERit : process (CLK, RST, DIN)
    begin
        if rising_edge(clk) then
--if RST signal is '1', then reset the DECODER signal
            if RST = '1' then
                DECODER <= "00000000";
            else
--if the counter is equal to 3, then set the DECODER signal to the DIN signal
                if (IN_THE_MIDDLE = '1' and data = '1') then
                    case CNT_DATA is
                        when "000" => DECODER(0) <= DIN;
                        when "001" => DECODER(1) <= DIN;
                        when "010" => DECODER(2) <= DIN;
                        when "011" => DECODER(3) <= DIN;
                        when "100" => DECODER(4) <= DIN;
                        when "101" => DECODER(5) <= DIN;
                        when "110" => DECODER(6) <= DIN;
                        when "111" => DECODER(7) <= DIN;
                        when others => NULL;
                    end case;
                end if;

            end if;

        end if;
    end process;

--if the counter is equal to 3, then set the VLDT signal to '1', else to '0'
    DOUT_VLD <= '1' when VLDT = '1' and IN_THE_MIDDLE = '1' else '0';
    DOUT <= DECODER when VLDT = '1' and IN_THE_MIDDLE = '1' else "00000000";

--instantiation of UART_RX_FSM entity
    FSM_OUT: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        MIDBIT => MIDBIT,
        FIN => FIN,
        VLDT => VLDT,
        DATA => DATA,
        CLK_CNT => CLK_CNT);

end architecture;