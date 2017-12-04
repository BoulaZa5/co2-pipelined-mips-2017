module adder (input signed [31:0] in1, input signed [31:0] in2, output signed [31:0] result);


	assign result = in1 + in2;


endmodule

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

module ALUcontrol(input [5:0]funct,input [1:0]ALUop,output [3:0] ALU);
parameter add =32;
parameter And =36;
parameter jr =8;
parameter Nor =39;
parameter Or =37;
parameter sll =0;
parameter slt =42;
parameter srl =2;
parameter sub =34;

parameter ADD =0;
parameter SUB = 1;
parameter R_FORMAT=2;
parameter ORIop=3;

assign ALU=((funct==And)&&(ALUop==R_FORMAT))?4'b0000 : (((funct==Or)&&(ALUop==R_FORMAT))||(ALUop==ORIop))?4'b0001:((funct==add)||(ALUop==ADD))?4'b0010 :
((funct==jr)&&(ALUop==R_FORMAT))?4'b0011 :((funct==sll)&&(ALUop==R_FORMAT))?4'b0100:((funct==srl)&&(ALUop==R_FORMAT))?4'b0101:
((funct==sub)||(ALUop==SUB))?4'b0110 : ((funct==slt)&&(ALUop==R_FORMAT))?4'b0111 :((funct==Nor)&&(ALUop==R_FORMAT))?4'b1100 :4'bxxxx;
endmodule

module comparator (input [31:0] data1 , input [31:0] data2 , output reg isEqual);


initial isEqual=0;
always@(*)
begin
if(data1==data2)
isEqual=1;
else
isEqual=0;

end

endmodule

module Control(input [5:0]op,output RegDst,output Jump,output Branch,output MemRead,output MemtoReg,output [1:0]ALUOp,output MemWrite,output ALUSrc,output RegWrite);
parameter R_format=0;
parameter Beq=4;
parameter Lw=35;
parameter Sw=43;
parameter J=2;
parameter addi=8;
parameter ori=13;

assign RegDst=((op==R_format)? 1'b1 : ((op==Lw||op==addi||op==Sw||op==ori)? 1'b0 : 1'bx));
assign Jump=(op==J)? 1'b1 : 1'b0;
assign Branch=(op==Beq)? 1'b1 : (op==J)? 1'bx : 1'b0;
assign MemRead=(op==Lw)? 1'b1 : 1'b0;
assign MemtoReg=(op==R_format||op==addi||op==ori)? 1'b0:(op==Lw)? 1'b1 : 1'bx;
assign ALUOp=(op==ori)?2'b11:(op==Beq)? 2'b01 : (op==R_format)? 2'b10 : (op==J)? 2'bxx : 2'b00;
assign MemWrite=(op==Sw)? 1'b1 : 1'b0;
assign ALUSrc=(op==Lw||op==Sw||op==addi||op==ori)? 1'b1 : (op==J)? 1'bx : 1'b0;
assign RegWrite=(op==R_format||op==Lw||op==addi||op==ori)? 1'b1 : 1'b0;
endmodule

module dataMemory (input wrEnable, input [9:0] wrAddress, input [31:0] wrData, input rdEnable, input [9:0] rdAddress, output [31:0] rdData, input clk);

	reg [31:0] memFile [0:1023];

	assign rdData = rdEnable? memFile[rdAddress] : 0;

	always @(posedge clk)
        if (wrEnable) begin
			memFile[wrAddress] <= wrData;
			$display ("mem  %d  =  %d", wrAddress, wrData);
		end

endmodule


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

module DecodeandWBStages (input clk ,input [63:0]IFIDReg, input [70:0]MEMWBReg, input [74:0] EXMEReg, output reg [135:0]IDEXReg , output BranchControlSignal ,output [31:0] BranchTarget ,output pcHOLD, output   IFIDRegHOLD  );
	//IFID
	wire [31:0]PC = IFIDReg[31:0];
	wire [31:0]instruction = IFIDReg[63:32];
	wire [5:0] OPcode = instruction[31:26];
	wire [4:0] rs = instruction [25:21];
	wire [4:0] rt = instruction [20:16];
	wire [4:0] rd = instruction [15:11];
	//IDEX
	wire [4:0] IDEXRegrt = IDEXReg[20:16];
	wire [4:0] IDEXRegrd = IDEXReg[15:11];
	wire [5:0] IDEXRegOPcode=IDEXReg [31:26];
	wire IDEXmemRead = IDEXReg [134];
	wire IDEXregwrite = IDEXReg [128];
	wire IDEXregdst = IDEXReg [135];

	//EXMEM
	wire EXMEMregwrite = EXMEReg [74] ;
	wire EXMEmemtoreg = EXMEReg [72];
	wire EXMEMmemread = EXMEReg [71];
	wire [4:0] EXMERegwriteReg = EXMEReg [68:64] ;
	wire [31:0] EXMEaluResult = EXMEReg [31:0];
	//Decode stage control signals
	wire  RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
	wire [1:0]ALUOp;

	wire [31:0] extendedSignal ;
	wire [31:0] BranchShiftedaddress;
	//MEMWB
	wire MEMWBRegWriteEnable = MEMWBReg[37];
	wire [4:0]MEMWBRegWriteReg = MEMWBReg [36:32];
	wire [31:0]MEMWBRegReadData = MEMWBReg [31:0];
	wire [31:0]MEMWBRegALUresult = MEMWBReg [69:38];
	wire MEMWBRegmemtoreg= MEMWBReg [70] ;

	wire [31:0] WriteData;
	wire [31:0] readData1;
	wire [31:0] readData2;
	wire BranchEqual;

	wire [7:0] controlSignals = {RegDst,MemRead , MemtoReg, ALUOp, MemWrite , ALUSrc, RegWrite};
	//wire [7:0] IDctrlSignalsNoHazard ;

// FORWARDING
	wire [31:0] newReaddata1;
	wire [31:0] newReaddata2;
	wire  regFileRead1MuxSignal;
	wire  regFileRead2MuxSignal;

	diForwardingUnit decodeStageForwading (rs, rt, OPcode,EXMEMregwrite,EXMEmemtoreg,EXMERegwriteReg,regFileRead1MuxSignal, regFileRead2MuxSignal);
	mux forwardData1mux (regFileRead1MuxSignal,readData1,EXMEaluResult,newReaddata1);
	mux forwardData2mux (regFileRead2MuxSignal,readData2,EXMEaluResult,newReaddata2);
	/*diForwardingUnit decodeStageForwading ( rs, rt ,OPcode,IDEXReg[128],IDEXRegrt ,EXMEWriteSignal,EXMEMRegWrReg,regFileRead1MuxSignal,regFileRead2MuxSignal);
	mux3To1_5bits rsMux(regFileRead1MuxSignal, readData1,EXMEMRegWrReg,MEMWBRegWriteReg, newReaddata1);
	mux3To1_5bits rdMux(regFileRead2MuxSignal, readData2, EXMEMRegWrReg,MEMWBRegWriteReg, newReaddata1);*/

	Control DecodeStageControlUnit(OPcode, RegDst, Jump, Branch, MemRead, MemtoReg,ALUOp, MemWrite, ALUSrc, RegWrite);

	//WBstage mux
	mux WriteDataMUX (MEMWBRegmemtoreg, MEMWBRegALUresult, MEMWBRegReadData , WriteData);

	registerFile PipeliningRegisterFile( MEMWBRegWriteEnable , MEMWBRegWriteReg , WriteData , rs,readData1, rt ,readData2,  clk);

	//branch
	signextend1632 decodeStageSignExtend(instruction [15:0], extendedSignal);
	ShiftLeftBranch ShiftedBranchAddress(extendedSignal ,BranchShiftedaddress);
	adder BranchAdder (PC , BranchShiftedaddress , BranchTarget );
	comparator BranchComarator (newReaddata1 , newReaddata2 , BranchEqual);
	and Branch_selector ( BranchControlSignal , Branch , BranchEqual );

//Hazard Detection
	wire IFflush ;
	hazardDetectionUnit IDstageHazardDetect(rs ,rt ,IDEXRegrt ,IDEXRegrd ,EXMERegwriteReg,OPcode ,IDEXRegOPcode,IDEXregwrite , IDEXregdst, EXMEMregwrite , EXMEMmemread , IFIDRegHOLD , pcHOLD , IFflush);
	//hazardDetectionUnit IDstageHazardDetect(rs ,rt , IDEXRegrt , IDEXRegOPcode ,  IFIDRegHOLD ,  pcHOLD , IFflush );
	//mux8bits ControlHazardSelection (BranchControlSignal , controlSignals , 8'b0 , IDctrlSignalsNoHazard);

	always @(posedge clk )
	begin

		if(IFflush==1) IDEXReg = 136'b 0 ;
		else IDEXReg = {controlSignals,extendedSignal,newReaddata2,newReaddata1,instruction};

	end

endmodule

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

module ExeForwardingUnit(input Ex_MemRegWrite,input [4:0]Ex_MemRegisterRd,input [4:0]ID_ExRegisterRs,input [4:0]ID_ExRegisterRt,input Mem_WbRegWrite,input MEM_WBMemToReg,input [4:0]Mem_WbRegisterRd,output reg [1:0]forwardA,output reg [1:0]forwardB);
	parameter fowardfromEx_Mem=2'b10,
		  fowardMemResultfromMem_Wb=2'b01,
		  fowardALUResultfromMem_Wb=2'b11;

initial
begin
	forwardA=0;forwardB=0;
end
always@(*)
begin
if(Ex_MemRegWrite==1 && Ex_MemRegisterRd!=0 && Ex_MemRegisterRd==ID_ExRegisterRs )
	forwardA=fowardfromEx_Mem;
else if(Mem_WbRegWrite==1 && Mem_WbRegisterRd!=0 && Mem_WbRegisterRd==ID_ExRegisterRs )
begin
	if(MEM_WBMemToReg==1)
	forwardA=fowardMemResultfromMem_Wb;
	else if(MEM_WBMemToReg==0)
	forwardA=fowardALUResultfromMem_Wb;
end
else
	forwardA=0;
if(Ex_MemRegWrite==1 && Ex_MemRegisterRd!=0 && Ex_MemRegisterRd==ID_ExRegisterRt )
	forwardB=fowardfromEx_Mem;
else if(Mem_WbRegWrite==1 && Mem_WbRegisterRd!=0 && Mem_WbRegisterRd==ID_ExRegisterRt )
begin
	if(MEM_WBMemToReg==1)
	forwardB=fowardMemResultfromMem_Wb;
	else if(MEM_WBMemToReg==0)
	forwardB=fowardALUResultfromMem_Wb;
end
else
	forwardB=0;

end



endmodule

module forward(input [4:0] RegLw,input[4:0] RegSw,input WriteEnable,input memWrite,input MEMWBmemtoreg,output [1:0]forwardF);

parameter forwardfromALUresult=2'b10,
	forwardfromReadMem=2'b01,
	noforward=2'b00;

	assign forwardF=((WriteEnable==1'b1)&&(RegLw==RegSw)&&(RegLw!=5'b00000)&&(RegSw!=5'b00000)&&(memWrite==1'b1)&&(MEMWBmemtoreg==1))?forwardfromReadMem:
			((WriteEnable==1'b1)&&(RegLw==RegSw)&&(RegLw!=5'b00000)&&(RegSw!=5'b00000)&&(memWrite==1'b1)&&(MEMWBmemtoreg==0))?forwardfromALUresult:noforward;
//always @(forwardF)
//$display("forward");
endmodule

module hazardDetectionUnit ( input [4:0]IFIDRegrs , input [4:0]IFIDRegrt , input [4:0]IDEXRegrt ,input [4:0]IDEXRegrd ,input [4:0] EXMERegwriteReg,
 input [5:0] IFIDopcode ,input [5:0] IDEXopcode,input IDEXregwrite ,input IDEXregdst,input EXMEMregwrite , input EXMEMmemread ,
 output reg IFIDRegHOLD , output reg pcHOLD ,output reg IFflush);

parameter beqOPcode = 6'b000100 ;
parameter lwOPcode = 6'b100011 , R_format = 6'b000000 , swOPcode = 6'b101011 ;

initial
begin
IFIDRegHOLD =0;
pcHOLD =0;
IFflush=0;
end

always@(*)
begin
if (/*IFIDopcode==R_format&&*/IFIDopcode!=swOPcode&&IDEXopcode==lwOPcode &&((IDEXRegrt == IFIDRegrs) || (IDEXRegrt == IFIDRegrt)) && IDEXregwrite==1 && IDEXregdst ==0) //stall after lw instruction
begin
IFIDRegHOLD=1;
pcHOLD=1;
IFflush=1;
end
else if (IFIDopcode==swOPcode&&IDEXopcode==lwOPcode &&((IDEXRegrt == IFIDRegrs) ) && IDEXregwrite==1 && IDEXregdst ==0) //stall sw dependency on lw instruction
begin
IFIDRegHOLD=1;
pcHOLD=1;
IFflush=1;
end
else if (IFIDopcode==beqOPcode && ((IDEXRegrd == IFIDRegrs) || (IDEXRegrd == IFIDRegrt))&& IDEXregdst ==1 && IDEXregwrite==1 ) //@ beq stall after R-format instruction
begin
IFIDRegHOLD=1;
pcHOLD=1;
IFflush=1;
end
else if (IFIDopcode==beqOPcode && IDEXopcode!=lwOPcode&&((IDEXRegrt == IFIDRegrs) || (IDEXRegrt == IFIDRegrt))&& IDEXregdst ==0 && IDEXregwrite==1 ) //@ beq stall after i-format instruction
begin
IFIDRegHOLD=1;
pcHOLD=1;
IFflush=1;
end
else if (IFIDopcode==beqOPcode && ((EXMERegwriteReg == IFIDRegrs) || (EXMERegwriteReg == IFIDRegrt)) && EXMEMregwrite==1 && EXMEMmemread ==1) //@beq second stall after lw instruction
begin
IFIDRegHOLD=1;
pcHOLD=1;
IFflush=1;
end
/*else if (IDEXopcode==beqOPcode && ((IDEXRegrt == IFIDRegrs) || (IDEXRegrt == IFIDRegrt)) ) //control hazard
begin
IFIDRegHOLD=0;
pcHOLD=0;
IFflush=1;
end*/

else
begin
//controlMUX=0;
IFIDRegHOLD=0;
pcHOLD=0;
IFflush=0;
end

end


endmodule

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

module insMemory (input [9:0] rdAddress, output [31:0] rdIns);

	reg [31:0] insFile [0:1023];

	assign rdIns = insFile[rdAddress];

	initial
		$readmemh("out.hex", insFile, 0);

endmodule

module memoryStage(input clk,input[74:0]EXMEMReg,output reg [70:0]MEMWBReg);
wire [31:0]rdData;
wire [31:0] memoryAddress = EXMEMReg[31:0];
wire[31:0]WriteData=EXMEMReg[63:32];
wire RegWrite=EXMEMReg[74];
wire MemToReg=EXMEMReg[72];
wire MemWrite=EXMEMReg[73];
wire MemRead=EXMEMReg[71];
wire [4:0] WriteRegister = EXMEMReg[68:64];
wire [31:0] MEMWBreaddata = MEMWBReg[31:0];
wire [31:0] MEMWBaluResult = MEMWBReg[69:38];
wire [31:0] selData;
wire [1:0] forwardF;

always @(posedge clk) begin
MEMWBReg = {MemToReg,memoryAddress,RegWrite,WriteRegister,rdData};
//$display ("memtoreg: %d memoryaddress: %d regwrite: %d writeregister: %d rddata: %d", MemToReg,memoryAddress,RegWrite,WriteRegister,rdData);
end
dataMemory d1(MemWrite, memoryAddress[9:0], selData, MemRead, memoryAddress[9:0],rdData, clk);
forward f2(MEMWBReg[36:32],WriteRegister,MEMWBReg[37],MemWrite,MEMWBReg[70],forwardF);
mux3To1 forwardingmux(forwardF,WriteData,MEMWBreaddata,MEMWBaluResult, selData);
//mux m2(forwardF,WriteData,MEMWBreaddata, selData);
endmodule

module mux (input selCh, input [31:0] inCh0, input [31:0] inCh1, output [31:0] selData);

	assign selData = selCh == 0 ? inCh0 :
                     selCh == 1 ? inCh1 : 0;

endmodule
module mux5bits (input selCh, input [4:0] inCh0, input [4:0] inCh1, output [4:0] selData);

	assign selData = selCh == 0 ? inCh0 :
                     selCh == 1 ? inCh1 : 0;

endmodule

module mux8bits (input selCh, input [7:0] inCh0, input [7:0] inCh1, output [7:0] selData);

	assign selData = selCh == 0 ? inCh0 :
                     selCh == 1 ? inCh1 : 0;

endmodule

module mux3To1 (input [1:0]selCh, input [31:0] inCh0, input [31:0] inCh1, input [31:0] inCh2, output [31:0] selData);

	assign selData = selCh == 2'b00 ? inCh0 :
                     	 selCh == 2'b01 ? inCh1 :
			 selCh == 2'b10 ? inCh2 : 32'bx;

endmodule

module mux3To1_5bits (input [1:0]selCh, input [4:0] inCh0, input [4:0] inCh1, input [4:0] inCh2, output [4:0] selData);

	assign selData = selCh == 2'b00 ? inCh0 :
                     	 selCh == 2'b01 ? inCh1 :
			 selCh == 2'b10 ? inCh2 : 32'bx;

endmodule

module mux4to1 (input [1:0] selCh, input [31:0] inCh0, input [31:0] inCh1, input [31:0] inCh2, input [31:0] inCh3, output [31:0] selData);

	assign selData = selCh == 2'b00 ? inCh0 :
                     selCh == 2'b01 ? inCh1 :
                     selCh == 2'b10 ? inCh2 :
                     selCh == 2'b11 ? inCh3 : 32'bx;

endmodule

module PC (output reg [31:0] nextPC , input [31:0] prevPC, input clk);

initial nextPC=32'b0;

always @(posedge clk)
	nextPC <= prevPC;

endmodule

module registerFile (input wrEnable, input [4:0] wrReg, input signed [31:0] wrData, input [4:0] rdReg1, output [31:0] rdData1, input [4:0] rdReg2, output [31:0] rdData2, input clk);

	reg [31:0] regFile [0:31];

	assign rdData1 = regFile[rdReg1];
	assign rdData2 = regFile[rdReg2];

	always @(negedge clk)
		if (wrEnable) begin
			regFile[wrReg] <= wrData;
			if (wrReg != 0) $display ("reg%d  =  %d", wrReg, wrData);
		end
initial   regFile[0] <= 32'h 0;
endmodule

module ShiftLeftBranch(input[31:0] In ,output [31:0] Out);
assign Out = 4*In ;
endmodule

module ShiftLeftJump(input[25:0] In ,output [27:0] Out);
assign Out = 4*In ;
endmodule

module signextend1632 (input [15:0] in, output [31:0] extended);

	assign extended = { {16 { in[15]}}, in[15:0] };

endmodule

module pipeliningMIPS ();

wire BranchTaken ;
wire [31:0]branchAddrs ;
wire IFIDhold , PChold;
wire [63:0]IF_IDreg ;
wire [135:0]ID_EXreg;
wire [70:0]MEM_WBreg;
wire [74:0]EX_MEMreg;

reg clk;
reg [9:0] clkCount;
initial begin clk <= 0; clkCount <= 10'd0; end
always @(clkCount) if (clkCount < 10'd<<TIME>>) #5 clk = ~clk;
always @ (clk) clkCount = clkCount + 1;

instructionFetch pipeliningMIPS_IF( BranchTaken,branchAddrs,IFIDhold,PChold,IF_IDreg, clk);
DecodeandWBStages pipeliningMIPS_ID_WB( clk ,IF_IDreg,MEM_WBreg,EX_MEMreg,ID_EXreg , BranchTaken ,branchAddrs, PChold, IFIDhold  );
memoryStage pipeliningMIPS_MEM( clk,EX_MEMreg,MEM_WBreg);
executionStage pipliningMIPS_EX(clk,ID_EXreg,MEM_WBreg,EX_MEMreg);

endmodule
