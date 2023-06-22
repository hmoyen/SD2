// **********GRUPO ************
// Helena Bianchi Moyen
// Luiz Mariano
// Mariana Watanabe


`timescale 1ns/1ns

module testbench;

    reg [31:0] operando_a_tb, operando_b_tb;
    reg sinalMuxFP1_tb, sinalMuxFP2_tb, sinalMuxFP3_tb, sinalMuxFP4_tb, sinalMuxFP5_tb;
    reg [7:0] sinalShiftFract_tb;
    reg [8:0] sinalShiftRes_tb;
    reg [8:0] sinalIncOrDec_tb;
    reg sinalRound_tb;
    reg clock_tb;

    wire [31:0] resultado_tb;
    wire [7:0] exp_dif_tb;
    wire [26:0] ula_tb, round_fract_tb;

    fd fd(
        .clock(clock_tb), 
        .operando_a(operando_a_tb), 
        .operando_b(operando_b_tb),
        .sinalMuxFP1(sinalMuxFP1_tb), 
        .sinalMuxFP2(sinalMuxFP2_tb), 
        .sinalMuxFP4(sinalMuxFP4_tb),
        .sinalMuxFP3(sinalMuxFP3_tb), 
        .sinalMuxFP5(sinalMuxFP5_tb), 
        .sinalShiftFract(sinalShiftFract_tb), 
        .sinalShiftRes(sinalShiftRes_tb), 
        .sinalIncOrDec(sinalIncOrDec_tb), 
        .sinalRound(sinalRound_tb), 
        .exp_dif(exp_dif_tb), 
        .ula(ula_tb), 
        .round_fract(round_fract_tb), 
        .resultado(resultado_tb)
    );

    initial $dumpfile("testbench.vcd");
    initial $dumpvars(0, testbench);

    initial 
    begin
        
        //*******************************Abaixo é a simulação: ********************************************************************
        clock_tb =0;
        operando_a_tb = 32'b00111111110000000000000000000000; // 1,5
        operando_b_tb = 32'b00111111000000000000000000000000; // 0,5
        sinalMuxFP1_tb = 0; // exp de 0,5 eh menor que de 1,5
        sinalMuxFP2_tb = 0; // a > b
        sinalMuxFP3_tb = 1; // b < a
        sinalMuxFP5_tb = 0;
        sinalShiftFract_tb = 1; // shift de b em 1
        sinalShiftRes_tb  = 9'b100000000; // nao precisamos shiftar nada (mantissa eh 0)
        sinalIncOrDec_tb  = 9'b000000000; // 
        sinalMuxFP4_tb = 0;
        sinalRound_tb = 0;
        // esperado: 01000000000000000000000000000000 =
        #50
        $display("Resultado de 1,5 + 0,5: %b", resultado_tb);
        operando_a_tb = 32'b00111111101000100100110111010011; // 1,268
        operando_b_tb = 32'b01000000000111010010111100011011; // 2,456
        // esperado : 01000000011011100101011000000100 = 3,724
        sinalMuxFP1_tb = 1; // exp de 1,268 eh menor que de 2,456
        sinalMuxFP2_tb = 1; // b > a (em modulo)
        sinalMuxFP3_tb = 0; // a < b (eme modulo)
        sinalMuxFP5_tb = 0;
        sinalShiftFract_tb = 1; // shift de a em 1
        sinalShiftRes_tb  = 9'b100000001; // shift de um para esquerda 
        sinalIncOrDec_tb  = 9'b100000001; // decrementa 1, pois shiftamos uma vez para a esquerda
        sinalMuxFP4_tb = 0;
        sinalRound_tb = 0;
        #50
        $display("Resultado de 1,268 + 2,456 %b", resultado_tb);
        operando_a_tb = 32'b10111111101000100100110111010011; // -1,268
        operando_b_tb = 32'b01000000000111010010111100011011; // 2,456
        // esperado : 00111111100110000001000001100011 = 1,188000
         //           00111111100110000001000001100011
        sinalMuxFP1_tb = 1; // exp de 1,268 eh menor que de 2,456
        sinalMuxFP2_tb = 1; // b > a (em modulo)
        sinalMuxFP3_tb = 0; // a < b (em modulo)
        sinalMuxFP5_tb = 0;
        sinalShiftFract_tb = 1; // shift de a em 1
        sinalShiftRes_tb  = 9'b100000010; // shift de dois para esquerda 
        sinalIncOrDec_tb  = 9'b100000010; // decrementa 2, pois shiftamos duas vezes para a esquerda
        sinalMuxFP4_tb = 0;
        sinalRound_tb = 0;
        #100
        $display("Resultado de - 1,268 + 2,456 %b", resultado_tb);


        $display("Fim da simulação");
        $finish;

     
    end

        always #10 clock_tb = ~clock_tb;
    
    



endmodule