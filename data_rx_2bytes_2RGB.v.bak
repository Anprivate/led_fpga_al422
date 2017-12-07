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
