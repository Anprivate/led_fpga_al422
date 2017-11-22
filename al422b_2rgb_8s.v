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
`define PIXEL_COUNT 	64
// bitwidth of pixel_counter
// up to 16 - 4
// 17-32 - 5
// 33-64 - 6
// 65-128 - 7
// etc. etc.
//`define PIXEL_COUNTER_WIDTH 6

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
	
	wire last_phase, last_phase_for_alrst, lat_strobe;
	
`ifdef TRUECOLOR
	`ifdef RGB_out1
	data_rx_3bytes_1RGB data_decoder(in_clk, in_nrst, in_data, pwm_cntr,
		last_phase, last_phase_for_alrst, lat_strobe,
		led_clk, rgb1, rgb2);
	`endif
	
	`ifdef RGB_out2
	data_rx_3bytes_2RGB data_decoder(in_clk, in_nrst, in_data, pwm_cntr,
		last_phase, last_phase_for_alrst, lat_strobe,
		led_clk, rgb1, rgb2);
	`endif
`endif

`ifdef HIGHCOLOR
	`ifdef RGB_out1
	data_rx_2bytes_1RGB data_decoder(in_clk, in_nrst, in_data, pwm_cntr,
		last_phase, last_phase_for_alrst, lat_strobe,
		led_clk, rgb1, rgb2);
	`endif
	
	`ifdef RGB_out2
	data_rx_2bytes_2RGB data_decoder(in_clk, in_nrst, in_data, pwm_cntr,
		last_phase, last_phase_for_alrst, lat_strobe,
		led_clk, rgb1, rgb2);
	`endif
`endif

	// pixel counter
	parameter PIXEL_COUNTER_WIDTH = $clog2(`PIXEL_COUNT);
	reg [PIXEL_COUNTER_WIDTH - 1:0] pixel_counter;
	
	wire last_pixel_in_row;
	assign last_pixel_in_row = (pixel_counter == (`PIXEL_COUNT - 1));
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			pixel_counter <= (`PIXEL_COUNT - 1);
		else
			if (last_phase)
				if (last_pixel_in_row)
					pixel_counter <= 0;
				else
					pixel_counter <= pixel_counter + 1;
					
	// led_oe
	parameter oe_on_pixel = 5;
	parameter oe_off_pixel = `PIXEL_COUNT - 5;
	
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
	assign last_led_row = led_row == last_led_row_value;
	
	wire last_led_row_for_alrst;
	assign last_led_row_for_alrst = led_row == last_led_row_value - 5'b00001;
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			led_row <= (last_led_row_value - 5'b00001);
		else
			if (last_phase & last_pixel_in_row)
				if (last_led_row)
					led_row <= 5'b00000;
				else
					led_row <= led_row + 5'b00001;

	// al422_nrst
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			al422_nrst <= 1'b0;
		else
			al422_nrst <= ~(last_phase_for_alrst & last_pixel_in_row & last_led_row_for_alrst);

	// led_lat			
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			led_lat <= 1'b0;
		else
			led_lat <= ((pixel_counter == 0) & lat_strobe);

	// pwm_cntr
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			pwm_cntr <= 8'b00000000;
		else
			if (last_phase & last_pixel_in_row & last_led_row)
				pwm_cntr <= pwm_cntr + 8'h01;

endmodule

module data_rx_3bytes_2RGB(
	input wire in_clk, in_nrst,
	input wire [7:0] in_data,
	input wire [7:0] pwm_value,
	
	output reg last_phase_strobe,
	output reg alrst_strobe,
	output reg lat_strobe,
	output reg led_clk,
	output reg [2:0] rgb1, rgb2
);

	reg [1:0] color_cntr;
	reg rgb_1_2;
	
	wire [2:0] cur_phase;
	assign cur_phase = {rgb_1_2, color_cntr};
	
		reg tmp_led_clk;
	always @(posedge in_clk)
	begin
		last_phase_strobe <= (cur_phase == 3'b110);
		alrst_strobe <= (cur_phase == 3'b100);
		lat_strobe <= (cur_phase == 3'b100);
		tmp_led_clk <= (cur_phase == 3'b111);
	end

	always @(negedge in_clk)
		led_clk <= tmp_led_clk;

	reg [7:0] in_data_buffer;
	always @(posedge in_clk)
		in_data_buffer <= in_data;
		
	always @(posedge in_clk)
	begin
		if (~in_nrst)
		begin
			color_cntr <= 2'b00;
			rgb_1_2 <= 1'b0;
		end
		else
		begin
			if (color_cntr == 2'b10)
			begin
				color_cntr <= 2'b00;
				rgb_1_2 <= ~rgb_1_2;
			end
			else
				color_cntr <= color_cntr + 2'b01;
		end
	end
			
	reg comparator_out;

	reg [3:0] tmp_reg_buffer, tmp_reg_pwm;
	reg tmp_carry;
	
	wire first_stage_out;
	assign first_stage_out = (in_data_buffer [7:4] > pwm_value [7:4]);
	
	wire second_stage_out;
	assign second_stage_out = (tmp_reg_buffer > tmp_reg_pwm);
		
	always @(posedge in_clk)
	begin
		tmp_reg_buffer <= in_data_buffer[3:0];
		tmp_reg_pwm <= pwm_value [3:0];
		tmp_carry <= first_stage_out;

		comparator_out <= tmp_carry | second_stage_out;
	end
	
	always @(posedge in_clk or negedge in_nrst)
	begin
		if (~in_nrst)
		begin
			rgb1 <= 3'b000;
			rgb2 <= 3'b000;
		end
		else
		begin
			if (rgb_1_2)
			begin
				case (color_cntr)
					2'b00: rgb2[0] <= comparator_out;
					2'b01: rgb2[1] <= comparator_out;
					2'b10: rgb2[2] <= comparator_out;
				endcase
			end
			else
			begin
				case (color_cntr)
					2'b00: rgb1[0] <= comparator_out;
					2'b01: rgb1[1] <= comparator_out;
					2'b10: rgb1[2] <= comparator_out;
				endcase
			end
		end
	end
endmodule

module data_rx_3bytes_1RGB(
	input wire in_clk, in_nrst,
	input wire [7:0] in_data,
	input wire [7:0] pwm_value,
	
	output reg last_phase_strobe,
	output reg alrst_strobe,
	output reg lat_strobe,
	output reg led_clk,
	output reg [2:0] rgb1, rgb2
);

	reg [1:0] color_cntr;
	
	wire [1:0] cur_phase;
	assign cur_phase = color_cntr;
	
	reg tmp_led_clk;
	always @(posedge in_clk)
	begin
		last_phase_strobe <= (cur_phase == 2'b10);
		alrst_strobe <= (cur_phase == 2'b10);
		lat_strobe <= (cur_phase == 2'b10);
		tmp_led_clk <= (cur_phase == 2'b11);
	end

	always @(negedge in_clk)
		led_clk <= tmp_led_clk;

	reg [7:0] in_data_buffer;
	always @(posedge in_clk)
		in_data_buffer <= in_data;
		
	always @(posedge in_clk)
	begin
		if (~in_nrst)
			color_cntr <= 2'b00;
		else
		begin
			if (color_cntr == 2'b10)
				color_cntr <= 2'b00;
			else
				color_cntr <= color_cntr + 2'b01;
		end
	end
			
	reg comparator_out;

	reg [3:0] tmp_reg_buffer, tmp_reg_pwm;
	reg tmp_carry;
	
	wire first_stage_out;
	assign first_stage_out = (in_data_buffer [7:4] > pwm_value [7:4]);
	
	wire second_stage_out;
	assign second_stage_out = (tmp_reg_buffer > tmp_reg_pwm);
		
	always @(posedge in_clk)
	begin
		tmp_reg_buffer <= in_data_buffer[3:0];
		tmp_reg_pwm <= pwm_value [3:0];
		tmp_carry <= first_stage_out;

		comparator_out <= tmp_carry | second_stage_out;
	end
	
	always @(posedge in_clk or negedge in_nrst)
	begin
		if (~in_nrst)
		begin
			rgb1 <= 3'b000;
			rgb2 <= 3'b000;
		end
		else
		begin
			case (color_cntr)
				2'b00: rgb1[0] <= comparator_out;
				2'b01: rgb1[1] <= comparator_out;
				2'b10: rgb1[2] <= comparator_out;
			endcase
			rgb2 <= 3'b000;
		end
	end

endmodule

module data_rx_2bytes_1RGB(
	input wire in_clk, in_nrst,
	input wire [7:0] in_data,
	input wire [7:0] pwm_value,
	
	output reg last_phase_strobe,
	output reg alrst_strobe,
	output reg lat_strobe,
	output reg led_clk,
	output reg [2:0] rgb1, rgb2
);

	reg color_cntr;
	
	wire cur_phase;
	assign cur_phase = color_cntr;
	
	reg tmp_led_clk;
	always @(posedge in_clk)
	begin
		last_phase_strobe <= (cur_phase == 2'b10);
		alrst_strobe <= (cur_phase == 2'b10);
		lat_strobe <= (cur_phase == 2'b10);
		tmp_led_clk <= (cur_phase == 2'b11);
	end

	always @(negedge in_clk)
		led_clk <= tmp_led_clk;

	reg [15:0] in_data_buffer;
	always @(posedge in_clk)
		if (cur_phase)
			in_data_buffer [15:8] <= in_data;
		else
			in_data_buffer [7:0] <= in_data;
		
	always @(posedge in_clk)
	begin
		if (~in_nrst)
			color_cntr <= 1'b0;
		else
			color_cntr <= ~color_cntr;
	end
	
	wire [2:0] tmp_rgb;
	color_comparator_rgb555 comparator_inst0(in_data_buffer, pwm_value[4:0], tmp_rgb[0], tmp_rgb[1], tmp_rgb[2]);
	
	always @(posedge in_clk or negedge in_nrst)
	begin
		if (~in_nrst)
		begin
			rgb1 <= 3'b000;
			rgb2 <= 3'b000;
		end
		else
		begin
			if (~color_cntr)
				rgb1 <= tmp_rgb;
			rgb2 <= 3'b000;
		end
	end

endmodule

module data_rx_2bytes_2RGB(
	input wire in_clk, in_nrst,
	input wire [7:0] in_data,
	input wire [7:0] pwm_value,
	
	output reg last_phase_strobe,
	output reg alrst_strobe,
	output reg lat_strobe,
	output reg led_clk,
	output reg [2:0] rgb1, rgb2
);

	reg [1:0] cur_phase;
	
	reg tmp_led_clk;
	always @(posedge in_clk)
	begin
		last_phase_strobe <= (cur_phase == 2'b10);
		alrst_strobe <= (cur_phase == 2'b10);
		lat_strobe <= (cur_phase == 2'b10);
		tmp_led_clk <= (cur_phase == 2'b11);
	end

	always @(negedge in_clk)
		led_clk <= tmp_led_clk;

	reg [15:0] in_data_buffer;
	always @(posedge in_clk)
		if (cur_phase[0])
			in_data_buffer [15:8] <= in_data;
		else
			in_data_buffer [7:0] <= in_data;
		
	always @(posedge in_clk)
	begin
		if (~in_nrst)
			cur_phase <= 2'b00;
		else
			cur_phase <= cur_phase + 1;
	end
	
	wire [2:0] tmp_rgb;
	color_comparator_rgb555 comparator_inst0(in_data_buffer, pwm_value[4:0], tmp_rgb[0], tmp_rgb[1], tmp_rgb[2]);
	
	always @(posedge in_clk or negedge in_nrst)
	begin
		if (~in_nrst)
		begin
			rgb1 <= 3'b000;
			rgb2 <= 3'b000;
		end
		else
		begin
			if (~cur_phase[0])
				if (cur_phase[1])
					rgb2 <= tmp_rgb;
				else
					rgb1 <= tmp_rgb;
		end
	end

endmodule

module color_comparator_rgb555 (
	input wire [15:0] in_color,
	input wire [4:0] in_value,
	output reg r, g, b
);

	always @(in_color or in_value)
	begin
		r = in_color [14:10] > in_value;
		g = in_color [9:5] > in_value;
		b = in_color [4:0] > in_value;
	end
endmodule
