module data_rx_2bytes_2RGB(
	input wire in_clk, in_nrst,
	input wire [7:0] in_data,
	input wire [7:0] pwm_value,
	
	output wire led_clk,
	output wire pwm_cntr_strobe,
	output wire alrst_strobe,
	output reg [2:0] rgb1, rgb2
);

	reg [1:0] phase_cntr;
	wire [3:0] phase_reg;
	
	assign phase_reg[0] = (phase_cntr == 2'h0);
	assign phase_reg[1] = (phase_cntr == 2'h1);
	assign phase_reg[2] = (phase_cntr == 2'h2);
	assign phase_reg[3] = (phase_cntr == 2'h3);

	assign led_clk = phase_reg[2];
	assign pwm_cntr_strobe = phase_reg[1];
	assign alrst_strobe = phase_reg[2];

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			phase_cntr <= 2'h0;
		else
			phase_cntr <= phase_cntr + 2'h1;
	
	reg [15:0] in_data_buffer;
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			in_data_buffer <= 16'h0000;
		else
		begin
			in_data_buffer [15:8] <= in_data;
			in_data_buffer [7:0] <= in_data_buffer [15:8];
		end
		
	wire [2:0] tmp_rgb;
	color_comparator_rgb555 comparator_inst0(in_data_buffer, pwm_value[4:0], tmp_rgb[0], tmp_rgb[1], tmp_rgb[2]);
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
		begin
			rgb1 <= 3'b000;
			rgb2 <= 3'b000;
		end
		else
		begin
			if (phase_reg[2])
					rgb1 <= tmp_rgb;
			if (phase_reg[0])
					rgb2 <= tmp_rgb;
		end

endmodule
