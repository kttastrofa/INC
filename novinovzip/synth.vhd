library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity UART_RX is
  port (
    CLK: in std_logic;
    RST: in std_logic;
    DIN: in std_logic;
    DOUT: out std_logic_vector (7 downto 0);
    DOUT_VLD: out std_logic
  );
end entity;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_fsm is
  port (
    clk : in std_logic;
    rst : in std_logic;
    din : in std_logic;
    bit_fin : in std_logic;
    word_fin : in std_logic;
    validity : out std_logic;
    data : out std_logic;
    clk_count : out std_logic);
end entity uart_rx_fsm;

architecture rtl of uart_rx_fsm is
  signal pstate : std_logic_vector (1 downto 0);
  signal nstate : std_logic_vector (1 downto 0);
  signal n98_q : std_logic_vector (1 downto 0);
  signal n100_o : std_logic;
  signal n103_o : std_logic_vector (1 downto 0);
  signal n106_o : std_logic;
  signal n109_o : std_logic_vector (1 downto 0);
  signal n112_o : std_logic;
  signal n113_o : std_logic;
  signal n116_o : std_logic_vector (1 downto 0);
  signal n119_o : std_logic;
  signal n120_o : std_logic;
  signal n123_o : std_logic_vector (1 downto 0);
  signal n126_o : std_logic;
  signal n127_o : std_logic_vector (3 downto 0);
  signal n129_o : std_logic_vector (1 downto 0);
  signal n133_o : std_logic;
  signal n135_o : std_logic;
  signal n137_o : std_logic;
  signal n139_o : std_logic;
  signal n140_o : std_logic_vector (3 downto 0);
  signal n144_o : std_logic;
  signal n149_o : std_logic;
  signal n153_o : std_logic;
begin
  validity <= n144_o;
  data <= n149_o;
  clk_count <= n153_o;
  -- uart_rx_fsm.vhd:25:12
  pstate <= n98_q; -- (signal)
  -- uart_rx_fsm.vhd:26:12
  nstate <= n129_o; -- (signal)
  -- uart_rx_fsm.vhd:34:9
  process (clk, rst)
  begin
    if rst = '1' then
      n98_q <= "00";
    elsif rising_edge (clk) then
      n98_q <= nstate;
    end if;
  end process;
  -- uart_rx_fsm.vhd:44:23
  n100_o <= not din;
  -- uart_rx_fsm.vhd:44:17
  n103_o <= "00" when n100_o = '0' else "01";
  -- uart_rx_fsm.vhd:42:13
  n106_o <= '1' when pstate = "00" else '0';
  -- uart_rx_fsm.vhd:49:17
  n109_o <= "01" when bit_fin = '0' else "10";
  -- uart_rx_fsm.vhd:47:13
  n112_o <= '1' when pstate = "01" else '0';
  -- uart_rx_fsm.vhd:54:32
  n113_o <= bit_fin and word_fin;
  -- uart_rx_fsm.vhd:54:17
  n116_o <= "10" when n113_o = '0' else "11";
  -- uart_rx_fsm.vhd:52:13
  n119_o <= '1' when pstate = "10" else '0';
  -- uart_rx_fsm.vhd:59:32
  n120_o <= bit_fin and din;
  -- uart_rx_fsm.vhd:59:17
  n123_o <= "11" when n120_o = '0' else "00";
  -- uart_rx_fsm.vhd:57:13
  n126_o <= '1' when pstate = "11" else '0';
  n127_o <= n126_o & n119_o & n112_o & n106_o;
  -- uart_rx_fsm.vhd:41:9
  with n127_o select n129_o <=
    n123_o when "1000",
    n116_o when "0100",
    n109_o when "0010",
    n103_o when "0001",
    "00" when others;
  -- uart_rx_fsm.vhd:70:13
  n133_o <= '1' when pstate = "00" else '0';
  -- uart_rx_fsm.vhd:74:13
  n135_o <= '1' when pstate = "01" else '0';
  -- uart_rx_fsm.vhd:76:13
  n137_o <= '1' when pstate = "10" else '0';
  -- uart_rx_fsm.vhd:78:13
  n139_o <= '1' when pstate = "11" else '0';
  n140_o <= n139_o & n137_o & n135_o & n133_o;
  -- uart_rx_fsm.vhd:69:9
  with n140_o select n144_o <=
    '1' when "1000",
    n144_o when "0100",
    n144_o when "0010",
    '0' when "0001",
    'X' when others;
  -- uart_rx_fsm.vhd:69:9
  with n140_o select n149_o <=
    '0' when "1000",
    '1' when "0100",
    n149_o when "0010",
    '0' when "0001",
    'X' when others;
  -- uart_rx_fsm.vhd:69:9
  with n140_o select n153_o <=
    n153_o when "1000",
    n153_o when "0100",
    '1' when "0010",
    '0' when "0001",
    'X' when others;
end rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture rtl of uart_rx is
  signal wrap_CLK: std_logic;
  signal wrap_RST: std_logic;
  signal wrap_DIN: std_logic;
  subtype typwrap_DOUT is std_logic_vector (7 downto 0);
  signal wrap_DOUT: typwrap_DOUT;
  signal wrap_DOUT_VLD: std_logic;
  signal bit_finish : std_logic;
  signal word_finish : std_logic;
  signal validity : std_logic;
  signal data : std_logic;
  signal clock_count : std_logic;
  signal clk_counter_out : std_logic_vector (3 downto 0);
  signal mid_bit : std_logic;
  signal data_counter_out : std_logic_vector (2 downto 0);
  signal decoder_out : std_logic_vector (7 downto 0);
  signal n5_o : std_logic_vector (3 downto 0);
  signal n7_o : std_logic_vector (3 downto 0);
  signal n10_q : std_logic_vector (3 downto 0);
  signal n13_o : std_logic;
  signal n14_o : std_logic;
  signal n18_o : std_logic;
  signal n19_o : std_logic;
  signal n24_o : std_logic_vector (2 downto 0);
  signal n25_o : std_logic_vector (2 downto 0);
  signal n27_o : std_logic_vector (2 downto 0);
  signal n30_q : std_logic_vector (2 downto 0);
  signal n33_o : std_logic;
  signal n34_o : std_logic;
  signal n38_o : std_logic;
  signal n40_o : std_logic;
  signal n42_o : std_logic;
  signal n44_o : std_logic;
  signal n46_o : std_logic;
  signal n48_o : std_logic;
  signal n50_o : std_logic;
  signal n52_o : std_logic;
  signal n54_o : std_logic;
  signal n55_o : std_logic_vector (7 downto 0);
  signal n56_o : std_logic;
  signal n57_o : std_logic;
  signal n58_o : std_logic;
  signal n59_o : std_logic;
  signal n60_o : std_logic;
  signal n61_o : std_logic;
  signal n62_o : std_logic;
  signal n63_o : std_logic;
  signal n64_o : std_logic;
  signal n65_o : std_logic;
  signal n66_o : std_logic;
  signal n67_o : std_logic;
  signal n68_o : std_logic;
  signal n69_o : std_logic;
  signal n70_o : std_logic;
  signal n71_o : std_logic;
  signal n72_o : std_logic_vector (7 downto 0);
  signal n73_o : std_logic_vector (7 downto 0);
  signal n75_o : std_logic_vector (7 downto 0);
  signal n78_q : std_logic_vector (7 downto 0);
  signal n80_o : std_logic;
  signal n81_o : std_logic;
  signal n83_o : std_logic;
  signal n84_o : std_logic_vector (7 downto 0);
  signal fsm_validity : std_logic;
  signal fsm_data : std_logic;
  signal fsm_clk_count : std_logic;
begin
  wrap_clk <= clk;
  wrap_rst <= rst;
  wrap_din <= din;
  dout <= wrap_dout;
  dout_vld <= wrap_dout_vld;
  wrap_DOUT <= n84_o;
  wrap_DOUT_VLD <= n81_o;
  -- uart_rx.vhd:26:12
  bit_finish <= n14_o; -- (signal)
  -- uart_rx.vhd:27:12
  word_finish <= n34_o; -- (signal)
  -- uart_rx.vhd:28:12
  validity <= fsm_validity; -- (signal)
  -- uart_rx.vhd:29:12
  data <= fsm_data; -- (signal)
  -- uart_rx.vhd:30:12
  clock_count <= fsm_clk_count; -- (signal)
  -- uart_rx.vhd:31:12
  clk_counter_out <= n10_q; -- (signal)
  -- uart_rx.vhd:32:12
  mid_bit <= n19_o; -- (signal)
  -- uart_rx.vhd:33:12
  data_counter_out <= n30_q; -- (signal)
  -- uart_rx.vhd:34:12
  decoder_out <= n78_q; -- (signal)
  -- uart_rx.vhd:42:52
  n5_o <= std_logic_vector (unsigned (clk_counter_out) + unsigned'("0001"));
  -- uart_rx.vhd:41:13
  n7_o <= "0000" when clock_count = '0' else n5_o;
  -- uart_rx.vhd:40:9
  process (wrap_CLK)
  begin
    if rising_edge (wrap_CLK) then
      n10_q <= n7_o;
    end if;
  end process;
  -- uart_rx.vhd:49:44
  n13_o <= '1' when clk_counter_out = "1111" else '0';
  -- uart_rx.vhd:49:23
  n14_o <= '0' when n13_o = '0' else '1';
  -- uart_rx.vhd:52:41
  n18_o <= '1' when clk_counter_out = "0111" else '0';
  -- uart_rx.vhd:52:20
  n19_o <= '0' when n18_o = '0' else '1';
  -- uart_rx.vhd:59:58
  n24_o <= std_logic_vector (unsigned (data_counter_out) + unsigned'("001"));
  -- uart_rx.vhd:58:17
  n25_o <= data_counter_out when bit_finish = '0' else n24_o;
  -- uart_rx.vhd:57:13
  n27_o <= "000" when data = '0' else n25_o;
  -- uart_rx.vhd:56:9
  process (wrap_CLK)
  begin
    if rising_edge (wrap_CLK) then
      n30_q <= n27_o;
    end if;
  end process;
  -- uart_rx.vhd:67:46
  n33_o <= '1' when data_counter_out = "111" else '0';
  -- uart_rx.vhd:67:24
  n34_o <= '0' when n33_o = '0' else '1';
  -- uart_rx.vhd:75:35
  n38_o <= mid_bit and data;
  -- uart_rx.vhd:77:25
  n40_o <= '1' when data_counter_out = "000" else '0';
  -- uart_rx.vhd:78:25
  n42_o <= '1' when data_counter_out = "001" else '0';
  -- uart_rx.vhd:79:25
  n44_o <= '1' when data_counter_out = "010" else '0';
  -- uart_rx.vhd:80:25
  n46_o <= '1' when data_counter_out = "011" else '0';
  -- uart_rx.vhd:81:25
  n48_o <= '1' when data_counter_out = "100" else '0';
  -- uart_rx.vhd:82:25
  n50_o <= '1' when data_counter_out = "101" else '0';
  -- uart_rx.vhd:83:25
  n52_o <= '1' when data_counter_out = "110" else '0';
  -- uart_rx.vhd:84:25
  n54_o <= '1' when data_counter_out = "111" else '0';
  n55_o <= n54_o & n52_o & n50_o & n48_o & n46_o & n44_o & n42_o & n40_o;
  n56_o <= decoder_out (0);
  -- uart_rx.vhd:76:21
  with n55_o select n57_o <=
    n56_o when "10000000",
    n56_o when "01000000",
    n56_o when "00100000",
    n56_o when "00010000",
    n56_o when "00001000",
    n56_o when "00000100",
    n56_o when "00000010",
    wrap_DIN when "00000001",
    n56_o when others;
  n58_o <= decoder_out (1);
  -- uart_rx.vhd:76:21
  with n55_o select n59_o <=
    n58_o when "10000000",
    n58_o when "01000000",
    n58_o when "00100000",
    n58_o when "00010000",
    n58_o when "00001000",
    n58_o when "00000100",
    wrap_DIN when "00000010",
    n58_o when "00000001",
    n58_o when others;
  n60_o <= decoder_out (2);
  -- uart_rx.vhd:76:21
  with n55_o select n61_o <=
    n60_o when "10000000",
    n60_o when "01000000",
    n60_o when "00100000",
    n60_o when "00010000",
    n60_o when "00001000",
    wrap_DIN when "00000100",
    n60_o when "00000010",
    n60_o when "00000001",
    n60_o when others;
  n62_o <= decoder_out (3);
  -- uart_rx.vhd:76:21
  with n55_o select n63_o <=
    n62_o when "10000000",
    n62_o when "01000000",
    n62_o when "00100000",
    n62_o when "00010000",
    wrap_DIN when "00001000",
    n62_o when "00000100",
    n62_o when "00000010",
    n62_o when "00000001",
    n62_o when others;
  n64_o <= decoder_out (4);
  -- uart_rx.vhd:76:21
  with n55_o select n65_o <=
    n64_o when "10000000",
    n64_o when "01000000",
    n64_o when "00100000",
    wrap_DIN when "00010000",
    n64_o when "00001000",
    n64_o when "00000100",
    n64_o when "00000010",
    n64_o when "00000001",
    n64_o when others;
  n66_o <= decoder_out (5);
  -- uart_rx.vhd:76:21
  with n55_o select n67_o <=
    n66_o when "10000000",
    n66_o when "01000000",
    wrap_DIN when "00100000",
    n66_o when "00010000",
    n66_o when "00001000",
    n66_o when "00000100",
    n66_o when "00000010",
    n66_o when "00000001",
    n66_o when others;
  n68_o <= decoder_out (6);
  -- uart_rx.vhd:76:21
  with n55_o select n69_o <=
    n68_o when "10000000",
    wrap_DIN when "01000000",
    n68_o when "00100000",
    n68_o when "00010000",
    n68_o when "00001000",
    n68_o when "00000100",
    n68_o when "00000010",
    n68_o when "00000001",
    n68_o when others;
  n70_o <= decoder_out (7);
  -- uart_rx.vhd:76:21
  with n55_o select n71_o <=
    wrap_DIN when "10000000",
    n70_o when "01000000",
    n70_o when "00100000",
    n70_o when "00010000",
    n70_o when "00001000",
    n70_o when "00000100",
    n70_o when "00000010",
    n70_o when "00000001",
    n70_o when others;
  n72_o <= n71_o & n69_o & n67_o & n65_o & n63_o & n61_o & n59_o & n57_o;
  -- uart_rx.vhd:75:17
  n73_o <= decoder_out when n38_o = '0' else n72_o;
  -- uart_rx.vhd:72:13
  n75_o <= n73_o when wrap_RST = '0' else "00000000";
  -- uart_rx.vhd:71:9
  process (wrap_CLK)
  begin
    if rising_edge (wrap_CLK) then
      n78_q <= n75_o;
    end if;
  end process;
  -- uart_rx.vhd:92:41
  n80_o <= validity and mid_bit;
  -- uart_rx.vhd:92:21
  n81_o <= '0' when n80_o = '0' else '1';
  -- uart_rx.vhd:93:45
  n83_o <= validity and mid_bit;
  -- uart_rx.vhd:93:25
  n84_o <= "00000000" when n83_o = '0' else decoder_out;
  -- uart_rx.vhd:96:5
  fsm : entity work.uart_rx_fsm port map (
    clk => wrap_CLK,
    rst => wrap_RST,
    din => wrap_DIN,
    bit_fin => bit_finish,
    word_fin => word_finish,
    validity => fsm_validity,
    data => fsm_data,
    clk_count => fsm_clk_count);
end rtl;
