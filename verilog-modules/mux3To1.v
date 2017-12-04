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

module mux3To1Test;
reg [1:0]selCh; reg [31:0] inCh0; reg [31:0] inCh1; reg [31:0] inCh2; wire [31:0] selData;
initial
begin
$monitor("out of mux=%d",selData);
#10
inCh0=100;
inCh1=55;
inCh2=93;
selCh=0;
#10
selCh=1;
#10
selCh=2;
#10
selCh=3;
#10
inCh0=15555555;
selCh=0;
end

mux3To1 mux1 (selCh, inCh0, inCh1, inCh2, selData);
endmodule