library verilog;
use verilog.vl_types.all;
entity led_al422_main is
    generic(
        PIXEL_COUNTER_PRELOAD: integer := 2;
        PWM_PIXEL_COUNTER_CORRECTION: integer := 0;
        PIXEL_COUNTER_INIT: vl_notype;
        OE_PREDELAY     : integer := 2;
        OE_POSTDELAY    : integer := 2;
        PIXEL_COUNTER_WIDTH: integer := 3;
        oe_on_pixel     : vl_notype;
        oe_off_pixel    : vl_notype;
        last_led_row_value: vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi1, Hi1, Hi1);
        LED_ROW_INITIAL : vl_notype;
        MAX_PWM_COUNTER : integer := 2
    );
    port(
        in_clk          : in     vl_logic;
        in_nrst         : in     vl_logic;
        in_data         : in     vl_logic_vector(7 downto 0);
        al422_nrst      : out    vl_logic;
        led_clk_out     : out    vl_logic;
        led_oe_out      : out    vl_logic;
        led_lat_out     : out    vl_logic;
        led_row         : out    vl_logic_vector(4 downto 0);
        rgb1            : out    vl_logic_vector(2 downto 0);
        rgb2            : out    vl_logic_vector(2 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PIXEL_COUNTER_PRELOAD : constant is 1;
    attribute mti_svvh_generic_type of PWM_PIXEL_COUNTER_CORRECTION : constant is 1;
    attribute mti_svvh_generic_type of PIXEL_COUNTER_INIT : constant is 3;
    attribute mti_svvh_generic_type of OE_PREDELAY : constant is 1;
    attribute mti_svvh_generic_type of OE_POSTDELAY : constant is 1;
    attribute mti_svvh_generic_type of PIXEL_COUNTER_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of oe_on_pixel : constant is 3;
    attribute mti_svvh_generic_type of oe_off_pixel : constant is 3;
    attribute mti_svvh_generic_type of last_led_row_value : constant is 1;
    attribute mti_svvh_generic_type of LED_ROW_INITIAL : constant is 3;
    attribute mti_svvh_generic_type of MAX_PWM_COUNTER : constant is 1;
end led_al422_main;
