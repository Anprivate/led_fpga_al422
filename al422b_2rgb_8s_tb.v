`timescale 1 ps/ 1 ps
module al422b_2rgb_8s_vlg_tst();
// test vector input registers
reg in_clk;
reg [15:0] address;
reg [8:0] memory [0:8191];
reg in_nrst;
// wires                                               
wire al422_nrst;
wire cntr_nrst;
wire led_clk_out;
wire led_lat_out;
wire led_oe_out;
wire [4:0]  led_row;
wire [2:0]  rgb1;
wire [2:0]  rgb2;

wire [7:0] memory_out;

assign memory_out = memory[address];
assign cntr_nrst = al422_nrst & in_nrst;

led_al422_main i1 (
// port map - connection between master ports and signals/registers   
	.al422_nrst(al422_nrst),
	.in_clk(in_clk),
	.in_data(memory_out),
	.in_nrst(in_nrst),
	.led_clk_out(led_clk_out),
	.led_lat_out(led_lat_out),
	.led_oe_out(led_oe_out),
	.led_row(led_row),
	.rgb1(rgb1),
	.rgb2(rgb2)
);

integer j;

initial
begin
	for (j=6; j < 8192; j=j+1)
	begin
		memory[j] <= 8'h00; //reset array
   end

	memory[0] <= 8'hF3;
	memory[1] <= 8'hF4;
	memory[2] <= 8'hF5;
	memory[3] <= 8'h80;
	memory[4] <= 8'h81;
	memory[5] <= 8'h82;
	
	in_nrst = 0;
	in_clk = 0;                                                       
	address = 0;
	#15 in_nrst = 1;
	#2000000 $stop;
end                                                    

always                                                 
  #10 in_clk = ~in_clk;
  
always @ (posedge in_clk)
	if (~cntr_nrst)
		address <= 16'h0;
	else
		address <= address + 16'h1;
endmodule

