module ShiftLeftJump(input[25:0] In ,output [27:0] Out);
assign Out = 4*In ;
endmodule

module ShiftLeftJumpTest;
reg[25:0]In;wire[27:0]Out;
initial 
begin
$monitor("Out %b",Out);
#10
In= 26'b111100001111000011110000 ;
#10
In= 26'b111100001111000011111111 ;
#10
In= 26'b111100001111000011111010 ;
end 
ShiftLeftJump J1(In ,Out);
endmodule
