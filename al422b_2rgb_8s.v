/***************************************************************************************************/
// definitions for modes of operation
/***************************************************************************************************/

// input color data format - only one line must be uncommented
// truecolor - 3 bytes per pixel
// highcolor - 2 bytes per pixel, RGB555 format
`define TRUECOLOR	1
//`define HIGHCOLOR	1

// LED panel scan type - only one line must be uncommented
`define SCAN_x8 	1
//`define SCAN_x16 	1
//`define SCAN_x32	1

// LED panel RGB inputs quantity - only one line must be uncommented
`define RGB_out1	1
//`define RGB_out2	1

// LED panels total pixels count
`define PIXEL_COUNT 	8

// phases of output signals for LED. If commented - active HIGH and RISING for CLK
//`define LED_LAT_ACTIVE_LOW	1
`define LED_OE_ACTIVE_LOW	1
//`define LED_CLK_ON_FALL		1

/***************************************************************************************************/
// main modules body
/***************************************************************************************************/
module al422b_2rgb_8s (
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

	reg led_lat, led_oe;
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
	
	reg [7:0] pwm_cntr;
	
	wire lat_strobe, pix_cntr_strobe, row_cntr_strobe, pwm_cntr_strobe, alrst_strobe;
	
`ifdef TRUECOLOR
	`ifdef RGB_out1
	data_rx_3bytes_1RGB data_decoder(in_clk, in_nrst, in_data, pwm_cntr,
		lat_strobe, pix_cntr_strobe, row_cntr_strobe, pwm_cntr_strobe, alrst_strobe, 
		led_clk, rgb1, rgb2);
	`endif
	
	`ifdef RGB_out2
	data_rx_3bytes_2RGB data_decoder(in_clk, in_nrst, in_data, pwm_cntr,
		lat_strobe, pix_cntr_strobe, row_cntr_strobe, pwm_cntr_strobe, alrst_strobe,
		led_clk, rgb1, rgb2);
	`endif
`endif

`ifdef HIGHCOLOR
	`ifdef RGB_out1
	data_rx_2bytes_1RGB data_decoder(in_clk, in_nrst, in_data, pwm_cntr,
		lat_strobe, pix_cntr_strobe, row_cntr_strobe, pwm_cntr_strobe, alrst_strobe, 
		led_clk, rgb1, rgb2);
	`endif
	
	`ifdef RGB_out2
	data_rx_2bytes_2RGB data_decoder(in_clk, in_nrst, in_data, pwm_cntr,
		lat_strobe, pix_cntr_strobe, row_cntr_strobe, pwm_cntr_strobe, alrst_strobe,
		led_clk, rgb1, rgb2);
	`endif
`endif


`define	LED_LAT_PHASE	8'h02
`define	OE_PREDELAY		2
`define	OE_POSTDELAY	2

	// pixel counter
	parameter PIXEL_COUNTER_WIDTH = $clog2(`PIXEL_COUNT);
	reg [PIXEL_COUNTER_WIDTH - 1:0] pixel_counter;
	
	wire last_pixel_in_row;
	assign last_pixel_in_row = (pixel_counter == `PIXEL_COUNT - 1);
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			pixel_counter <= 0;
		else
			if (pix_cntr_strobe)
				if (last_pixel_in_row)
					pixel_counter <= 0;
				else
					pixel_counter <= pixel_counter + 1;
					
	// led_oe
	parameter oe_on_pixel = `LED_LAT_PHASE + `OE_POSTDELAY;
	parameter oe_off_pixel = (`LED_LAT_PHASE > `OE_PREDELAY) ? (`LED_LAT_PHASE - `OE_PREDELAY) : (`PIXEL_COUNT - 1 - `OE_PREDELAY + `LED_LAT_PHASE);
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			led_oe <= 1'b0;
		else
			if (pixel_counter == oe_on_pixel)
				led_oe <= 1'b1;
			else
				if (pixel_counter == oe_off_pixel)
					led_oe <= 1'b0;
	
	// led_lat			
	wire tmp_led_lat; 
	assign tmp_led_lat = (pixel_counter == `LED_LAT_PHASE);
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			led_lat <= 1'b0;
		else
			led_lat <= (tmp_led_lat & lat_strobe);

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
	
	wire last_led_row_for_alrst;
	assign last_led_row_for_alrst = (led_row == last_led_row_value - 5'b00001);
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			led_row <= (last_led_row_value - 8'h1);
		else
			if (led_lat)
				if (last_led_row)
					led_row <= 5'b00000;
				else
					led_row <= led_row + 5'b00001;

	// al422_nrst
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			al422_nrst <= 1'b1;
		else
			al422_nrst <= ~(alrst_strobe & last_pixel_in_row);
//			al422_nrst <= ~(alrst_strobe & last_pixel_in_row & last_led_row_for_alrst);

	// pwm_cntr
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			pwm_cntr <= 8'b00000000;
		else
			if (pwm_cntr_strobe & (pixel_counter == 0) & (led_row == last_led_row_value - 1))
				pwm_cntr <= pwm_cntr + 8'h01;

endmodule
