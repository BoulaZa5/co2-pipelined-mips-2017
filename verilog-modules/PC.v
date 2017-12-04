module PC (output reg [31:0] nextPC , input [31:0] prevPC, input clk);

initial nextPC=32'b0;

always @(posedge clk)
	nextPC <= prevPC;

endmodule

module PC_test;

reg [31:0]prevPC;
reg clk;
wire [31:0]nextpc ;

always begin #5 clk = ~clk; end

initial 
begin
 $monitor ($time , ,"clk=%d , PrevPC=%d , NextPC=%d",clk,prevPC,nextpc);

clk =0;

#5 prevPC=7;
#10 prevPC=56;
#10 prevPC=9;
#10 prevPC=657;
end

PC PC_TEST( nextpc , prevPC , clk);
endmodule
