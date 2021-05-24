`include"rrArbiter_synthesized.v"

module tb();
	reg clk, rst;
	reg[7:0] a, b, c, d;
	wire[7:0] out;
	arbiter arbiter(a, b, c,d, clk, rst, out);
	initial begin
		$dumpfile("arbiter.vcd");
		$dumpvars(0, tb);
		rst = 1'b0;
		clk = 1'b1;
		#2 rst=~rst;
		#2 rst =~rst;
		#1 clk = ~clk;
		forever #5 clk = ~clk;
		
			
	end
	
	initial begin
	a = 7'd10;
	b = 7'd26;
	c = 7'd14;
	d = 7'd9;
	#100 $finish;
	end


endmodule
