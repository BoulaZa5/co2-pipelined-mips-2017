module mux4to1 (input [1:0] selCh, input [31:0] inCh0, input [31:0] inCh1, input [31:0] inCh2, input [31:0] inCh3, output [31:0] selData);

	assign selData = selCh == 2'b00 ? inCh0 : 
                     selCh == 2'b01 ? inCh1 :
                     selCh == 2'b10 ? inCh2 :
                     selCh == 2'b11 ? inCh3 : 32'bx;

endmodule

module mux4to1_tb;

	reg selCh;
	reg [31:0] inCh0;
	reg [31:0] inCh1;
	reg [31:0] inCh2;
	reg [31:0] inCh3;
	wire [31:0] selData;

	initial begin

		$monitor ("selCh:%d inCh0:%d inCh1:%d selData:%d", selCh, inCh0, inCh1, selData);

		#10 selCh = 0; inCh0 = 102; inCh1 = 15; inCh2 = 19; inCh3 = 28;
		#10 selCh = 1; inCh2 = 239;
		#10 inCh0 = 53;
		#10 selCh = 2;
		#10 inCh1 = 77; inCh3 = 238;
		#10 selCh = 0;
		#10 selCh = 3;

	end

	mux4to1 m1 (selCh, inCh0, inCh1, inCh2, inCh3, selData);

endmodule
