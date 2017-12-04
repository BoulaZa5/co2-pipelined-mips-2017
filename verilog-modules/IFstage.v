module instructionFetch (input branchResult, input [31:0] branchAddrs, input regStall, input muxStall, output reg [63:0] instructionFetchReg, input clk);

	wire [31:0] adderAddrs;
	wire [31:0] pcInput;
	wire [31:0] pcOutput;
	wire [31:0] instruction;
	wire [9:0] instructionAddress = pcOutput >> 2;
	wire [1:0] muxSelection;

	initial instructionFetchReg = { 64 {1'b0} };

	assign muxSelection = {muxStall, branchResult};

	mux4to1 addrsMux1(muxSelection, adderAddrs, branchAddrs, pcOutput, pcOutput, pcInput);
	PC pc1 (pcOutput, pcInput, clk);
	insMemory im1 (instructionAddress, instruction);
	adder adder1 (pcOutput, 32'd4, adderAddrs);

	always @(posedge clk)
	begin
		if (regStall == 1);
		else begin
			if (branchResult) instructionFetchReg <= {{32 {1'b0}},adderAddrs};
			else instructionFetchReg <= {instruction, adderAddrs};
		end
	end

endmodule

module instructionFetch_tb ();

	reg branchResult;
	reg [31:0] branchAddrs;
	reg muxStall;
	reg regStall;
	wire [63:0] instructionFetchReg;
	reg clk;
	
	always begin #5 clk = ~clk; end

	initial begin

		$monitor ("instructionFetchReg:%h branchResult: %b branchAddrs : %d muxStall: %b", instructionFetchReg, branchResult, branchAddrs, muxStall);

		branchResult = 0; branchAddrs = { 32 {1'b0} }; regStall = 0; muxStall = 0; clk = 0;
		#28 branchResult = 0; branchAddrs = 32'd7; muxStall = 1;
		#5 branchResult = 1;
		#5 branchResult = 0;
		#90
		#22 muxStall = 0;
		#28 branchResult = 0; branchAddrs = 32'd3; muxStall = 1;
		#22 muxStall = 0;

	end

	instructionFetch if1(branchResult, branchAddrs, regStall, muxStall, instructionFetchReg, clk);

endmodule
