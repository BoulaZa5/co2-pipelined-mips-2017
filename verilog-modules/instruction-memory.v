module insMemory (input [9:0] rdAddress, output [31:0] rdIns);

	reg [31:0] insFile [0:1023];

	assign rdIns = insFile[rdAddress];

	initial
		$readmemh("instructions.ins", insFile, 0);

endmodule

module insMemory_tb;

	reg [9:0] rdAddress;
	wire [31:0] rdIns;

	initial begin

		$monitor ("rdAddress:%d rdIns:%d", rdAddress, rdIns);

		#2 rdAddress = 0;
		#2 rdAddress = 1;
		#2 rdAddress = 2;
		#2 rdAddress = 3;
		#2 rdAddress = 4;
		#2 rdAddress = 5;
		#2 rdAddress = 6;
		#2 rdAddress = 7;
        
	end

	insMemory im1 (rdAddress, rdIns);

endmodule
