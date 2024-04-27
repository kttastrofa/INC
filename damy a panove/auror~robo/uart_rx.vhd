-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Róbert Gonda (xgondar00)

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
    signal clk_cnt_en : std_logic;
    signal data_read_en : std_logic;
    signal data_vld : std_logic;
    signal clk_cnt : std_logic_vector(4 downto 0);
    signal data_cnt : std_logic_vector(3 downto 0);

begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,

        CLK_CNT => clk_cnt,
        DATA_CNT => data_cnt,

        CLK_CNT_EN => clk_cnt_en,
        DATA_READ_EN => data_read_en,
        DATA_VLD => data_vld
    );

    process(CLK) begin
        if (RST = '1') then     -- ak je aktivny RST tak sa vsetko vynuluje
            DOUT <= (others => '0');
            DOUT_VLD <= '0';
            clk_cnt <= "00001";
            data_cnt <= (others => '0');
        elsif rising_edge(CLK) then     -- RST nie je aktivny, pozerame sa na nabeznu stranu hodin
            if (clk_cnt_en = '0') then  -- clock counter nie je aktivny, nastavuje sa na 0
                clk_cnt <= (others => '0');
            else    -- clock counter je aktivny
                -- if pre CLK_CNT
                if (clk_cnt /= "11000") then   -- prvotne pocitanie do 24
                    clk_cnt <= clk_cnt + 1;
                elsif(clk_cnt = "11000") then   -- ak dosiahne 24, vynuluje sa
                    clk_cnt <= "00000";
                elsif (data_read_en = '1' and clk_cnt = "10000") then   -- data read je aktivny a na clocku je hodnota 16 -> resetuje sa spat na 0
                    clk_cnt <= "00000";  -- AK 00000 NEFUNGUJE SKUSIT 00001
                end if;

                -- if pre DATA_VLD
                if (data_cnt = "1000") then  -- prijali sme 8 bitov dat, pri 9. sa data counter zresetuje na 0
                    if (data_vld = '1') then    -- ak je data valid aktivne
                        DOUT_VLD <= '1';    -- vyslanie signalu ze data su valid
                        data_cnt <= "0000"; -- reset counteru
                    end if;
                end if;

                -- if pre DATA_CNT
                if (data_read_en = '1' and clk_cnt = "10000") then  -- data read je aktivny, citame stale pri 16. ticku hodin
                    case data_cnt is
                        when "0000" => DOUT(0) <= DIN;  -- nacitanie inputu do konkretneho bitu
                        when "0001" => DOUT(1) <= DIN;
                        when "0010" => DOUT(2) <= DIN;
                        when "0011" => DOUT(3) <= DIN;
                        when "0100" => DOUT(4) <= DIN;
                        when "0101" => DOUT(5) <= DIN;
                        when "0110" => DOUT(6) <= DIN;
                        when "0111" => DOUT(7) <= DIN;
                        when others => null;
                    end case;

                    data_cnt <= data_cnt + 1;   -- inkrementovanie data counteru

                    -- if (data_cnt = "1000") then
                    --     data_cnt <= "0000";
                    -- end if;

                    clk_cnt <= "00000";  -- AK 00000 NEFUNGUJE SKUSIT 00001  -- reset clock counteru
                end if;
            end if;
        end if;
    end process;
end architecture;
-- TODO well, rozdelila by som to na procesy podla suciastiek ake pouzivas - CNT, DC, CMP, ... prehladnejsie, funkcejsie
--TODO CMP napises takto: MIDBIT <= '1' when CNT_CLK_EN = "1111" else '0';