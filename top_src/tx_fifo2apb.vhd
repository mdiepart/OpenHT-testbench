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

entity tx_fifo2apb is
    port (
        clk   : in std_logic;
        reset : in std_logic;
        s_apb_paddr : in std_logic_vector(31 downto 0);
        s_apb_penable : in std_logic;
        s_apb_prdata : out std_logic_vector(31 downto 0);
        s_apb_pready : out std_logic_vector(0 downto 0);
        s_apb_psel : in std_logic_vector(0 downto 0);
        s_apb_pslverr : out std_logic_vector(0 downto 0);
        s_apb_pstrb : in std_logic_vector(3 downto 0);
        s_apb_pwdata : in std_logic_vector(31 downto 0);
        s_apb_pwrite : in std_logic;

        wr_count : in std_logic_vector(31 downto 0);
        rd_count : in std_logic_vector(31 downto 0);

        tx_axis_tdata : in std_logic_vector(31 downto 0);
        tx_axis_tvalid : in std_logic;
        tx_axis_tready : out std_logic
    );
end entity tx_fifo2apb;

architecture rtl of tx_fifo2apb is

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

    signal tx_axis_tready_i : std_logic;
begin
    s_apb_pready(0) <= '1';
    tx_axis_tready <= tx_axis_tready_i;

    process (clk)
        variable next_cntr : unsigned(9 downto 0);
    begin
        if rising_edge(clk) then
            tx_axis_tready_i <= '0';
            if s_apb_psel(0) = '1' and s_apb_penable = '0' and s_apb_pwrite = '0' then
                case s_apb_paddr(3 downto 2) is
                    when "00" =>
                        s_apb_prdata <= wr_count;

                    when "01" =>
                        if tx_axis_tvalid = '1' then
                            s_apb_prdata <= tx_axis_tdata;
                            tx_axis_tready_i <= '1';
                        else
                            s_apb_prdata <= X"99999999";
                        end if;

                    when "10" =>
                        s_apb_prdata <= rd_count;
                    
                    when others =>
                        s_apb_prdata <= (others => '0');
                end case;
            end if;
        end if;
    end process;

end architecture;
