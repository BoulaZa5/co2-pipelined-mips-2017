module pipeliningMIPS (input clk);

wire BranchTaken ;
wire [31:0]branchAddrs ;
wire IFIDhold , PChold;
wire [63:0]IF_IDreg ;
wire [135:0]ID_EXreg;
wire [70:0]MEM_WBreg;
wire [74:0]EX_MEMreg;

instructionFetch pipeliningMIPS_IF( BranchTaken,branchAddrs,IFIDhold,PChold,IF_IDreg, clk);
DecodeandWBStages pipeliningMIPS_ID_WB( clk ,IF_IDreg,MEM_WBreg,EX_MEMreg,ID_EXreg , BranchTaken ,branchAddrs, PChold, IFIDhold  );
memoryStage pipeliningMIPS_MEM( clk,EX_MEMreg,MEM_WBreg);
executionStage pipliningMIPS_EX(clk,ID_EXreg,MEM_WBreg,EX_MEMreg);

endmodule



module PiplineMIPSTestBench ;

reg clk ;
always begin #5 clk = ~clk; end

initial 
begin clk=0;
end

pipeliningMIPS pipeliningMIPStest(clk);



endmodule 