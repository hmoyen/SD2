// **********GRUPO ************
// Helena Bianchi Moyen
// Luiz Mariano
// Mariana Watanabe


`timescale 1ns/1ns

module testbench;

    wire [53:0] produto_tb;
    reg clock_tb;
    reg reset_tb;
    reg [26:0] multiplicando_tb;
    reg [26:0] multiplicador_tb;


    ULA_Float ULA(
        .clock(clock_tb),
        .reset(reset_tb),
        .multiplicando(multiplicando_tb),
        .multiplicador(multiplicador_tb),
        .produto(produto_tb)
    );


    initial $dumpfile("testbench.vcd");
    initial $dumpvars(0, testbench);

    initial 
    begin
        
        //*******************************Abaixo é a simulação: ********************************************************************

        clock_tb  = 0;
        reset_tb = 1;
        multiplicador_tb = 27'b110000000000000000000000000; //1.5
        multiplicando_tb = 27'b110000000000000000000000000;//1.5
        #10
        reset_tb = 0;
        #1000
        $display("Fim da simulação: %b", produto_tb);
        $finish;

     
    end

        always #10 clock_tb = ~clock_tb;
    
    

endmodule
