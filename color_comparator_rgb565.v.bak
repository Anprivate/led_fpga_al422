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
