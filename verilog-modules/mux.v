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
