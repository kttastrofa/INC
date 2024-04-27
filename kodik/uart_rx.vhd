________________________________________________________________________________________________________________________
-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author: Katarína Mečiarová ~ xmeciak00
________________________________________________________________________________________________________________________

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


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

    signal MIDBIT : std_logic;
    signal FIN : std_logic; -- ~ RST
    signal VLDT : std_logic;
    signal DATA : std_logic;
    signal CLK_CNT : std_logic;
    signal CNT_CLK_EN : std_logic_vector(3 downto 0);
    signal IN_THE_MIDDLE : std_logic;
    signal CNT_DATA : std_logic_vector(2 downto 0);
    signal DECODER : std_logic_vector(7 downto 0);

begin

    CNT_CLK_EN : process (CLK)
    begin
        if rising_edge(CLK) then
            if CLK_CNT = '1' then
                CNT_CLK_EN <= CNT_CLK_EN + 1;
            else
                CNT_CLK_EN <= "0000";
            end if;
        end if;
    end process;
    -- Compare 
    MIDBIT <= '1' when CNT_CLK_EN = "1111" else '0';

    -- určení mid bitu
    IN_THE_MIDDLE <= '1' when CNT_CLK_EN = "0111" else '0';

    CNT_DATA : process (CLK)
    begin
        if rising_edge(CLK) then
            if DATA = '1' then
                if MIDBIT = '1' then
                    CNT_DATA <= CNT_DATA + 1;
                end if;
            else
                CNT_DATA <= "000";
            end if;
        end if;
    end process;

    FIN <= '1' when CNT_DATA = "111" else '0';

    DECODER : process (CLK, RST, DIN)
    begin
        if rising_edge(clk) then
            if RST = '1' then
                DECODER <= "00000000";
            else
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

    DOUT_VLD <= '1' when VLDT = '1' and IN_THE_MIDDLE = '1' else '0';
    DOUT <= DECODER when VLDT = '1' and IN_THE_MIDDLE = '1' else "00000000";

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        MIDBIT => MIDBIT,
        FIN => FIN,
        VLDT => VLDT,
        DATA => DATA,
        CLK_CNT => CLK_CNT
    );

end architecture;
