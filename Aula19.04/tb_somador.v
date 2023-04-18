`timescale 1ns/1ns

module testbench;

    // Inputs
    reg [7:0] a_tb;
    reg [7:0] b_tb;
    reg clock_tb;
    wire sinal_tb;
    wire [8:0] res_tb;
    wire out_tb;
    reg load_tb;

    somador uut (
        .a(a_tb), 
        .b(b_tb),
        .soma(res_tb),
        .sinal(sinal_tb) 

    );

    registrador utt (

        .clk(clock_tb),
        .data_in(res_tb),
        .load(load_tb),
        .data_out(out_tb)
    );

    initial begin
        
        // Observacao: colocar a entrada em binário, pois ao colocar um numero negativo em decimal, o Verilog armazena ele em complemento de 2.
        a_tb =8'b00000001;
        clock_tb = 0;
        b_tb =8'b00000001;
        #100
        load_tb = 1;
        $display(out_tb);
        $finish;
        
        
        
    end

    always  #10 clock_tb = ~clock_tb;
    

endmodule