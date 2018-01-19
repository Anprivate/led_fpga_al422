/***************************************************************************************************/
// definitions for modes of operation
/***************************************************************************************************/

// input color data format - only one line must be uncommented
// truecolor - 3 bytes per pixel
// highcolor - 2 bytes per pixel, RGB565 format
`define TRUECOLOR	1
//`define HIGHCOLOR	1

// LED panel RGB inputs quantity - only one line must be uncommented
`define RGB_out1	1
//`define RGB_out2	1

// LED panel scan type - only one line must be uncommented
`define SCAN_x8 	1
//`define SCAN_x16 	1
//`define SCAN_x32	1

// LED panels total pixels count
`define PIXEL_COUNT 	64

// phases of output signals for LED. If commented - active HIGH and RISING for CLK
`define LED_OE_ACTIVE_LOW	1
//`define LED_CLK_ON_FALL		1
//`define LED_LAT_ACTIVE_LOW	1

`define OE_PREDELAY	2
`define OE_POSTDELAY	2

/***************************************************************************************************/
// main modules body - DON'T MODIFY ANYTHING BELOW THIS LINE!!!
/***************************************************************************************************/
module led_al422_main(
	input wire in_clk, in_nrst,
	// al422 pins
	input wire [7:0] in_data,
	output reg al422_nrst,
	// led outpur pins HUB75E
	output wire led_clk_out, led_oe_out, led_lat_out,
	// up to 1/32 scan
	output reg [4:0] led_row,
	// up to 2 RGB outputs
	output wire [2:0] rgb1, rgb2
);

	reg led_oe;
	wire led_lat;
	wire led_clk;

`ifdef LED_LAT_ACTIVE_LOW
	assign led_lat_out = ~led_lat;
`else
	assign led_lat_out = led_lat;
`endif

`ifdef LED_OE_ACTIVE_LOW
	assign led_oe_out = ~led_oe;
`else
	assign led_oe_out = led_oe;
`endif
	
	
`ifdef LED_CLK_ON_FALL
	assign led_clk_out = ~led_clk;
`else
	assign led_clk_out = led_clk;
`endif
	
	wire [2:0] rgb1_tmp;
	wire [2:0] rgb2_tmp;
	assign rgb1 = rgb1_tmp;
	assign rgb2 = rgb2_tmp;
	
	wire pwm_cntr_strobe, alrst_strobe;

`ifdef TRUECOLOR
	`define PWM_COUNTER_WIDTH	8
	
	reg [`PWM_COUNTER_WIDTH-1:0] pwm_cntr;
	wire [`PWM_COUNTER_WIDTH-1:0] pwm_for_decoder;

	// bits shuffling for PWM dithering
	assign pwm_for_decoder = {pwm_cntr[0], pwm_cntr[1], pwm_cntr[2], pwm_cntr[3], pwm_cntr[4], pwm_cntr[5], pwm_cntr[6], pwm_cntr[7]}; 

	`ifdef RGB_out1
		parameter PIXEL_COUNTER_PRELOAD = 2;
		parameter PWM_PIXEL_COUNTER_CORRECTION = 0;
		data_rx_3bytes_1RGB data_decoder(in_clk, in_nrst, in_data, pwm_for_decoder,
			led_clk, pwm_cntr_strobe, alrst_strobe, 
			rgb1_tmp, rgb2_tmp);
	`endif
	
	`ifdef RGB_out2
		parameter PIXEL_COUNTER_PRELOAD = 1;
		parameter PWM_PIXEL_COUNTER_CORRECTION = 0;
		data_rx_3bytes_2RGB data_decoder(in_clk, in_nrst, in_data, pwm_for_decoder,
			led_clk, pwm_cntr_strobe, alrst_strobe,
			rgb1_tmp, rgb2_tmp);
	`endif
`endif

`ifdef HIGHCOLOR
	`define PWM_COUNTER_WIDTH	6
	reg [`PWM_COUNTER_WIDTH-1:0] pwm_cntr;
	wire [`PWM_COUNTER_WIDTH-1:0] pwm_for_decoder;
	
	// bits shuffling for PWM dithering
	assign pwm_for_decoder = {pwm_cntr[0], pwm_cntr[1], pwm_cntr[2], pwm_cntr[3], pwm_cntr[4], pwm_cntr[5]}; 

	`ifdef RGB_out1
		parameter PIXEL_COUNTER_PRELOAD = 2;
		parameter PWM_PIXEL_COUNTER_CORRECTION = 1;
		data_rx_2bytes_1RGB data_decoder(in_clk, in_nrst, in_data, pwm_for_decoder,
			led_clk, pwm_cntr_strobe, alrst_strobe, 
			rgb1_tmp, rgb2_tmp);
	`endif
	
	`ifdef RGB_out2
		parameter PIXEL_COUNTER_PRELOAD = 1;
		parameter PWM_PIXEL_COUNTER_CORRECTION = 0;
		data_rx_2bytes_2RGB data_decoder(in_clk, in_nrst, in_data, pwm_for_decoder,
			led_clk, pwm_cntr_strobe, alrst_strobe,
			rgb1_tmp, rgb2_tmp);
	`endif
`endif
	
	parameter PIXEL_COUNTER_INIT = `PIXEL_COUNT - PIXEL_COUNTER_PRELOAD;


	// pixel counter
	parameter PIXEL_COUNTER_WIDTH = $clog2(`PIXEL_COUNT);
	reg [PIXEL_COUNTER_WIDTH - 1:0] pixel_counter;
	
	wire last_pixel_in_row;
	assign last_pixel_in_row = (pixel_counter == `PIXEL_COUNT - 1);
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			pixel_counter <= (PIXEL_COUNTER_INIT);
		else
			if (led_clk)
				if (pixel_counter == `PIXEL_COUNT - 1)
					pixel_counter <= 0;
				else
					pixel_counter <= pixel_counter + 1;
					
	// led_lat			
	assign led_lat = (last_pixel_in_row & led_clk);

	// led_oe
	parameter oe_on_pixel = `OE_POSTDELAY;
	parameter oe_off_pixel = `PIXEL_COUNT - `OE_PREDELAY;
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			led_oe <= 1'b0;
		else
			if (pixel_counter == oe_on_pixel)
				led_oe <= 1'b1;
			else
				if (pixel_counter == oe_off_pixel)
					led_oe <= 1'b0;
	
	// led_row
`ifdef SCAN_x32
	parameter last_led_row_value = 5'b11111;
`endif 	

`ifdef SCAN_x16
	parameter last_led_row_value = 5'b01111;
`endif 	

`ifdef SCAN_x8
	parameter last_led_row_value = 5'b00111;
`endif 	
	
	wire last_led_row;
	assign last_led_row = (led_row == last_led_row_value);
	
	parameter LED_ROW_INITIAL = last_led_row_value - 5'h01;
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			led_row <= LED_ROW_INITIAL;
		else
			if (led_lat)
				if (last_led_row)
					led_row <= 5'h00;
				else
					led_row <= led_row + 5'h01;

	// al422_nrst
	wire row_for_alrst;
	assign row_for_alrst = (led_row == last_led_row_value - 5'b00001);
	
	wire pix_cntr_for_alrst;
	assign pix_cntr_for_alrst = (pixel_counter == (PIXEL_COUNTER_INIT - 1));

	wire tmp_al422_nrst_strobe;
	assign tmp_al422_nrst_strobe = alrst_strobe & pix_cntr_for_alrst & row_for_alrst;
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			al422_nrst <= 1'b1;
		else
			al422_nrst <= ~tmp_al422_nrst_strobe;

	// pwm_cntr
	parameter MAX_PWM_COUNTER = (1 << `PWM_COUNTER_WIDTH) - 2;
	
	wire row_for_pwm;
	assign row_for_pwm = (led_row == (last_led_row_value - 1)); 
	
	wire  pix_cntr_for_pwm;
	assign pix_cntr_for_pwm = (pixel_counter == (PIXEL_COUNTER_INIT + PWM_PIXEL_COUNTER_CORRECTION));
	
	wire tmp_pwm_strobe;
	assign tmp_pwm_strobe = pwm_cntr_strobe & pix_cntr_for_pwm & row_for_pwm; 
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			pwm_cntr <= MAX_PWM_COUNTER;
		else
			if (tmp_pwm_strobe)
				if (pwm_cntr == MAX_PWM_COUNTER)
					pwm_cntr <= 0;
				else
					pwm_cntr <= pwm_cntr + 1;

endmodule
