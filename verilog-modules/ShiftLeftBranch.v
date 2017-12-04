module ShiftLeftBranch(input[31:0] In ,output [31:0] Out);
assign Out = 4*In ;
endmodule

module ShiftLeftBranchTest;
reg[31:0]In;wire[31:0]Out;
initial 
begin
$monitor("Out %b",Out);
#10
In= 32'b11110000111100001111000011110000 ;
#10
In= 32'b11110000111100001111000011111111 ;
#10
In= 32'b11110000111100001111000011111010 ;
end 
ShiftLeftBranch B1(In ,Out);
endmodule
