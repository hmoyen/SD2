`timescale 1ns/1ns

module testbench;


// Inputs

reg signed [8:0] a_tb;
reg signed [8:0] b_tb;

wire signed [8:0] res_tb;
reg clock_tb;

adder utt (
    .a(a_tb),
    .b(b_tb),
    .soma(res_tb)

);

initial begin
    a_tb = 9'b111111111;
    b_tb = 4;
    #100
    $display("%d", res_tb);
    $finish;
end


always #1 clock_tb = ~clock_tb;
    
    



endmodule