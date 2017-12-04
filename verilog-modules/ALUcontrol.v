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

module ALUcontrolTest;
reg [5:0] funct;reg[1:0]ALUop;wire[3:0]ALU;
initial 
begin
$monitor("ALU =%b ",ALU);
#10
funct=36;ALUop=2;
#10
funct=37;ALUop=2;
#10
funct=32;ALUop=0;
#10
funct=34;ALUop=1;
#10
funct=42;ALUop=2;
#10
funct=39;ALUop=2;
#10
funct=0;ALUop=2;
#10
funct=2;ALUop=2;
#10
funct=8;ALUop=2;
end
ALUcontrol A1(funct,ALUop, ALU);
endmodule
