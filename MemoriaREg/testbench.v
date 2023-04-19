`timescale 1ns/1ns

module testbench;

    // Inputs
    reg [3:0] a_tb;
    reg [3:0] b_tb;
    reg clock_tb;
    wire sinal_tb;
    wire [4:0] res_tb;
    wire [63:0] doutMem_tb;
    reg weReg_tb;
    reg [4:0] Rw_tb;
    reg [4:0] Ra_tb. Rb_tb;
    wire [63:0] doutA_tb;
    wire [63:0] doutB_tb;
    reg weMem_tb;

    somador uut (
        .a(a_tb), 
        .b(b_tb), 
        .soma(res_tb),
        .sinal(sinal_tb)
    );

    registrador utt (

        .clk(clock_tb),
        .din(doutMem_tb),
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
        .we(weMem),
        .din(doutA_tb),
        .dout(doutMem_tb)
    );

    initial begin
        clock_tb = 0;
        a_tb = 0;
        b_tb = 16;
        weReg_tb = 1;
        #10
        Rw_tb = 




        

        
    end

    always  #10 clock_tb = ~clock_tb;
    



endmodule