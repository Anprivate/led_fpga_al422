module color_comparator_rgb565 (
	input wire [15:0] in_color,
	input wire [5:0] in_value,
	output reg r, g, b
);

	always @(in_color or in_value)
	begin
		r = in_color [15:11] > in_value[5:1];
		g = in_color [10:5] > in_value;
		b = in_color [4:0] > in_value[5:1];
	end
endmodule
