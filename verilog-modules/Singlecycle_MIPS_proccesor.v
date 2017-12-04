module Single_Cycle_MIPS_Proccessor (input clk ,input reset, output overflow);

wire [31:0] PC_Input;
wire [31:0] PC_Output;
wire [31:0] Instruction;
wire [31:0] Fetched_PC;
wire RegDst,Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
wire [1:0]ALUOp;
wire [4:0]write_register;
wire [31:0] write_data ; wire [31:0] read_data_1 ; wire [31:0] read_data_2;
wire [3:0] ALUcontrol_signal;
wire [27:0] jumpaddress;
wire [31:0] Branch_extended_address ; wire [31:0] ALU_second_operand ;
wire ALU_Zero_flag ; wire [31:0] ALU_Result ;
wire [31:0] WriteData ; 
wire [31:0] Data_Memory_readData ;
wire [31:0] Branch_Shifted_address ; wire [31:0] Branch_target ;
wire Branch_control_Signal;
wire [31:0]PC_target_fetched_branch;


PC single_cycle_PC (PC_Output, PC_Input , reset , clk );
insMemory single_cycle_Instruction_Memory ( PC_Output[9:0]>> 2 , Instruction ); 
adder PC_adder ( PC_Output , 4 , Fetched_PC );
Control single_cycle_Control_unit (Instruction[31:26], RegDst, Jump , Branch , MemRead ,MemtoReg , ALUOp , MemWrite , ALUSrc , RegWrite );
mux Wirte_Register_Mux (RegDst ,  Instruction[20:16] ,  Instruction[15:11] , write_register);
ShiftLeftJump Shift_Left_Jump_address( Instruction[25:0] ,  jumpaddress[27:0]);
registerFile single_cycle_MIPS_registers (RegWrite, write_register, WriteData,Instruction[25:21] , read_data_1, Instruction[20:16], read_data_2, clk);
signextend1632 sign_extend_unit ( Instruction[15:0], Branch_extended_address); 
mux ALU_Mux ( ALUSrc , read_data_2 , Branch_extended_address , ALU_second_operand); 
ALUcontrol single_cycle_ALUcontrol(Instruction[5:0], ALUOp ,ALUcontrol_signal);
alu single_cycle_MIPS_ALU ( read_data_1 , ALU_second_operand , ALUcontrol_signal, Instruction[10:6] ,ALU_Result, overflow ,  ALU_Zero_flag );
dataMemory Single_cycle_MIPS_DataMemory(MemWrite, ALU_Result[4:0],read_data_2 , MemRead ,ALU_Result[4:0]  , Data_Memory_readData, clk);
mux Write_Data_Mux_single_cycle_MIPS (MemtoReg, ALU_Result, Data_Memory_readData , WriteData);
ShiftLeftBranch Shift_Left_Branch_address(Branch_extended_address ,Branch_Shifted_address);
adder Branch_adder (Fetched_PC , Branch_Shifted_address , Branch_target );
and Branch_selector ( Branch_control_Signal , Branch , ALU_Zero_flag );
mux Branch_address_Mux (Branch_control_Signal , Fetched_PC , Branch_target , PC_target_fetched_branch );
mux Jump_address_mux (Jump , PC_target_fetched_branch , {Fetched_PC[31:28],jumpaddress} , PC_Input );
endmodule


module MIPS_Poccessor_single_cycle_tb ;

reg clk , reset ;
wire overflow;
always begin #5 clk = ~clk; end

initial
begin
$monitor ("overflow=%d",overflow);
clk=0;
reset=0;
end
Single_Cycle_MIPS_Proccessor Single_Cycle_MIPS_Proccessor_TEST (clk , reset,overflow);

endmodule