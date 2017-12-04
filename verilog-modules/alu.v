module alu (input signed [31:0] in1, input signed [31:0] in2, input [3:0] opCode, input [4:0] shiftAmt, output signed [31:0] result, output overflow, output zero);

	parameter AND = 4'b0000,
		  OR  = 4'b0001,
		  ADD = 4'b0010,
		  SUB = 4'b0110,
		  SLL = 4'b0100,
		  SRL = 4'b0101,
		  SLT = 4'b0111,
		  NOR = 4'b1100,

		  TRUE   = 1'b1,
		  FALSE  = 1'b0;

	assign result = opCode == ADD ? in1 + in2 :
			opCode == SUB ? in1 - in2 :
			opCode == AND ? in1 & in2 :
			opCode == OR  ? in1 | in2 :
			opCode == SLL ? in2 << shiftAmt :
			opCode == SRL ? in2 >> shiftAmt :
			opCode == SLT ? in1 < in2 ? TRUE : FALSE :
			opCode == NOR ? ~(in1 | in2) : 0;

	assign overflow = opCode == ADD ? (in1[31] == in2[31] && result[31] != in1[31]) ? TRUE : FALSE :
			  opCode == SUB ? (in1[31] != in2[31] && result[31] != in1[31]) ? TRUE : FALSE : FALSE;

	assign zero = result == 0 ? TRUE : FALSE;

endmodule

module alu_tb;

	reg signed [31:0] in1;
	reg signed [31:0] in2;
	reg [3:0] opCode;
	reg [4:0] shiftAmt;
	wire signed [31:0] result;
	wire overflow;
	wire zero;

	parameter AND = 4'b0000,
		  OR  = 4'b0001,
		  ADD = 4'b0010,
		  SUB = 4'b0110,
		  SLL = 4'b0100,
		  SRL = 4'b0101,
		  SLT = 4'b0111,
		  NOR = 4'b1100;

	initial begin

		// $monitor ("in1:%d in2:%d opCode:%d shiftAmt:%d result:%d", in1, in2, opCode, shiftAmt, result);
		$monitor ("result = %d!", zero);

		shiftAmt = 0;
		#10 opCode = ADD; in1 = 5; in2 = 7; #2 $display ("%d + %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = -5; in2 = -7; #2 $display ("%d + %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = -5; in2 = 7; #2 $display ("%d + %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 5; in2 = -7; #2 $display ("%d + %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 2147483647; in2 = 2147483647; #2 $display ("%d + %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = -2147483647; in2 = -2147483647; #2 $display ("%d + %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 32'h80000000; in2 = 32'h80000000; #2 $display ("%d + %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 32'h80000000-1; in2 = 3; #2 $display ("%d + %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 32'h80000000; in2 = -1; #2 $display ("%d + %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 32'h80000000-1; in2 = -9; #2 $display ("%d + %d = %d with overflow = %d", in1, in2, result, overflow);

		#10 opCode = SUB; in1 = 5; in2 = 7; #2 $display ("%d - %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = -5; in2 = -7; #2 $display ("%d - %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = -5; in2 = 7; #2 $display ("%d - %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 5; in2 = -7; #2 $display ("%d - %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 2147483647; in2 = -2147483648; #2 $display ("%d - %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = -2147483648; in2 = 2147483647; #2 $display ("%d - %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 32'h80000000; in2 = 32'h80000000; #2 $display ("%d - %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 32'h80000000-1; in2 = -3; #2 $display ("%d - %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 32'h80000000; in2 = -1; #2 $display ("%d - %d = %d with overflow = %d", in1, in2, result, overflow);
		#10 in1 = 32'h80000000-1; in2 = -9; #2 $display ("%d - %d = %d with overflow = %d", in1, in2, result, overflow);

		#10 opCode = AND; in1 = 1; in2 = 1; #2 $display ("%d & %d = %d", in1, in2, result);
		#10 in2 = 0; #2 $display ("%d & %d = %d", in1, in2, result);
		#10 in1 = 0; #2 $display ("%d & %d = %d", in1, in2, result);
		#10 in2 = 1; #2 $display ("%d & %d = %d", in1, in2, result);

		#10 opCode = OR; in1 = 1; #2 $display ("%d | %d = %d", in1, in2, result);
		#10 in2 = 0; #2 $display ("%d | %d = %d", in1, in2, result);
		#10 in1 = 0; #2 $display ("%d | %d = %d", in1, in2, result);
		#10 in2 = 1; #2 $display ("%d | %d = %d", in1, in2, result);

		#10 opCode = SLL; in1 = 1; shiftAmt = 1; #2 $display ("%b << %d = %b", in1, shiftAmt, result);
		#10 in1 = 2; shiftAmt = 2; #2 $display ("%b << %d = %b", in1, shiftAmt, result);
		#10 in1 = 4; shiftAmt = 3; #2 $display ("%b << %d = %b", in1, shiftAmt, result);
		#10 in1 = 8; shiftAmt = 4; #2 $display ("%b << %d = %b", in1, shiftAmt, result);

		#10 opCode = SRL; in1 = 16; shiftAmt = 1; #2 $display ("%b >> %d = %b", in1, shiftAmt, result);
		#10 in1 = 2; #2 $display ("%b >> %d = %b", in1, shiftAmt, result);
		#10 in1 = 4; shiftAmt = 3; #2 $display ("%b >> %d = %b", in1, shiftAmt, result);
		#10 in1 = 8; shiftAmt = 4; #2 $display ("%b >> %d = %b", in1, shiftAmt, result);
		#10 in1 = -16; shiftAmt = 1; #2 $display ("%b >> %d = %b", in1, shiftAmt, result);

		#10 opCode = SLT; in1 = 16; in2 = 7; #2 $display ("%d < %d = %d", in1, in2, result);
		#10 in1 = -16; in2 = -7; #2 $display ("%d < %d = %d", in1, in2, result);
		#10 in1 = -16; in2 = 7; #2 $display ("%d < %d = %d", in1, in2, result);
		#10 in1 = 16; in2 = -7; #2 $display ("%d < %d = %d", in1, in2, result);

		#10 opCode = NOR; in1 = 1; in2 = 1; #2 $display ("%d & %d = %d", in1, in2, result);
		#10 in2 = 0; #2 $display ("%d & %d = %d", in1, in2, result);
		#10 in1 = 0; #2 $display ("%d & %d = %d", in1, in2, result);
		#10 in2 = 1; #2 $display ("%d & %d = %d", in1, in2, result);

	end

	alu alu1 (in1, in2, opCode, shiftAmt, result, overflow, zero);

endmodule
