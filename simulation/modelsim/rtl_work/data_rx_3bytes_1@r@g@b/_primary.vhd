library verilog;
use verilog.vl_types.all;
entity data_rx_3bytes_1RGB is
    port(
        in_clk          : in     vl_logic;
        in_nrst         : in     vl_logic;
        in_data         : in     vl_logic_vector(7 downto 0);
        pwm_value       : in     vl_logic_vector(7 downto 0);
        led_clk         : out    vl_logic;
        pwm_cntr_strobe : out    vl_logic;
        alrst_strobe    : out    vl_logic;
        rgb1            : out    vl_logic_vector(2 downto 0);
        rgb2            : out    vl_logic_vector(2 downto 0)
    );
end data_rx_3bytes_1RGB;
