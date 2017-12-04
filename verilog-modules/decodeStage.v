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



module DecodeandWBStagesTB;
reg clk=0 ;
wire [63:0]IFIDReg; //input
wire [70:0]MEMWBReg; //input
wire [74:0] EXMEReg; //input
wire [135:0]IDEXReg ; //output
wire BranchControlSignal ;
wire[31:0] BranchTarget;
wire pcHOLD ;
wire IFIDRegHOLD ;
//IFIDReg
reg [31:0] IFIDRegpc ;
reg [31:0] IFIDReginstruction ; 
//MEMWBReg
reg [31:0] MEMWBRegmemreaddata ;
reg [31:0] MEMWBRegAlUresult ;
reg [4:0] MEMWBRegwrReg ; //forward test
reg MEMWBRegwrenable ;
reg MEMWBRegmemtoreg ;
//EXMEReg
reg [31:0] EXMERegALUresult;
reg [31:0] EXMERegReadData2=0;
reg [4:0] EXMERegwrReg; //forward test
reg EXMERegZero =0;
reg EXMERegOverflow=0;
reg EXMERegMemRead;
reg EXMERegmemtoreg;
reg EXMERegmemwrite;
reg EXMERegregWrite;

assign IFIDReg= {IFIDReginstruction, IFIDRegpc};
assign MEMWBReg= {MEMWBRegmemtoreg,MEMWBRegAlUresult,MEMWBRegwrenable,MEMWBRegwrReg, MEMWBRegmemreaddata } ;
assign EXMEReg = {EXMERegregWrite,EXMERegmemwrite,EXMERegmemtoreg,EXMERegMemRead,EXMERegOverflow,EXMERegZero,EXMERegwrReg,EXMERegReadData2, EXMERegALUresult};

//IDEXReg (output from the prev cycle )
wire [31:0] IDEXRegInst = IDEXReg[31:0];
wire [31:0] readdata1 = IDEXReg [63:32];
wire [31:0] readdata2 = IDEXReg [95 : 64];
wire [31:0] signExtended = IDEXReg [127:96];
wire [4:0] IDEXRegrt = IDEXRegInst[20:16]; //for Hazard test
wire [4:0] IDEXRegrd = IDEXRegInst[15:11]; //for Hazard test
wire IDEXRegMemRead = IDEXReg[134]; //for Hazard Test

always
#5 clk=!clk;

integer i ;

initial
begin
$monitor ($time, " outputs : Inst.= %h , data1= %d , data2 = %d , signex = %d ,\n btaken = %d , btarget = %d , PCHold = %d , RegHold = %d , rt=%d , rd=%d , memread =%d \n inputs : Regpc=%d ,inst=%h , MEMWBreaddata=%d , MEMWBAlUres=%d , MEMWBwrReg=%d ,MEMWBwrenable=%d , MEMWBmemtoreg=%d",
IDEXRegInst , readdata1 , readdata2 , signExtended , BranchControlSignal ,  BranchTarget , pcHOLD ,  IFIDRegHOLD, IDEXRegrt , IDEXRegrd , IDEXRegMemRead ,
IFIDRegpc ,IFIDReginstruction , MEMWBRegmemreaddata , MEMWBRegAlUresult , MEMWBRegwrReg ,MEMWBRegwrenable , MEMWBRegmemtoreg );
//$monitor ($time ," IDEXRegInst =%h ,readdata1=%d , readdata2=%d, IDEXRegrt = %d , IDEXRegMemRead=%d , \n  BranchControlSignal=%d , BranchTarget=%d , pcHOLD=%d ,  IFIDRegHOLD=%d \n inputs  IFIDRegpc=%d ,IFIDReginstruction=%h , MEMWBRegmemreaddata=%d , MEMWBRegAlUresult=%d , MEMWBRegwrReg=%d ,MEMWBRegwrenable=%d , MEMWBRegmemtoreg=%d"  , IDEXRegInst ,readdata1,readdata2, IDEXRegrt , IDEXRegMemRead , BranchControlSignal , BranchTarget , pcHOLD ,  IFIDRegHOLD,  IFIDRegpc ,IFIDReginstruction , MEMWBRegmemreaddata , MEMWBRegAlUresult , MEMWBRegwrReg ,MEMWBRegwrenable , MEMWBRegmemtoreg );
//$monitor ($time , "IFIDReg=%h , MEMWBReg=%h, IDEXReg=%h , BranchControlSignal=%h , BranchTarget=%h , pcHOLD=%h " , IFIDReg, MEMWBReg, IDEXReg , BranchControlSignal , BranchTarget , pcHOLD );

for (i=0 ; i<32 ; i=i+1)
begin
#10
MEMWBRegwrenable=1 ;
MEMWBRegwrReg=i ;
MEMWBRegmemtoreg=0 ;
MEMWBRegAlUresult=i ;
end


//TEST Branch Taken
#10
//IFID
IFIDRegpc = 7;
IFIDReginstruction = 32'h12320005 ; //instruction beq $s5 , $s1, label  
//MEMWBReg
MEMWBRegmemreaddata=0 ;
MEMWBRegAlUresult=17 ;
MEMWBRegwrReg=18 ; 
MEMWBRegwrenable=1 ;
MEMWBRegmemtoreg=0 ;

//TEST branch hazard
#10
//IFID
IFIDRegpc = 11;
IFIDReginstruction = 32'h02f49020 ; //instruction add $s2 , $s7 , $s4  
//MEMWBReg
MEMWBRegmemreaddata=0 ;
MEMWBRegAlUresult=78 ;
MEMWBRegwrReg=7 ; 
MEMWBRegwrenable=1 ;
MEMWBRegmemtoreg=1 ;
//Test Forwarding from mem and hazard
#10
//IFID
IFIDRegpc = 7;
IFIDReginstruction = 32'h12320004 ; //instruction beq $s2 , $s1, label  
//MEMWBReg
MEMWBRegmemreaddata=0 ;
MEMWBRegAlUresult=55 ;
MEMWBRegwrReg=14 ; 
MEMWBRegwrenable=1 ;
MEMWBRegmemtoreg=0;
//EXMEMreg
EXMERegwrReg=17 ;
EXMERegregWrite=1;
EXMERegmemtoreg=0;
EXMERegMemRead=0;
EXMERegALUresult=66;

//sw debendency on lw hazard
#10
//IFID
IFIDRegpc = 11;
IFIDReginstruction = 32'h8e510000 ; //instruction lw $s1 , 0($s2)  
//MEMWBReg
MEMWBRegmemreaddata=0 ;
MEMWBRegAlUresult=55 ;
MEMWBRegwrReg=14 ; 
MEMWBRegwrenable=1 ;
MEMWBRegmemtoreg=0;
//EXMEMreg
EXMERegwrReg=17 ;
EXMERegregWrite=1;
EXMERegmemtoreg=0;
EXMERegMemRead=0;
EXMERegALUresult=66;

#10
//IFID
IFIDRegpc = 11;
IFIDReginstruction = 32'hae370000 ; //instruction sw $s7 , 0($s1)  
//MEMWBReg
MEMWBRegmemreaddata=0 ;
MEMWBRegAlUresult=55 ;
MEMWBRegwrReg=14 ; 
MEMWBRegwrenable=1 ;
MEMWBRegmemtoreg=0;
//EXMEMreg
EXMERegwrReg=17 ;
EXMERegregWrite=1;
EXMERegmemtoreg=0;
EXMERegMemRead=0;
EXMERegALUresult=66;

//lw and beq 2 stalls
/*#10
//IFID
IFIDRegpc = 11;
IFIDReginstruction = 32'h8e510000 ; //instruction lw $s1 , 0($s2)  
//MEMWBReg
MEMWBRegmemreaddata=0 ;
MEMWBRegAlUresult=55 ;
MEMWBRegwrReg=14 ; 
MEMWBRegwrenable=1 ;
MEMWBRegmemtoreg=0;
//EXMEMreg
EXMERegwrReg=17 ;
EXMERegregWrite=1;
EXMERegmemtoreg=0;
EXMERegMemRead=0;
EXMERegALUresult=66;*/
#10
//IFID
IFIDRegpc = 7;
IFIDReginstruction = 32'h12320004 ; //instruction beq $s2 , $s1, label  
//MEMWBReg
MEMWBRegmemreaddata=0 ;
MEMWBRegAlUresult=55 ;
MEMWBRegwrReg=14 ; 
MEMWBRegwrenable=1 ;
MEMWBRegmemtoreg=0;
//EXMEMreg
EXMERegwrReg=17 ;
EXMERegregWrite=1;
EXMERegmemtoreg=1;
EXMERegMemRead=1; //lw
EXMERegALUresult=66;
#10
//IFID
IFIDRegpc = 10;
IFIDReginstruction = 32'h12320004 ; //instruction beq $s2 , $s1, label  
//MEMWBReg
MEMWBRegmemreaddata=0 ;
MEMWBRegAlUresult=55 ;
MEMWBRegwrReg=14 ; 
MEMWBRegwrenable=1 ;
MEMWBRegmemtoreg=0;
//EXMEMreg
EXMERegwrReg=17 ;
EXMERegregWrite=1;
EXMERegmemtoreg=0;
EXMERegMemRead=0; //lw
EXMERegALUresult=66;


end
DecodeandWBStages decodeandwbtest( clk ,IFIDReg, MEMWBReg, EXMEReg , IDEXReg , BranchControlSignal , BranchTarget , pcHOLD ,  IFIDRegHOLD);

endmodule
