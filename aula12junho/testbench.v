// **********GRUPO ************
// Helena Bianchi Moyen
// Luiz Mariano
// Mariana Watanabe


`timescale 1ns/1ns

module testbench;

    reg clock_tb, rst_n_tb;

    processador riscv(
        .clk(clock_tb),
        .rst_n(rst_n_tb)
    );

    initial $dumpfile("testbench.vcd");
    initial $dumpvars(0, testbench);

    initial 
    begin
        
        //*******************************Abaixo é a simulação: ********************************************************************
        clock_tb = 0;
        rst_n_tb = 1;
        #10
        rst_n_tb = 0;

        #1000

        $display("Fim da simulação");
        $finish;

     
    end

        always #10 clock_tb = ~clock_tb;
    
    



endmodule