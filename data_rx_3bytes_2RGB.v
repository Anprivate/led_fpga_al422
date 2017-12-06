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
