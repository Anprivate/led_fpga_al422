module data_rx_3bytes_1RGB(
	input wire in_clk, in_nrst,
	input wire [7:0] in_data,
	input wire [7:0] pwm_value,
	
//		lat_strobe, pix_cntr_strobe, row_cntr_strobe, alrst_strobe, 
	output wire lat_strobe,
	output wire pix_cntr_strobe,
	output wire row_cntr_strobe,
	output wire pwm_cntr_strobe,
	output wire alrst_strobe,
	output wire led_clk,
	output reg [2:0] rgb1, rgb2
);

	reg [2:0] phase_reg;
	
	assign led_clk = phase_reg[2];
	assign lat_strobe = phase_reg[2];
	assign pix_cntr_strobe = phase_reg[1];
	assign row_cntr_strobe = phase_reg[1];
	assign pwm_cntr_strobe = phase_reg[0];
	assign alrst_strobe = phase_reg[1];
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			phase_reg <= 3'b001;
		else
			phase_reg <= {phase_reg[1:0],phase_reg[2]};

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
			rgb2 <= 3'b0;
		end
		
endmodule
