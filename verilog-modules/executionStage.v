module executionStage (input clk,input [135:0]IDEXReg,input [70:0]MEMWBReg, output reg [74:0]EXMEMReg);
	
	wire [31:0]instruction=IDEXReg[31:0];
	wire signed [31:0]readData1=IDEXReg[63:32];
 	wire signed [31:0]readData2=IDEXReg[95:64]; 
	wire signed [31:0]immediateExtendedField=IDEXReg[127:96];	
	wire [7:0]controlSignals=IDEXReg[135:128];
	
	wire [5:0]funct=instruction[5:0];
	wire [4:0]shiftAmt=instruction[10:6];
	wire [4:0]ID_EXRegisterRd=instruction[15:11];
	wire [4:0]ID_EXRegisterRt=instruction[20:16];
	wire [4:0]ID_EXRegisterRs=instruction[25:21];
	wire EX_MEMRegWrite=EXMEMReg[74];
	wire [4:0]EX_MEMRegisterRd=EXMEMReg[68:64];
	wire MEM_WBRegWrite=MEMWBReg[37];
	wire [4:0]MEM_WBRegisterRd=MEMWBReg[36:32];
	wire [31:0]MEM_WBMemResult=MEMWBReg[31:0];
	wire [31:0]MEM_WBALUResult=MEMWBReg[69:38];
	wire MEM_WBMemToReg=MEMWBReg[70];

	wire RegWrite=controlSignals[0];
	wire ALUSrc=controlSignals[1];
	wire MemWrite=controlSignals[2];
	wire [1:0]ALUOp=controlSignals[4:3];
	wire MemToReg=controlSignals[5];
	wire MemRead =controlSignals[6];
	wire RegDst=controlSignals[7];
	
	wire [3:0]ALUcontrolSignal;
	wire signed [31:0]ALUFirstOperand ;
	wire signed [31:0]ALUSecondOperand ;
	wire [4:0]writeRegister;
	wire signed [31:0]ALUResult;
	wire signed [31:0]ALUMuxFirstOperand;
	wire overflowFlag;
	wire ALUZeroflag;
	
	wire [1:0]forwardA;
	wire [1:0]forwardB;
	
	mux4to1 FowardingMuxA( forwardA, readData1, MEM_WBMemResult, EXMEMReg[31:0], MEM_WBALUResult, ALUFirstOperand);
	mux4to1 FowardingMuxB( forwardB, readData2, MEM_WBMemResult, EXMEMReg[31:0], MEM_WBALUResult, ALUMuxFirstOperand);
	mux ALUMux ( ALUSrc , ALUMuxFirstOperand , immediateExtendedField , ALUSecondOperand); 
	ALUcontrol alucontrol(funct, ALUOp ,ALUcontrolSignal);
	alu exeAlu ( ALUFirstOperand , ALUSecondOperand , ALUcontrolSignal, shiftAmt ,ALUResult, overflowFlag ,  ALUZeroflag );
	mux5bits WriteRegisterMux (RegDst , ID_EXRegisterRt , ID_EXRegisterRd , writeRegister);
	ExeForwardingUnit forwardunit( EX_MEMRegWrite, EX_MEMRegisterRd, ID_EXRegisterRs, ID_EXRegisterRt, MEM_WBRegWrite, MEM_WBMemToReg, MEM_WBRegisterRd, forwardA, forwardB);
	always @(posedge clk)
		EXMEMReg={RegWrite,MemWrite,MemToReg,MemRead,overflowFlag,ALUZeroflag,writeRegister,ALUMuxFirstOperand,ALUResult};



endmodule


module executionTest();
reg signed[135:0]IDEXReg;reg signed[37:0]MEMWBReg;
wire [74:0]EXMEMReg;reg clk=0;
always
#5clk=!clk;

initial
begin
$monitor($time,"result=%d data2=%d writeReg=%d zeroFlag=%d OVRFFlag=%d MemRead=%d MemToReg=%d MemWrite=%d RegWrite=%d rs=%d forwardDatafromMEM=%d",$signed(EXMEMReg[31:0]),EXMEMReg[63:32],EXMEMReg[68:64],EXMEMReg[69],EXMEMReg[70],EXMEMReg[71],EXMEMReg[72],EXMEMReg[73],EXMEMReg[74],IDEXReg[25:21],MEMWBReg[31:0]);
// make memWBrd $s2 and its data =165 with MemWB.regwrite=1
MEMWBReg[31:0]=165;
MEMWBReg[36:32]=18;
MEMWBReg[37]=1; 
// add instruction with rs has the same memWBrd=$s2 then forwarding from mem to alu at branch A
#10
IDEXReg[31:0]=32'h02538820;//instruction add $s1,$s2,$s3
IDEXReg[63:32]=5;//data1
IDEXReg[95:64]=10;//data2
IDEXReg[127:96]=10;//immediate extended
IDEXReg[135:128]=8'b10010001;//control for R-format
// add instruction with rt has the same ExEMemrd=$s1 then forwarding from alu to alu at branch B
#10
IDEXReg[31:0]=32'h02519820;//instruction add $s3,$s2,$s1
IDEXReg[63:32]=-15;//data1
IDEXReg[95:64]=7;//data2
IDEXReg[127:96]=10;//immediate extended
IDEXReg[135:128]=8'b10010001;//control for R-format
MEMWBReg[31:0]=189;
MEMWBReg[36:32]=17;
MEMWBReg[37]=1;
// sub instruction with rt has the same ExEMemrd=$s3 then forwarding from alu to alu at branch B
#10
IDEXReg[31:0]=32'h02538822;//instruction sub $s1 $s2 $s3
IDEXReg[63:32]=5;//data1
IDEXReg[95:64]=7;//data2
IDEXReg[127:96]=10;//immediate extended
IDEXReg[135:128]=8'b10010001;//control for R-format
// trivial sub instruction with rs=5 and rt=7 depends on the previous data but there no forwarding
#10
IDEXReg[31:0]=32'h02538822;
MEMWBReg[31:0]=111;
MEMWBReg[36:32]=22;
MEMWBReg[37]=1;
#10
// farwarding from mem to alu (rs)
IDEXReg[31:0]=32'h02CB6825;//instruction OR $t5 $s6 $t3
IDEXReg[63:32]=13;//data1
IDEXReg[95:64]=9;//data2
IDEXReg[127:96]=9;//immediate extended
IDEXReg[135:128]=8'b10010001;//control for R-format
MEMWBReg[31:0]=111;
MEMWBReg[36:32]=22;
MEMWBReg[37]=1;
// trivial sub 13-9
#10
IDEXReg[31:0]=32'h02518822;//instruction sub $s1 $s2 $s1
IDEXReg[63:32]=13;//data1
IDEXReg[95:64]=9;//data2
IDEXReg[127:96]=9;//immediate extended
IDEXReg[135:128]=8'b10010001;//control for R-format
// trivial sll 10 by 2
#10
IDEXReg[31:0]=32'h00114880;//instruction sll $t1,$s1,2
IDEXReg[63:32]=10;//data1
IDEXReg[95:64]=9;//data2
IDEXReg[127:96]=9;//immediate extended
IDEXReg[135:128]=8'b10010001;//control for R-format
// lw data1+immediate
#10
IDEXReg[31:0]=32'h8e510064;//instruction lw $s1, 100($s2)
IDEXReg[63:32]=16;//data1
IDEXReg[95:64]=9;//data2
IDEXReg[127:96]=-16;//immediate extended
IDEXReg[135:128]=8'b01100011;//control for lw
end





executionStage exe(clk,IDEXReg,MEMWBReg, EXMEMReg);
endmodule
