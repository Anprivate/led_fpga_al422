module data_rx_3bytes_1RGB(
	input wire in_clk, in_nrst,
	input wire [7:0] in_data,
	input wire [7:0] pwm_value,
	
	output wire led_clk,
	output wire pwm_cntr_strobe,
	output wire alrst_strobe,
	output reg [2:0] rgb1, rgb2
);

	reg [1:0] phase_cntr;
	wire [2:0] phase_reg;
	assign phase_reg[0] = (phase_cntr == 2'b00);
	assign phase_reg[1] = (phase_cntr == 2'b01);
	assign phase_reg[2] = (phase_cntr == 2'b10);

	assign led_clk = phase_reg[2];
	assign pwm_cntr_strobe = phase_reg[0];
	assign alrst_strobe = phase_reg[1];
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			phase_cntr <= 2'b00;
		else
			if (phase_cntr == 2'b10)
				phase_cntr <= 2'b00;
			else
				phase_cntr <= phase_cntr + 1;

	// in_data_buffer
	reg [7:0] in_data_buffer;
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			in_data_buffer <= 8'h00;
		else
			in_data_buffer <= in_data;
			
	reg comparator_out;

	reg tmp_high, tmp_low, tmp_eq;
	
	wire high_comp;
	assign high_comp = (in_data_buffer [7:4] > pwm_value [7:4]);
	
	wire high_eq;
	assign high_eq = (in_data_buffer [7:4] == pwm_value [7:4]);
	
	wire low_comp;
	assign low_comp = (in_data_buffer [3:0] > pwm_value [3:0]);
		
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
		begin
			tmp_high <= 1'b0;
			tmp_low <= 1'b0;
			tmp_eq <= 1'b0;
			comparator_out <= 1'b0;
		end
		else
		begin
			tmp_high <= high_comp;
			tmp_low <= low_comp;
			tmp_eq <= high_eq;
	
			comparator_out <= (tmp_high | (tmp_eq & tmp_low));
		end
	
	reg [2:0] tmp_rgb;
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			tmp_rgb <= 3'b0;
		else
			tmp_rgb <= {tmp_rgb[1:0],comparator_out};

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
		begin
			rgb1 <= 3'b0;
			rgb2 <= 3'b0;
		end
		else
		begin
			if (phase_reg[0])
				rgb1 <= tmp_rgb;
			rgb2 <= 3'b0;
		end
		
endmodule
