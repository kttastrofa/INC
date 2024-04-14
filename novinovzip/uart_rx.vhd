-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Ondřej Novotný (xnovot2p)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



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

    signal bit_finish : std_logic;
    signal word_finish : std_logic;
    signal validity : std_logic;
    signal data : std_logic;
    signal clock_count : std_logic;
    signal clk_counter_out : std_logic_vector(3 downto 0);
    signal mid_bit : std_logic;
    signal data_counter_out : std_logic_vector(2 downto 0);
    signal decoder_out : std_logic_vector(7 downto 0);

begin

    clk_counter : process (CLK)
    begin
        if rising_edge(CLK) then
            if(clock_count = '1') then
                clk_counter_out <= clk_counter_out + 1;
            else
                clk_counter_out <= "0000";
            end if;
        end if;
    end process;
    -- Compare 
    bit_finish <= '1' when clk_counter_out = "1111" else '0';

    -- určení mid bitu
    mid_bit <= '1' when clk_counter_out = "0111" else '0';

    data_counter : process(CLK)
    begin
        if rising_edge(CLK) then
            if data = '1' then
                if bit_finish = '1' then
                    data_counter_out <= data_counter_out + 1;
                end if;
            else
                data_counter_out <= "000";
            end if;
        end if;
    end process;

    word_finish <= '1' when data_counter_out = "111" else '0';

    decoder : process(CLK, RST, DIN)
    begin
        if rising_edge(clk) then
            if RST = '1' then
                decoder_out <= "00000000";
            else
                if (mid_bit = '1' and data = '1') then
                    case data_counter_out is
                        when "000" => decoder_out(0) <= DIN;
                        when "001" => decoder_out(1) <= DIN;
                        when "010" => decoder_out(2) <= DIN;
                        when "011" => decoder_out(3) <= DIN;
                        when "100" => decoder_out(4) <= DIN;
                        when "101" => decoder_out(5) <= DIN;
                        when "110" => decoder_out(6) <= DIN;
                        when "111" => decoder_out(7) <= DIN;
                        when others => NULL;
                    end case;
                end if;
            end if;
        end if;
    end process;

    DOUT_VLD <= '1' when validity = '1' and mid_bit = '1' else '0';
    DOUT <= decoder_out when validity = '1' and mid_bit = '1' else "00000000";

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        BIT_FIN => bit_finish,
        WORD_FIN => word_finish,
        VALIDITY => validity,
        DATA => data,
        CLK_COUNT => clock_count
    );

end architecture;
