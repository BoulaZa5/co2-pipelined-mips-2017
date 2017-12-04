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


/*
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
wire [31:0] selData;
wire [31:0] aluOut2 = MEMWBReg[69:38];
wire [1:0] forwardF ;
always @(posedge clk) begin
MEMWBReg = {MemToReg,memoryAddress,RegWrite,WriteRegister,rdData};

//$display ("memtoreg: %d memoryaddress: %d regwrite: %d writeregister: %d rddata: %d", MemToReg,memoryAddress,RegWrite,WriteRegister,rdData);
end
dataMemory d1(MemWrite, memoryAddress[9:0], selData, MemRead, memoryAddress[9:0],rdData, clk);
forward f2(MEMWBReg[36:32],EXMEMReg[68:64],MEMWBReg[37],MEMWBReg[70],forwardF);
mux3To1 m2(forwardF,WriteData,MEMWBreaddata,aluOut2, selData);
endmodule
*/
module memoryStageTb;
reg clk;reg[74:0]EXMEMReg;wire [70:0]MEMWBReg;
wire MemToReg = MEMWBReg[70];
wire[31:0] memoryAddress=MEMWBReg[69:38];
wire RegWrite=MEMWBReg[37];
wire [4:0]WriteRegister=MEMWBReg[36:32];
wire[31:0]rdData=MEMWBReg[31:0];
wire [1:0]forwardF;
always 
#5 clk=!clk;
initial 
begin 
EXMEMReg = {75 {1'b0}};
clk = 0;
$monitor ($time,"MemToReg %b memoryAddress %h RegWrite %d WriteRegister %b rdData %h forwardF %b MEMWBReg %h",MemToReg ,memoryAddress ,RegWrite ,WriteRegister ,rdData,forwardF,MEMWBReg);
#10 //add
EXMEMReg[31:0]=32'h08438433;//result of ALU
EXMEMReg[63:32]=32'h8f3da232;//ReadData2
EXMEMReg[68:64]=5'b11100;//WriteReg
EXMEMReg[71]=1'b0;//MemRead
EXMEMReg[72]=1'b0;//MemToReg
EXMEMReg[73]=1'b0;//MemWrite
EXMEMReg[74]=1'b1;//RegWrite

#10 //sw
EXMEMReg[31:0]=32'h00000019;//result of ALU
EXMEMReg[63:32]=32'h01354440;//ReadData2
EXMEMReg[68:64]=5'b11100;//WriteReg
EXMEMReg[71]=1'b0;//MemRead
EXMEMReg[72]=1'b0;//MemToReg
EXMEMReg[73]=1'b1;//MemWrite
EXMEMReg[74]=1'b0;//RegWrite
end
memoryStage m1(clk,EXMEMReg,MEMWBReg);
endmodule
