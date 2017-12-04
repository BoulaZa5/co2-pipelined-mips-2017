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

module forwardingTest;
reg Ex_MemRegWrite;
reg [4:0]Ex_MemRegisterRd;
reg [4:0]ID_ExRegisterRs;
reg [4:0]ID_ExRegisterRt;
reg Mem_WbRegWrite;
reg [4:0]Mem_WbRegisterRd;
wire [1:0]forwardA;
wire [1:0]forwardB;
initial
begin
$monitor($time,"forwardA=%b forwardB=%b Ex_MemRegWrite=%b Ex_MemRegisterRd=%d Mem_WbRegWrite=%b Mem_WbRegisterRd=%d ID_ExRegisterRs=%d ID_ExRegisterRt=%d",forwardA,forwardB,Ex_MemRegWrite,Ex_MemRegisterRd,Mem_WbRegWrite,Mem_WbRegisterRd,ID_ExRegisterRs,ID_ExRegisterRt);
#10
// forward a 10 b 01
Ex_MemRegWrite=1;
Ex_MemRegisterRd=5;
ID_ExRegisterRs=5;
ID_ExRegisterRt=3;
Mem_WbRegWrite=1;
Mem_WbRegisterRd=3;
#10
// forward a 00 b 01
Ex_MemRegWrite=0;
Ex_MemRegisterRd=5;
ID_ExRegisterRs=5;
ID_ExRegisterRt=3;
Mem_WbRegWrite=1;
Mem_WbRegisterRd=3;
#10
// forward a 01 b 00
Ex_MemRegWrite=1;
Ex_MemRegisterRd=5;
ID_ExRegisterRs=2;
ID_ExRegisterRt=3;
Mem_WbRegWrite=1;
Mem_WbRegisterRd=2;
#10
// forward a 10 b 00
Ex_MemRegWrite=1;
Ex_MemRegisterRd=2;
ID_ExRegisterRs=2;
ID_ExRegisterRt=1;
Mem_WbRegWrite=1;
Mem_WbRegisterRd=2;
#10
// forward a 10 b 10
Ex_MemRegWrite=1;
Ex_MemRegisterRd=2;
ID_ExRegisterRs=2;
ID_ExRegisterRt=2;
Mem_WbRegWrite=1;
Mem_WbRegisterRd=2;
#10
// forward a 00 b 00
Ex_MemRegWrite=0;
Ex_MemRegisterRd=2;
ID_ExRegisterRs=2;
ID_ExRegisterRt=2;
Mem_WbRegWrite=0;
Mem_WbRegisterRd=2;
#10
// forward a 01 b 01
Ex_MemRegWrite=0;
Ex_MemRegisterRd=2;
ID_ExRegisterRs=2;
ID_ExRegisterRt=2;
Mem_WbRegWrite=1;
Mem_WbRegisterRd=2;
#10
// forward a 10 b 10
Ex_MemRegWrite=1;
Ex_MemRegisterRd=2;
ID_ExRegisterRs=2;
ID_ExRegisterRt=2;
Mem_WbRegWrite=0;
Mem_WbRegisterRd=2;
#10
// forward a 10 b 10
Ex_MemRegWrite=1;
Ex_MemRegisterRd=2;
ID_ExRegisterRs=2;
ID_ExRegisterRt=2;
Mem_WbRegWrite=1;
Mem_WbRegisterRd=2;
end


ExeForwardingUnit fowardunit( Ex_MemRegWrite, Ex_MemRegisterRd, ID_ExRegisterRs, ID_ExRegisterRt, Mem_WbRegWrite, Mem_WbRegisterRd, forwardA, forwardB);
endmodule
