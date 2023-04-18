`timescale 1ns/1ns

module testbench;

    // Inputs
    reg [8:0] a_tb;
    reg [8:0] b_tb;
    wire [3:0] state_tb;
    reg clock_tb;
    reg start_tb;
    wire sinal_tb;
    wire [16:0] res_tb;

    datapath uut (
        .a(a_tb), 
        .b(b_tb), 
        .res(res_tb),
        .clock(clock_tb),
        .sinal(sinal_tb),
        .state(state_tb)
    );

    control_unit utt (

        .clock(clock_tb),
        .start(start_tb),
        .state(state_tb),
        .sinal(sinal_tb)
    );

    initial begin
        start_tb = 1;
        // Observacao: colocar a entrada em binário, pois ao colocar um numero negativo em decimal, o Verilog armazena ele em complemento de 2.
        a_tb =9'b111111111;
        clock_tb = 0;
        b_tb =9'b111111111;
        #10
        start_tb = 0;
        

        
    end

    always  #10 clock_tb = ~clock_tb;
    



endmodule
