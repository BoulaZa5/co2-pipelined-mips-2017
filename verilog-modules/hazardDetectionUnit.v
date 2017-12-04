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


module hazardUnitTB ;

reg [4:0]IFIDRegrs ;
reg [4:0]IFIDRegrt ;
reg [4:0]IDEXRegrt ;
reg [4:0]IDEXRegrd ;
reg [4:0] EXMERegwriteReg;
reg [5:0] IFIDopcode ;
reg [5:0] IDEXopcode;
reg IDEXregwrite ;
reg IDEXregdst;
reg EXMEMregwrite ;
reg EXMEMmemread ;




wire IFIDRegHOLD;
wire pcHOLD ;
wire IFflush ;

initial
begin

$monitor ("IFIDRegrs=%d IFIDRegrt=%d ; IDEXRegrt=%d; IDEXRegrd=%d,EXMERegwriteReg=%d,IFIDopcode=%d,IDEXopcode= %d,IDEXregwrite = %d,IDEXregdst=%d,EXMEMregwrite =%d,EXMEMmemread=%d \n IFIDRegHOLD=%d ,  pcHOLD=%d , IFflush=%d " , IFIDRegrs,IFIDRegrt,IDEXRegrt,IDEXRegrd,EXMERegwriteReg,IFIDopcode,IDEXopcode,IDEXregwrite,IDEXregdst,EXMEMregwrite,EXMEMmemread, IFIDRegHOLD ,  pcHOLD , IFflush );

#10
IFIDRegrs=7 ;
IFIDRegrt=8 ;
IDEXRegrt=14;
IDEXRegrd=22;
EXMERegwriteReg=1;
IFIDopcode= 6'b000100 ; //beq
IDEXopcode= 0;
IDEXregwrite = 1;
IDEXregdst=0;
EXMEMregwrite =1;
EXMEMmemread=0;


#10
IFIDRegrs=7 ;
IFIDRegrt=8 ;
IDEXRegrt=7;
IDEXRegrd=22;
EXMERegwriteReg=15;
IFIDopcode= 0 ; //rformat
IDEXopcode= 6'b100011 ; //lw
IDEXregwrite = 1;
IDEXregdst=0;
EXMEMregwrite =1;
EXMEMmemread=0;

#10
IFIDRegrs=7 ;
IFIDRegrt=8 ;
IDEXRegrt=7;
IDEXRegrd=22;
EXMERegwriteReg=15;
IFIDopcode= 4 ; //beq
IDEXopcode= 35 ; //lw
IDEXregwrite = 1;
IDEXregdst=0;
EXMEMregwrite =1;
EXMEMmemread=0;
#10
IFIDRegrs=1 ;
IFIDRegrt=8 ;
IDEXRegrt=1;
IDEXRegrd=22;
EXMERegwriteReg=0;
IFIDopcode= 0 ; //rformat
IDEXopcode= 35 ; //lw
IDEXregwrite = 1;
IDEXregdst=0;
EXMEMregwrite =1;
EXMEMmemread=1;

end

//hazardDetectionUnit  hazardUnitTEST ( IFIDRegrs , IFIDRegrt , IDEXRegrt , OPcode , IFIDRegHOLD , pcHOLD ,IFflush);
hazardDetectionUnit  hazardUnitTEST (IFIDRegrs ,IFIDRegrt ,IDEXRegrt ,IDEXRegrd ,EXMERegwriteReg,
IFIDopcode ,IDEXopcode,IDEXregwrite , IDEXregdst, EXMEMregwrite , EXMEMmemread , 
IFIDRegHOLD , pcHOLD , IFflush);
endmodule
