module NOT (input A, output Y);
	assign Y = ~A;
endmodule
module BUF (input A, output Y);
	assign Y = A;
endmodule
module NOR (input A,B, output Y);
	assign Y = ~(A|B);
endmodule
module NAND (input A,B, output Y);
	assign Y = ~(A&B);
endmodule
module DFF (input C,D, output reg Q);
	always @(posedge C)  begin
		Q<=D;
	end
endmodule
