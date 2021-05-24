module arbiter(input a, b, c, d, input clk, rst,
		output reg out);
	reg[1:0] counter;
	initial begin
	counter=2'b00;
	end
	//Instantiating a counter
	always@(posedge clk) begin
		begin
		counter<=counter+1'b1;
		end
	end	
	always@(posedge clk) begin
		
		case(counter) 
			2'b00: out<=a;
			2'b01: out<=b;
			2'b10: out<=c;
			2'b11: out<=d;
			default: out<=1'd0;
		endcase
	end
	
endmodule
