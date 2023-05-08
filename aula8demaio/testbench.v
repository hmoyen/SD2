`timescale 1ns/1ns

module testbench;

    // Inputs
    reg clock_tb;
    reg sinal_tb;
    wire signed [63:0] res_tb;
    wire [63:0] doutMem_tb;
    reg weReg_tb;
    reg [63:0] Rw_tb;
    reg [63:0] Ra_tb, Rb_tb;
    wire signed [63:0] doutA_tb;
    wire signed [63:0] doutB_tb;
    wire signed [63:0] S1_tb;
    wire signed [63:0] S2_tb;
    reg weMem_tb, weMemIns_tb, wePC_tb, weIR_tb;
    reg [63:0] dinMemIns_tb;
    reg sinalMux1_tb;
    reg sinalMux2_tb;
    reg signed [63:0] C_tb;
    wire [63:0] PC_tb;
    wire [63:0] IR_tb;
    wire [31:0] doutIR_tb;

    adder uut (
        .a(doutA_tb), 
        .b(S1_tb), 
        .soma(res_tb),
        .sinal(sinal_tb)
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

        .clk(clock_tb),
        .ads(res_tb),
        .we(weMem_tb),
        .din(doutB_tb),
        .dout(doutMem_tb)
    );

    Mux1 utv (
        .C(doutIR_tb),
        .Rb(doutB_tb),
        .sinalMux(sinalMux1_tb),
        .S1(S1_tb)
    );

    Mux2 uvv (
        .dout(doutMem_tb),
        .soma(res_tb),
        .sinalMux(sinalMux2_tb),
        .S2(S2_tb)
    );
    
    memoriaIns utH (

        .clk(clock_tb),
        .ads(PC_tb),
        .we(weMemIns_tb),
        .din(dinMemIns_tb),
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
        .data_out(doutIR_tb)

    );


    initial $dumpfile("testbench.vcd");
    initial $dumpvars(0, testbench);

    initial 
    begin
         //Para simular, precisa-se dar o sinal de clock(que será 0 ou 1), também o sinal do somador(0 se for soma ou 1 se for subtração),
        //Ainda, deve-se fornecer o b_tb que é endereço que será somado com zero(a_tb), e que será o endereço da memória. Por fim, também
        //é necessário fornecer o rw_tb que irá como endereço do registrador no momento do load, e também fornecer o ra_tb que será o endereço
        //onde a informação será lida no registrador. Por fim, é necessário fornecer o we do registrador(weReg_tb) e o we da memória(weReg_tb).
        //*******************************Abaixo é a simulação de um load no registrador: ********************************************************************
    
        wePC_tb = 1;
        weIR_tb =1;
        #10
        clock_tb = 0;
        sinal_tb=0;
        Rw_tb = 1;
        Ra_tb= 0;
        C_tb = 1; // Operação a ser feita (1) -> LOAD (Quero guardar o que está no x0 #0 da memória no endereço 1 do banco de registradores)
        sinalMux1_tb = 0;
        sinalMux2_tb = 0;
        #10
        #10   
        #10

        weReg_tb=1;
        #10
        
      
        // Add -- adicionando o que estava no reg[1] e reg[2] do banco e guardando no reg[3]
        
        Ra_tb = 2;
        Rb_tb = 1;
        Rw_tb = 3;
        C_tb = 3; // Operação a ser feita (3) -> ADD (Quero guardar a soma do x1 e x2 no x3)
        sinalMux1_tb = 1;
        sinalMux2_tb = 1;

        
        #10
        #10
        weReg_tb = 1;
        #10
        weReg_tb = 0;
        //Sub
        C_tb =4;
        Ra_tb = 1;
        Rb_tb = 3;
        Rw_tb = 4;
        sinal_tb = 1;

        #10
        weReg_tb = 1;


      

//*******************************Abaixo é a simulação do store na memória: ********************************************************************
        #10
        Ra_tb = 5;
        Rb_tb = 6;
        weReg_tb = 0;
        sinal_tb = 0;
        sinalMux1_tb = 0;
        sinalMux2_tb = 0;
        C_tb = 2; // Operação a ser feita -> STORE (Quero armazenar no endereço x5 #1 o que está no registrador x6)
        
        #10
        #10
        #10
        weMem_tb=1;

        #10
        
        #10
        weMem_tb=0;
        #10

//*******************************Abaixo é a simulação do addi e subi na memória: ********************************************************************

        #10
        clock_tb = 0;
        sinal_tb=0;
        Rw_tb = 2;
        Ra_tb= 0;
        C_tb = 5; 
        sinalMux1_tb = 0;
        sinalMux2_tb = 1;
        #10
        #10   
        #10

        weReg_tb=1;
        #10

        #10
        clock_tb = 0;
        sinal_tb=0;
        Rw_tb = 7;
        Ra_tb= 0;
        C_tb = 6;
        sinalMux1_tb = 0;
        sinalMux2_tb = 1;
        sinal_tb = 1;
        #10
        #10   
        #10

        weReg_tb=1;
        #10
        




       
$finish;

     
    end

        always #1 clock_tb = ~clock_tb;
    
    



endmodule