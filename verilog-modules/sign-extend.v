module signextend1632 (input [15:0] in, output [31:0] extended);

	assign extended = { {16 { in[15]}}, in[15:0] };

endmodule

module signextend1632_tb;

	reg [15:0] in;
	wire [31:0] extended;

	initial begin

		$monitor ("in=%b extended=%b", in, extended);

		#10 in = 5;
		#10 in = -19;
		#10 in = -93;
		#10 in = 25;

	end

	signextend1632 se1 (in, extended);

endmodule
