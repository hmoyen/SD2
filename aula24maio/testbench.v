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
    reg weMem_tb, wePC_tb, weIR_tb, weMemIns_tb;
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
        .we(weMemIns_tb),
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

        //************** Começa BEQ ******************************************************************
        // Primeiro, vamos comparar o que tem no registrador 1 e 2. Se forem iguais,a flag indica TRUE
        // e pulamos para a instrução BLT. Vamos testar:

        sinalMux1_tb = 1; // Seleciona doutB
        clock_tb = 0; // Inicializa o clock
        sinalMux2_tb = 0; // Don't care se o que vai para o Din do Banco de Registradores é o resultado da soma ou a saída da memória
        weIR_tb = 1; // Para registrar a instrução atual
        weMem_tb = 0; // Não vamos escrever nada na memória
        weMemIns_tb = 1;
        weReg_tb = 0; // Não vamos escrever nada no banco de registradores
        wePC_tb = 0; // Como inicializamos uma instrucao, não ativamos o we do PC

        #10
        #10 // Espera dois clocks; Um para a soma e outro para o registrador

        $display("Flag BEQ entre x1 e x2: %d", flag_tb); // Como é verdadeiro (1=1), a flag está como 1. Logo, somamos o imediato (2) ao PC (5).

        //************** Começa BNE *******************************************************
        wePC_tb  = 1; // Vamos mudar a instrução para BNE
        weMemIns_tb =0;
        weIR_tb = 1; // Para registrar a instrução atual
        sinalMux1_tb = 1; // Seleciona doutB
        sinalMux2_tb = 0; // Don't care se o que vai para o Din do Banco de Registradores é o resultado da soma ou a saída da memória
        weMem_tb = 0; // Não vamos escrever nada na memória
        weReg_tb = 0; // Não vamos escrever nada no banco de registradores

        #10
        #10 // Se dermos display da flag aqui, veremos que ela vem para 0 em um dado momento. Analisando o GTK Wave, percebe-se que isso ocorre
            // em razão da mudança de instrução momentaneamente. Como o resultado da soma ainda não foi dado, ele dá a flag em função do último resultado.
        wePC_tb  = 0; // Vamos mudar a instrução para BNE

        #10
        #10

        $display("Flag BNE entre x1 e x3: %d", flag_tb); // Veja que a flag está como 1, pois x1 e x3 são diferentes.

        //************** Começa BLT *******************************************************

        wePC_tb  = 1; // Vamos mudar a instrução para BLT
        weMemIns_tb =0;
        weIR_tb = 1; // Para registrar a instrução atual
        sinalMux1_tb = 1; // Seleciona doutB
        sinalMux2_tb = 0; // Don't care se o que vai para o Din do Banco de Registradores é o resultado da soma ou a saída da memória
        weMem_tb = 0; // Não vamos escrever nada na memória
        weReg_tb = 0; // Não vamos escrever nada no banco de registradores
        
        #10
        #10
        wePC_tb  = 0; 
        #10
        #10
        $display("Flag BLT entre x1 e x3: %d", flag_tb); // Veja que a flag está como 1, pois x1 <x3.

        //************** Começa BGE *******************************************************

        wePC_tb  = 1; // Vamos mudar a instrução para BGE
        weMemIns_tb =0;
        weIR_tb = 1; // Para registrar a instrução atual
        sinalMux1_tb = 1; // Seleciona doutB
        sinalMux2_tb = 0; // Don't care se o que vai para o Din do Banco de Registradores é o resultado da soma ou a saída da memória
        weMem_tb = 0; // Não vamos escrever nada na memória
        weReg_tb = 0; // Não vamos escrever nada no banco de registradores

        #10
        #10
        wePC_tb  = 0; 
        #10
        #10
        $display("Flag BGE entre x1 e x3: %d", flag_tb); // Veja que a flag está como 0, pois x1 <x3.
        
        //************** Começa BLTU *******************************************************

        wePC_tb  = 1; // Vamos mudar a instrução para BLTU
        weMemIns_tb =0;
        weIR_tb = 1; // Para registrar a instrução atual
        sinalMux1_tb = 1; // Seleciona doutB
        sinalMux2_tb = 0; // Don't care se o que vai para o Din do Banco de Registradores é o resultado da soma ou a saída da memória
        weMem_tb = 0; // Não vamos escrever nada na memória
        weReg_tb = 0; // Não vamos escrever nada no banco de registradores

        #10
        #10
        wePC_tb  = 0; 
        #10
        #10
        $display("Flag BLTU entre x5 e x4: %d", flag_tb); // Veja que a flag está como 1, pois x5 <x4.
        #10
        $display(PC_tb);

        //************** Começa BGEU*******************************************************

        wePC_tb  = 1; // Vamos mudar a instrução para BGEU
        weMemIns_tb =0;
        weIR_tb = 1; // Para registrar a instrução atual
        sinalMux1_tb = 1; // Seleciona doutB
        sinalMux2_tb = 0; // Don't care se o que vai para o Din do Banco de Registradores é o resultado da soma ou a saída da memória
        weMem_tb = 0; // Não vamos escrever nada na memória
        weReg_tb = 0; // Não vamos escrever nada no banco de registradores

        #10
        #10
        wePC_tb  = 0; 
        #10
        #10
        $display("Flag BGEU entre x5 e x4: %d", flag_tb); // Veja que a flag está como 0, pois x5 <x4.
        #10

        $display(PC_tb);
        #10


  
        /***********Começa o add********************************************************************/

        /*****Aqui foi feito o BGEU de novo para ir à instrução com endereço 7*********************/

        wePC_tb  = 1; // Vamos mudar a instrução para BGEU
        weMemIns_tb =0;
        weIR_tb = 1; // Para registrar a instrução atual
        sinalMux1_tb = 1; // Seleciona doutB
        sinalMux2_tb = 0; // Don't care se o que vai para o Din do Banco de Registradores é o resultado da soma ou a saída da memória
        weMem_tb = 0; // Não vamos escrever nada na memória
        weReg_tb = 0; // Não vamos escrever nada no banco de registradores

        #10
        #10
        wePC_tb  = 0; 
        #10
        #10
        $display("Endereço agora vale:");
        #10

        $display(PC_tb);
        #10
        #10
        $display("eh o res");
        $display(res_tb);

        /***************Começa o sub*********************************/

        /*Aqui foi feito o BGEU de novo para ir à instrução com endereço 8*/

        wePC_tb  = 1; // Vamos mudar a instrução para BGEU
        weMemIns_tb =0;
        weIR_tb = 1; // Para registrar a instrução atual
        sinalMux1_tb = 1; // Seleciona doutB
        sinalMux2_tb = 0; // Don't care se o que vai para o Din do Banco de Registradores é o resultado da soma ou a saída da memória
        weMem_tb = 0; // Não vamos escrever nada na memória
        weReg_tb = 0; // Não vamos escrever nada no banco de registradores

        #10
        #10
        wePC_tb  = 0; 
        #10
        #10
        $display("Endereço agora vale:");
        #10

        $display(PC_tb);
        #10
        #10
        $display("eh o res");
        $display(res_tb);

        /***************Começa o addi*********************************/

        /*Aqui foi feito o BGEU de novo para ir à instrução com endereço 9*/

        wePC_tb  = 1; // Vamos mudar a instrução para BGEU
        weMemIns_tb =0;
        weIR_tb = 1; // Para registrar a instrução atual
        sinalMux1_tb = 0; // Seleciona imm
        sinalMux2_tb = 0; // Don't care se o que vai para o Din do Banco de Registradores é o resultado da soma ou a saída da memória
        weMem_tb = 0; // Não vamos escrever nada na memória
        weReg_tb = 0; // Não vamos escrever nada no banco de registradores

        #10
        #10
        wePC_tb  = 0; 
        #10
        #10
        $display("Endereço agora vale:");
        #10

        $display(PC_tb);
        #10
        #10
        $display("eh o res");
        $display(res_tb);
        



       
$finish;

     
    end

        always #10 clock_tb = ~clock_tb;
    
    



endmodule
