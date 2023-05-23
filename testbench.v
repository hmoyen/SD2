`timescale 1ns/1ns

module testbench;

    // Inputs
    reg clock_tb;
    reg sinal_tb;
    wire signed [63:0] res_tb;
    wire [63:0] doutMem_tb;
    reg weReg_tb;
    wire [4:0] Rw_tb;
    wire [4:0] Ra_tb, Rb_tb;
    wire [6:0] opcode_tb;
    wire signed [63:0] doutA_tb;
    wire signed [63:0] doutB_tb;
    wire signed [63:0] S1_tb;
    wire signed [63:0] S2_tb;
    reg weMem_tb, wePC_tb, weIR_tb;
    reg sinalMux1_tb;
    reg sinalMux2_tb;
    wire [31:0] C_tb;
    wire [31:0] PC_tb;
    wire [31:0] IR_tb;
    wire [31:0] doutIR_tb;
    wire flag_tb;
    wire signed [63:0] imm_tb;
    wire [31:0] somafour_tb, somaimm_tb;

    ULA uut (
        .a(doutA_tb), 
        .b(S1_tb), 
        .soma(res_tb),
        .sinal(IR_tb),
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
        .sinalMux(sinalMux2_tb),
        .S2(S2_tb)
    );
    
    memoria_ins utH (

        .ads(PC_tb),
        .dout(IR_tb),
        .rs1(Ra_tb),
        .rs2(Rb_tb),
        .rd(Rw_tb),
        .opcode(opcode_tb)
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
        .data_out(doutIR_tb)

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
        .dout_pc(PC_tb),
        .imm(imm_tb),
        .soma(somaimm_tb)
    );

    Mux3 ihs (
        .four_some(somafour_tb),
        .imm_some(somaimm_tb),
        .flag(flag_tb),
        .S3(C_tb)
    );


    initial $dumpfile("testbench.vcd");
    initial $dumpvars(0, testbench);

    initial 
    begin
        
        //*******************************Abaixo é a simulação: ********************************************************************

        // começa BEQ

        sinalMux1_tb = 0;
        clock_tb = 0;
        sinalMux2_tb = 0;
        weIR_tb = 1;
        weMem_tb = 0;
        wePC_tb = 0;

        #10
        #10
        #10
        #10
        #10
        $display("%d", flag_tb);
        // #10
        // wePC_tb= 1;
        // $display("%d", flag_tb);
        #10
        #10
        weMem_tb = 1;
        #10


        


    


       
$finish;

     
    end

        always #10 clock_tb = ~clock_tb;
    
    



endmodule