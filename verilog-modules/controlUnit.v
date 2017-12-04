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
module ControlTest;
reg [5:0]op;wire [1:0]ALUOp;wire RegDst,Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
initial
begin
$monitor("RegDst=%b ALUSrc=%b MemtoReg=%b RegWrite=%b MemRead=%b MemWrite=%b Branch=%b ALUOp=%b Jump=%b",RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp,Jump);
#10
op=0;
#10
op=35;
#10
op=43;
#10
op=4;
#10
op=2;
#10
op=8;
end
Control controlUnit(op, RegDst,Jump, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);
endmodule
