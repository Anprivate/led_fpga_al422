`timescale 1 ps/ 1 ps
module al422b_2rgb_8s_vlg_tst();
// test vector input registers
reg in_clk;
reg [15:0] address;
reg in_nrst;
// wires                                               
wire al422_nrst;
wire led_clk_out;
wire led_lat_out;
wire led_oe_out;
wire [4:0]  led_row;
wire [2:0]  rgb1;
wire [2:0]  rgb2;

// assign statements (if any)                          
al422b_2rgb_8s i1 (
// port map - connection between master ports and signals/registers   
	.al422_nrst(al422_nrst),
	.in_clk(in_clk),
	.in_data(address[7:0]),
	.in_nrst(in_nrst),
	.led_clk_out(led_clk_out),
	.led_lat_out(led_lat_out),
	.led_oe_out(led_oe_out),
	.led_row(led_row),
	.rgb1(rgb1),
	.rgb2(rgb2)
);
initial                                                
begin                                                  
	in_nrst = 1;
	in_clk = 0;                                                       
	address = 0;
	#50 in_nrst = 0;
	#50 in_nrst = 1;
	#2000000 $stop;
end                                                    

always                                                 
  #10 in_clk = ~in_clk;
  
always @ (posedge in_clk)
	if (~al422_nrst)
		address <= 16'b00000000;
	else
		address <= address + 16'b00000001;
endmodule

