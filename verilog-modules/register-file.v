module registerFile (input wrEnable, input [4:0] wrReg, input [31:0] wrData, input [4:0] rdReg1, output [31:0] rdData1, input [4:0] rdReg2, output [31:0] rdData2, input clk);

	reg [31:0] regFile [0:31];

	assign rdData1 = regFile[rdReg1];
	assign rdData2 = regFile[rdReg2];

	always @(negedge clk)
		if (wrEnable)
			regFile[wrReg] <= wrData;
initial   regFile[0] <= 32'h 0;
endmodule

module registerFile_tb;

	reg wrEnable;
	reg [4:0] wrReg;
	reg [31:0] wrData;
	reg [4:0] rdReg1;
	wire [31:0] rdData1;
	reg [4:0] rdReg2;
	wire [31:0] rdData2;
	reg clk;

	integer index;

	always begin #5 clk = ~clk; end

	initial begin

		// $monitor ("clk:%d en:%d wrReg:%d wrData:%d rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", clk, wrEnable, wrReg, wrData, rdReg1, rdData1, rdReg2, rdData2);

		clk = 0;

		wrEnable = 1;
		//for (index = 0; index < 32; index = index + 1) begin #10 wrReg = index; wrData = index * 2; $display ("wrReg:%d wrData:%d", wrReg, wrData); end
		//#10 wrEnable = 0; wrReg = 31; wrData = 93;

		#10 rdReg1 = 0; rdReg2 = 1; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 2; rdReg2 = 3; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 4; rdReg2 = 5; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 6; rdReg2 = 7; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 8; rdReg2 = 9; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 10; rdReg2 = 11; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 12; rdReg2 = 13; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 14; rdReg2 = 15; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 16; rdReg2 = 17; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 18; rdReg2 = 19; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 20; rdReg2 = 21; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 22; rdReg2 = 23; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 24; rdReg2 = 25; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 26; rdReg2 = 27; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 28; rdReg2 = 29; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);
		#10 rdReg1 = 30; rdReg2 = 31; #2 $display ("rdReg1:%d rdData1:%d rdReg2:%d rdData2:%d", rdReg1, rdData1, rdReg2, rdData2);

	end

	registerFile regFile1 (wrEnable, wrReg, wrData, rdReg1, rdData1, rdReg2, rdData2, clk);

endmodule