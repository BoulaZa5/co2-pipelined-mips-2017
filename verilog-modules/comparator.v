module comparator (input [31:0] data1 , input [31:0] data2 , output reg isEqual);


initial isEqual=0;
always@(*)
begin
if(data1==data2)
isEqual=1;
else
isEqual=0;

end

endmodule



module comparatorTB ;

reg [31:0] data1 ;
reg [31:0] data2 ;
wire isEqual;

initial 
begin
$monitor ("data1=%d ,data2=%d ,isEqual=%d",data1 ,data2 ,isEqual);

#10
data1=52;
data2=24;

#10
data1=24;
data2=24;

#10
data1=78;
data2=78;

#10
data1=52;
data2=24;

#10
data1=11;
data2=11;

end


comparator compareTEST(data1 ,data2 ,isEqual);
endmodule
