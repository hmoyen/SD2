// **********GRUPO ************
// Helena Bianchi Moyen
// Luiz Mariano
// Mariana Watanabe


`timescale 1ns/1ns

module testbench;

    // Inputs
    reg clock_tb;
    reg reset_tb;
    reg [31:0] instruction_tb;

    wire [31:0] S5_tb;
    wire funct7_tb; // Da memória de instrução para a ALUControl
    wire [2:0] funct3_tb; // Da memória de instrução para a ALUControl
    wire [3:0] control_tb; // Da ALUControl para a ULA
    wire signed [63:0] res_tb;
    wire [63:0] doutMem_tb;
    wire [3:0] state_reg_tb;
    wire [4:0] Rw_tb;
    wire [4:0] Ra_tb, Rb_tb;
    wire [6:0] opcode_tb;
    wire signed [63:0] doutA_tb;
    wire signed [63:0] doutB_tb;
    wire signed [63:0] S1_tb;
    wire signed [63:0] S2_tb;
    wire signed [63:0] S4_tb;
    wire [31:0] C_tb;
    wire [31:0] PC_tb;
    wire [31:0] IR_tb;
    wire [31:0] doutIR_tb;
    wire flag_tb;
    wire signed [63:0] imm_tb;
    wire [31:0] somafour_tb, somaimm_tb;

    // Sinais UC

    wire weMem_tb, wePC_tb, weIR_tb;
    wire sinalMux1_tb;
    wire [1:0] sinalMux2_tb;
    wire sinalMux4_tb;
    wire [1:0] aluop_tb; // UC para ALUControl



    ULA uut (
        .a(doutA_tb), 
        .b(S1_tb), 
        .soma(res_tb),
        .sinal(control_tb),
        .flag(flag_tb)
    );

    registrador utt (

        .clk(clock_tb),
        .din(S2_tb),
        .we(weReg_tb),
        .Rw(Rw_tb),
        .Ra(Ra_tb),
        .Rb(Rb_tb),
        .doutA(doutA_tb),
        .doutB(doutB_tb)
    );

    memoria utu (

        .ads(res_tb),
        .we(weMem_tb),
        .din(doutB_tb),
        .dout(doutMem_tb)
    );

    Mux1 utv (
        .imm(imm_tb),
        .doutB(doutB_tb),
        .sinalMux(sinalMux1_tb),
        .S1(S1_tb)
    );

    Mux2 uvv (
        .dout(doutMem_tb),
        .soma(res_tb),
        .PC_four(somafour_tb),
        .PC_imm(somaimm_tb),
        .sinalMux(sinalMux2_tb),
        .S2(S2_tb)
    );
    
    memoria_ins utH (

        .ads(S5_tb),
        .dout(IR_tb)
    );

    PC uhh(
        .clock(clock_tb),
        .r_enable(wePC_tb),
        .data_in(C_tb),
        .data_out(PC_tb)
    );

    IR huu (
        .clock(clock_tb),
        .r_enable(weIR_tb),
        .data_in(IR_tb),
        .data_out(doutIR_tb),
        .rs1(Ra_tb),
        .rs2(Rb_tb),
        .rd(Rw_tb),
        .opcode(opcode_tb),
        .funct7(funct7_tb),
        .funct3(funct3_tb)

    );

    imm_generator hii (
        .palavra(doutIR_tb),
        .opcode(opcode_tb),
        .imm(imm_tb)

    );

    somador_four itt(
        .dout_pc(PC_tb),
        .soma(somafour_tb)

    );

    somador_imm its (
        .dout(S4_tb),
        .imm(imm_tb),
        .soma(somaimm_tb)
    );

    Mux3 ihs (
        .four_some(somafour_tb),
        .imm_some(somaimm_tb),
        .flag(flag_tb),
        .S3(C_tb)
    );

    Mux4 iss (
        .doutA(doutA_tb),
        .PC(PC_tb),
        .sinalMux(sinalMux4_tb),
        .S4(S4_tb)
    );

    Mux5 hhh (
        .dout_PC(PC_tb),
        .tb(instruction_tb),
        .S5(S5_tb),
        .reset(reset_tb)
    );

    ALUControl alu (
        .aluop(aluop_tb),
        .funct3(funct3_tb),
        .funct7(funct7_tb),
        .control(control_tb)
    );

    state_machineUC sta (
        .clk(clock_tb),
        .reset(reset_tb),
        .state_reg(state_reg_tb)
    );

    UC ucc(
        .clk(clock_tb),
        .state_reg(state_reg_tb),
        .opcode(opcode_tb),
        .aluop(aluop_tb),
        .Mux1(sinalMux1_tb),
        .Mux2(sinalMux2_tb),
        .Mux4(sinalMux4_tb),
        .weMem(weMem_tb),
        .weReg(weReg_tb),
        .weIR(weIR_tb),
        .wePc(wePC_tb)

    );



    initial $dumpfile("testbench.vcd");
    initial $dumpvars(0, testbench);

    initial 
    begin
        
        //*******************************Abaixo é a simulação: ********************************************************************
        clock_tb = 1;
        reset_tb = 1;
        instruction_tb = 0; // ADD
        #10
        reset_tb = 0; // INSTRUCTION FETCH FINISHED
        #10
        // DECODE FINISHED
        #10
        // EXECUTE FINISHED
        #10
        #10
        #10
        #10
        #10
        #10
        #10
        #10
        // WB FINISHED -> NEXT INSTRUCTION IS SUB
        #10
        // INSTRUCTION FETCH FINISHED
        #10
        // DECODE FINISHED
        #10
        // EXECUTE FINISHED
        #10
        #10
        #10
        #10
        #10
        #10
        #10
        #10
        // WB FINISHED -> END
        $display("Fim da simulação");
        $finish;

     
    end

        always #10 clock_tb = ~clock_tb;
    
    



endmodule