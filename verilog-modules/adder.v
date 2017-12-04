module adder (input signed [31:0] in1, input signed [31:0] in2, output signed [31:0] result);


	assign result = in1 + in2;
	

endmodule

module adder_tb;

	reg signed [31:0] in1;
	reg signed [31:0] in2;
	wire signed [31:0] result;

	initial begin

		$monitor ("%d + %d = %d", in1, in2, result);

		#10 in1 = -5; in2 = -7;
		#10 in1 = -5; in2 = 7;
		#10 in1 = 5; in2 = -7;
		#10 in1 = 2147483648; in2 = 2147483648;
		#10 in1 = 19; in2 = 20;
		#10 in1 = 12;
		#10 in2 = -3;

	end

	adder add1 (in1, in2, result);

endmodule

