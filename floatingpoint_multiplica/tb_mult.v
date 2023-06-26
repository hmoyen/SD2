// **********GRUPO ************
// Helena Bianchi Moyen
// Luiz Mariano
// Mariana Watanabe


`timescale 1ns/1ns

module testbench;

    wire [31:0] produto_tb;
    reg clock_tb;
    reg reset_tb;
    reg sinalMuxFP1_tb, sinalRound_tb, sinalMuxFP2_tb;
    reg [31:0] multiplicando_tb;
    reg [31:0] multiplicador_tb;
    reg [8:0] sinalShiftRes_tb;
    reg [8:0] sinalIncOrDec_tb;
    wire [25:0] round_fract_tb;
    wire [53:0] ula_tb;

    fd fd(
        .multiplicador(multiplicador_tb), 
        .multiplicando(multiplicando_tb),
        .produto(produto_tb),
        .clock(clock_tb),
        .sinalMuxFP1(sinalMuxFP1_tb), 
        .sinalShiftRes(sinalShiftRes_tb), 
        .sinalIncOrDec(sinalIncOrDec_tb), 
        .round_fract(round_fract_tb),
        .ula(ula_tb), 
        .reset(reset_tb),
        .sinalRound(sinalRound_tb),
        .sinalMuxFP2(sinalMuxFP2_tb)

        );

    initial $dumpfile("testbench.vcd");
    initial $dumpvars(0, testbench);

    initial 
    begin
        
        //*******************************Abaixo é a simulação: ********************************************************************

        clock_tb  = 0;
        #1
        reset_tb = 1;
        multiplicador_tb = 32'b00111111101001010110000001000010; //1.292
        multiplicando_tb = 32'b00111111110000000000000000000000;//1.5
        sinalMuxFP2_tb = 0; 
        sinalMuxFP1_tb = 0;
        sinalShiftRes_tb  = 9'b100000010; // shift de dois para esquerda 
        sinalIncOrDec_tb  = 9'b100000010;
        #10
        reset_tb = 0;
        #1000
        $display("Fim da simulação: %b", produto_tb);
        $finish;

     
    end

        always #10 clock_tb = ~clock_tb;
    
    

endmodule
