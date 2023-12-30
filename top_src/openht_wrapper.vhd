-------------------------------------------------------------
-- Pynq OpenHT GnuRadio testbench
--
-- Sebastien Van Cauwenberghe, ON4SEB
--
-- December 2023
-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.apb_pkg.all;
use work.axi_stream_pkg.all;

entity openht_wrapper is
    port (
        clk   : in std_logic;
        nrst : in std_logic;
        lock_i : in std_logic;

        s_apb_paddr : in std_logic_vector(31 downto 0);
        s_apb_penable : in std_logic;
        s_apb_prdata : out std_logic_vector(31 downto 0);
        s_apb_pready : out std_logic_vector(0 downto 0);
        s_apb_psel : in std_logic_vector(0 downto 0);
        s_apb_pslverr : out std_logic_vector(0 downto 0);
        s_apb_pstrb : in std_logic_vector(3 downto 0);
        s_apb_pwdata : in std_logic_vector(31 downto 0);
        s_apb_pwrite : in std_logic;

        tx_axis_tdata : out std_logic_vector(31 downto 0);
        tx_axis_tvalid : out std_logic;
        tx_axis_tready : in std_logic;

        rx_axis_tdata : in std_logic_vector(31 downto 0);
        rx_axis_tvalid : in std_logic;
        rx_axis_tready : out std_logic;

        io_in		: in std_logic_vector(2 downto 0);
		io_out	: out std_logic_vector(3 downto 0);

        -- Debug
        dbg_tx0_tdata : out std_logic_vector(31 downto 0);
        dbg_tx0_tstrb : out std_logic_vector(3 downto 0);
        dbg_tx0_tvalid : out std_logic;
        dbg_tx0_tready : out std_logic;

        dbg_tx1_tdata : out std_logic_vector(31 downto 0);
        dbg_tx1_tstrb : out std_logic_vector(3 downto 0);
        dbg_tx1_tvalid : out std_logic;
        dbg_tx1_tready : out std_logic;

        dbg_tx2_tdata : out std_logic_vector(31 downto 0);
        dbg_tx2_tstrb : out std_logic_vector(3 downto 0);
        dbg_tx2_tvalid : out std_logic;
        dbg_tx2_tready : out std_logic;

        dbg_tx3_tdata : out std_logic_vector(31 downto 0);
        dbg_tx3_tstrb : out std_logic_vector(3 downto 0);
        dbg_tx3_tvalid : out std_logic;
        dbg_tx3_tready : out std_logic;

        dbg_tx4_tdata : out std_logic_vector(31 downto 0);
        dbg_tx4_tstrb : out std_logic_vector(3 downto 0);
        dbg_tx4_tvalid : out std_logic;
        dbg_tx4_tready : out std_logic;

        dbg_tx5_tdata : out std_logic_vector(31 downto 0);
        dbg_tx5_tstrb : out std_logic_vector(3 downto 0);
        dbg_tx5_tvalid : out std_logic;
        dbg_tx5_tready : out std_logic;

        dbg_tx6_tdata : out std_logic_vector(31 downto 0);
        dbg_tx6_tstrb : out std_logic_vector(3 downto 0);
        dbg_tx6_tvalid : out std_logic;
        dbg_tx6_tready : out std_logic;

        dbg_tx7_tdata : out std_logic_vector(31 downto 0);
        dbg_tx7_tstrb : out std_logic_vector(3 downto 0);
        dbg_tx7_tvalid : out std_logic;
        dbg_tx7_tready : out std_logic;

        dbg_rx0_tdata : out std_logic_vector(31 downto 0);
        dbg_rx0_tstrb : out std_logic_vector(3 downto 0);
        dbg_rx0_tvalid : out std_logic;
        dbg_rx0_tready : out std_logic;

        dbg_rx1_tdata : out std_logic_vector(31 downto 0);
        dbg_rx1_tstrb : out std_logic_vector(3 downto 0);
        dbg_rx1_tvalid : out std_logic;
        dbg_rx1_tready : out std_logic;

        dbg_rx2_tdata : out std_logic_vector(31 downto 0);
        dbg_rx2_tstrb : out std_logic_vector(3 downto 0);
        dbg_rx2_tvalid : out std_logic;
        dbg_rx2_tready : out std_logic;

        dbg_rx3_tdata : out std_logic_vector(31 downto 0);
        dbg_rx3_tstrb : out std_logic_vector(3 downto 0);
        dbg_rx3_tvalid : out std_logic;
        dbg_rx3_tready : out std_logic;

        dbg_rx4_tdata : out std_logic_vector(31 downto 0);
        dbg_rx4_tstrb : out std_logic_vector(3 downto 0);
        dbg_rx4_tvalid : out std_logic;
        dbg_rx4_tready : out std_logic;

        dbg_rx5_tdata : out std_logic_vector(31 downto 0);
        dbg_rx5_tstrb : out std_logic_vector(3 downto 0);
        dbg_rx5_tvalid : out std_logic;
        dbg_rx5_tready : out std_logic
    );
end entity openht_wrapper;

architecture rtl of openht_wrapper is
    -- From https://stackoverflow.com/questions/56496265/vivado-x-interface-info-not-showing-up-in-block-design-gui
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_INFO of s_apb_paddr    :SIGNAL is "xilinx.com:interface:apb:1.0 S_APB PADDR";
    ATTRIBUTE X_INTERFACE_INFO of s_apb_psel     :SIGNAL is "xilinx.com:interface:apb:1.0 S_APB PSEL";
    ATTRIBUTE X_INTERFACE_INFO of s_apb_penable  :SIGNAL is "xilinx.com:interface:apb:1.0 S_APB PENABLE";
    ATTRIBUTE X_INTERFACE_INFO of s_apb_pwrite   :SIGNAL is "xilinx.com:interface:apb:1.0 S_APB PWRITE";
    ATTRIBUTE X_INTERFACE_INFO of s_apb_pwdata   :SIGNAL is "xilinx.com:interface:apb:1.0 S_APB PWDATA";
    ATTRIBUTE X_INTERFACE_INFO of s_apb_pready   :SIGNAL is "xilinx.com:interface:apb:1.0 S_APB PREADY";
    ATTRIBUTE X_INTERFACE_INFO of s_apb_prdata   :SIGNAL is "xilinx.com:interface:apb:1.0 S_APB PRDATA";
    ATTRIBUTE X_INTERFACE_INFO of s_apb_pslverr  :SIGNAL is "xilinx.com:interface:apb:1.0 S_APB PSLVERR";
    ATTRIBUTE X_INTERFACE_INFO of s_apb_pstrb    :SIGNAL is "xilinx.com:interface:apb:1.0 S_APB PSTRB";

    signal apb_in : apb_in_t;
    signal apb_out : apb_out_t;

    signal tx_axis_iq_i	: axis_in_iq_t;
    signal tx_axis_iq_o	: axis_out_iq_t;


    signal rx_axis_iq_09_i	: axis_in_iq_t;
    signal rx_axis_iq_09_o : axis_out_iq_t;
    signal rx_axis_iq_24_i	: axis_in_iq_t;
    signal rx_axis_iq_24_o : axis_out_iq_t;

    attribute MARK_DEBUG : string;
    --attribute MARK_DEBUG of apb_in : signal is "TRUE";
    --attribute MARK_DEBUG of apb_out : signal is "TRUE";

    -- Debug TX
    signal tx_dbg0_in : axis_in_iq_t;
    signal tx_dbg0_out : axis_out_iq_t;
    signal tx_dbg1_in : axis_in_iq_t;
    signal tx_dbg1_out : axis_out_iq_t;
    signal tx_dbg2_in : axis_in_iq_t;
    signal tx_dbg2_out : axis_out_iq_t;
    signal tx_dbg3_in : axis_in_iq_t;
    signal tx_dbg3_out : axis_out_iq_t;
    signal tx_dbg4_in : axis_in_iq_t;
    signal tx_dbg4_out : axis_out_iq_t;
    signal tx_dbg5_in : axis_in_iq_t;
    signal tx_dbg5_out : axis_out_iq_t;
    signal tx_dbg6_in : axis_in_iq_t;
    signal tx_dbg6_out : axis_out_iq_t;
    signal tx_dbg7_in : axis_in_iq_t;
    signal tx_dbg7_out : axis_out_iq_t;

    -- Debug RX
    signal rx_dbg0_in : axis_in_iq_t;
    signal rx_dbg0_out : axis_out_iq_t;
    signal rx_dbg1_in : axis_in_iq_t;
    signal rx_dbg1_out : axis_out_iq_t;
    signal rx_dbg2_in : axis_in_iq_t;
    signal rx_dbg2_out : axis_out_iq_t;
    signal rx_dbg3_in : axis_in_iq_t;
    signal rx_dbg3_out : axis_out_iq_t;
    signal rx_dbg4_in : axis_in_iq_t;
    signal rx_dbg4_out : axis_out_iq_t;
    signal rx_dbg5_in : axis_in_iq_t;
    signal rx_dbg5_out : axis_out_iq_t;

begin

    -- APB
    apb_in.PADDR <= s_apb_paddr(16 downto 1); -- Multiply accesses by 2 to allow 32 bits aligned accesses
    apb_in.PWRITE <= s_apb_pwrite;
    apb_in.PENABLE <= s_apb_penable;
    apb_in.PWDATA <= s_apb_pwdata(15 downto 0);
    process (s_apb_paddr, s_apb_psel)
    begin
        apb_in.PSEL <= (others => '0');
        apb_in.PSEL(to_integer(unsigned(s_apb_paddr(16 downto 17 - APB_PSELID_BITS)))) <= s_apb_psel(0);
    end process;

    s_apb_prdata <= X"0000" & apb_out.prdata;
    s_apb_pready(0) <= apb_out.PREADY;
    s_apb_pslverr(0) <= '0';
    
    tx_axis_tvalid <= tx_axis_iq_i.tvalid;
    tx_axis_tdata <= tx_axis_iq_i.tdata;
    tx_axis_iq_o.tready <= tx_axis_tready;

    rx_axis_iq_09_i.tvalid <= rx_axis_tvalid;
    rx_axis_iq_09_i.tdata <= rx_axis_tdata;
    rx_axis_iq_09_i.tstrb <= X"C";
    rx_axis_tready <= rx_axis_iq_09_o.tready;

    -- Debug TX
    dbg_tx0_tdata <= tx_dbg0_in.tdata;
    dbg_tx0_tstrb <= tx_dbg0_in.tstrb;
    dbg_tx0_tvalid <= tx_dbg0_in.tvalid;
    dbg_tx0_tready <= tx_dbg0_out.tready;

    dbg_tx1_tdata <= tx_dbg1_in.tdata;
    dbg_tx1_tstrb <= tx_dbg1_in.tstrb;
    dbg_tx1_tvalid <= tx_dbg1_in.tvalid;
    dbg_tx1_tready <= tx_dbg1_out.tready;

    dbg_tx2_tdata <= tx_dbg2_in.tdata;
    dbg_tx2_tstrb <= tx_dbg2_in.tstrb;
    dbg_tx2_tvalid <= tx_dbg2_in.tvalid;
    dbg_tx2_tready <= tx_dbg2_out.tready;

    dbg_tx3_tdata <= tx_dbg3_in.tdata;
    dbg_tx3_tstrb <= tx_dbg3_in.tstrb;
    dbg_tx3_tvalid <= tx_dbg3_in.tvalid;
    dbg_tx3_tready <= tx_dbg3_out.tready;

    dbg_tx4_tdata <= tx_dbg4_in.tdata;
    dbg_tx4_tstrb <= tx_dbg4_in.tstrb;
    dbg_tx4_tvalid <= tx_dbg4_in.tvalid;
    dbg_tx4_tready <= tx_dbg4_out.tready;

    dbg_tx5_tdata <= tx_dbg5_in.tdata;
    dbg_tx5_tstrb <= tx_dbg5_in.tstrb;
    dbg_tx5_tvalid <= tx_dbg5_in.tvalid;
    dbg_tx5_tready <= tx_dbg5_out.tready;

    dbg_tx6_tdata <= tx_dbg6_in.tdata;
    dbg_tx6_tstrb <= tx_dbg6_in.tstrb;
    dbg_tx6_tvalid <= tx_dbg6_in.tvalid;
    dbg_tx6_tready <= tx_dbg6_out.tready;

    dbg_tx7_tdata <= tx_dbg7_in.tdata;
    dbg_tx7_tstrb <= tx_dbg7_in.tstrb;
    dbg_tx7_tvalid <= tx_dbg7_in.tvalid;
    dbg_tx7_tready <= tx_dbg7_out.tready;

    -- Debug RX
    dbg_rx0_tdata <= rx_dbg0_in.tdata;
    dbg_rx0_tstrb <= rx_dbg0_in.tstrb;
    dbg_rx0_tvalid <= rx_dbg0_in.tvalid;
    dbg_rx0_tready <= rx_dbg0_out.tready;

    dbg_rx1_tdata <= rx_dbg1_in.tdata;
    dbg_rx1_tstrb <= rx_dbg1_in.tstrb;
    dbg_rx1_tvalid <= rx_dbg1_in.tvalid;
    dbg_rx1_tready <= rx_dbg1_out.tready;

    dbg_rx2_tdata <= rx_dbg2_in.tdata;
    dbg_rx2_tstrb <= rx_dbg2_in.tstrb;
    dbg_rx2_tvalid <= rx_dbg2_in.tvalid;
    dbg_rx2_tready <= rx_dbg2_out.tready;

    dbg_rx3_tdata <= rx_dbg3_in.tdata;
    dbg_rx3_tstrb <= rx_dbg3_in.tstrb;
    dbg_rx3_tvalid <= rx_dbg3_in.tvalid;
    dbg_rx3_tready <= rx_dbg3_out.tready;

    dbg_rx4_tdata <= rx_dbg4_in.tdata;
    dbg_rx4_tstrb <= rx_dbg4_in.tstrb;
    dbg_rx4_tvalid <= rx_dbg4_in.tvalid;
    dbg_rx4_tready <= rx_dbg4_out.tready;

    dbg_rx5_tdata <= rx_dbg5_in.tdata;
    dbg_rx5_tstrb <= rx_dbg5_in.tstrb;
    dbg_rx5_tvalid <= rx_dbg5_in.tvalid;
    dbg_rx5_tready <= rx_dbg5_out.tready;

    top_common_inst : entity work.top_common
    generic map (
      REV_MAJOR => 0,
      REV_MINOR => 5
    )
    port map (
      clk_i => clk,
      lock_i => lock_i,
      nrst => nrst,
      tx_axis_iq_i => tx_axis_iq_i,
      tx_axis_iq_o => tx_axis_iq_o,
      rx_axis_iq_09_i => rx_axis_iq_09_i,
      rx_axis_iq_09_o => rx_axis_iq_09_o,
      rx_axis_iq_24_i => rx_axis_iq_24_i,
      rx_axis_iq_24_o => rx_axis_iq_24_o,
      apb_in => apb_in,
      apb_out => apb_out,
      io0 => io_in(0),
      io1 => io_in(1),
      io2 => io_in(2),
      io3 => io_out(0),
      io4 => io_out(1),
      io5 => io_out(2),
      io6 => io_out(3),
      -- Debug TX
      tx_dbg0_in => tx_dbg0_in,
      tx_dbg0_out => tx_dbg0_out,
      tx_dbg1_in => tx_dbg1_in,
      tx_dbg1_out => tx_dbg1_out,
      tx_dbg2_in => tx_dbg2_in,
      tx_dbg2_out => tx_dbg2_out,
      tx_dbg3_in => tx_dbg3_in,
      tx_dbg3_out => tx_dbg3_out,
      tx_dbg4_in => tx_dbg4_in,
      tx_dbg4_out => tx_dbg4_out,
      tx_dbg5_in => tx_dbg5_in,
      tx_dbg5_out => tx_dbg5_out,
      tx_dbg6_in => tx_dbg6_in,
      tx_dbg6_out => tx_dbg6_out,
      tx_dbg7_in => tx_dbg7_in,
      tx_dbg7_out => tx_dbg7_out,
      -- Debug RX
      rx_dbg0_in => rx_dbg0_in,
      rx_dbg0_out => rx_dbg0_out,
      rx_dbg1_in => rx_dbg1_in,
      rx_dbg1_out => rx_dbg1_out,
      rx_dbg2_in => rx_dbg2_in,
      rx_dbg2_out => rx_dbg2_out,
      rx_dbg3_in => rx_dbg3_in,
      rx_dbg3_out => rx_dbg3_out,
      rx_dbg4_in => rx_dbg4_in,
      rx_dbg4_out => rx_dbg4_out,
      rx_dbg5_in => rx_dbg5_in,
      rx_dbg5_out => rx_dbg5_out
    );

end architecture;