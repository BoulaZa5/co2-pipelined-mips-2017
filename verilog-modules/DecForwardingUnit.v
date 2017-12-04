
module diForwardingUnit (input [4:0] regFileReadReg1, input [4:0] regFileReadReg2, input [5:0] operation, input EXMEregwrite,input EXMEmemtoreg, input [4:0] EXMEWriteReg, output reg regFileRead1MuxSignal, output reg regFileRead2MuxSignal);

	parameter beqOperation = 6'b000100;
		 // nofrwrd = 2'b00,
			//  frwrdFromEXMEM = 2'b01,
			//  frwrdFromMEMWB = 2'b10;

	//reg frwrdReg1;
	//reg frwrdReg1Data;
	//reg frwrdReg2;
	//reg frwrdReg2Data;

	initial begin regFileRead1MuxSignal = 0 ;  regFileRead2MuxSignal = 0; end

	always @(*) begin

		if (regFileReadReg1 == EXMEWriteReg && operation == beqOperation && EXMEregwrite == 1'b1 && EXMEmemtoreg == 0) begin
			regFileRead1MuxSignal <=1;
		end
		else regFileRead1MuxSignal <= 0;

		if (regFileReadReg2 == EXMEWriteReg && operation == beqOperation && EXMEregwrite == 1'b1 && EXMEmemtoreg == 0 ) begin
			regFileRead2MuxSignal <=1;
		end

		else regFileRead2MuxSignal <= 0;

		//regFileRead1MuxSignal <= {frwrdReg1, frwrdReg1Data};
//		regFileRead2MuxSignal <= {frwrdReg2, frwrdReg2Data};

	end

endmodule

module diForwardingUnit_tb ();

	reg [4:0] regFileReadReg1;
	reg [4:0] regFileReadReg2;
	reg [5:0] operation;
	reg EXMEWriteSignal;
	reg EXMEmemtoreg;
	reg [4:0] EXMEWriteReg;
	//reg MEWBWriteSignal;
	//reg [4:0] MEWBWriteReg;
	wire  regFileRead1MuxSignal;
	wire  regFileRead2MuxSignal;

	initial begin

		$monitor("regFileRead1MuxSignal: %b regFileRead2MuxSignal: %b when regFileReadReg1: %d regFileReadReg2: %d operation: %b EXMEWriteSignal: %b EXMEWriteReg: %d EXMEmemtoreg : %d", regFileRead1MuxSignal, regFileRead2MuxSignal, regFileReadReg1, regFileReadReg2, operation, EXMEWriteSignal, EXMEWriteReg, EXMEmemtoreg);

		regFileReadReg1 = 5'd0; regFileReadReg2 = 5'd1; operation = 6'b000100; EXMEWriteSignal = 1; EXMEWriteReg = 5'd0; EXMEmemtoreg = 0 ;

		#10 regFileReadReg1 = 5'd12; regFileReadReg2 = 5'd9;
		#10 EXMEWriteReg = 5'd9;
		#10 EXMEWriteSignal = 0;
		//#10 MEWBWriteReg = 5'd12;
		//#10 MEWBWriteSignal = 0;
		#10 EXMEWriteSignal = 1; //MEWBWriteSignal = 1;
		#10 operation = 6'b000000;

	end

	diForwardingUnit diFU1 (regFileReadReg1, regFileReadReg2, operation, EXMEWriteSignal,EXMEmemtoreg, EXMEWriteReg, regFileRead1MuxSignal, regFileRead2MuxSignal);

endmodule
