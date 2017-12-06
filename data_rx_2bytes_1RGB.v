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
