module data_rx_3bytes_2RGB(
	input wire in_clk, in_nrst,
	input wire [7:0] in_data,
	input wire [7:0] pwm_value,
	
	output wire led_clk,
	output wire pwm_cntr_strobe,
	output wire alrst_strobe,
	output reg [2:0] rgb1, rgb2
);

	reg [2:0] phase_cntr;
	wire [5:0] phase_reg;
	assign phase_reg[0] = (phase_cntr == 3'h0);
	assign phase_reg[1] = (phase_cntr == 3'h1);
	assign phase_reg[2] = (phase_cntr == 3'h2);
	assign phase_reg[3] = (phase_cntr == 3'h3);
	assign phase_reg[4] = (phase_cntr == 3'h4);
	assign phase_reg[5] = (phase_cntr == 3'h5);

	assign led_clk = phase_reg[5];
	assign pwm_cntr_strobe = phase_reg[0];
	assign alrst_strobe = phase_reg[4];
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			phase_cntr <= 3'h0;
		else
			if (phase_cntr == 3'h5)
				phase_cntr <= 3'h0;
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

	reg [3:0] tmp_reg_buffer, tmp_reg_pwm;
	reg tmp_carry;
	
	wire first_stage_out;
	assign first_stage_out = (in_data_buffer [7:4] > pwm_value [7:4]);
	
	wire second_stage_out;
	assign second_stage_out = (tmp_reg_buffer > tmp_reg_pwm);
		
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
		begin
			tmp_reg_buffer <= 4'h0;
			tmp_reg_pwm <= 4'h0;
			tmp_carry <= 1'b0;
			comparator_out <= 1'b0;
		end
		else
		begin
			tmp_reg_buffer <= in_data_buffer[3:0];
			tmp_reg_pwm <= pwm_value [3:0];
			tmp_carry <= first_stage_out;
	
			comparator_out <= tmp_carry | second_stage_out;
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
			if (phase_reg[3])
				rgb2 <= tmp_rgb;
		end
		
endmodule
