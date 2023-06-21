module ULA_exp (b, a, sub);

input signed [7:0] b, a; 
output signed [7:0] sub;

assign soma = a-b;
     
endmodule

module ULA_fraction (b, a, add);

input [22:0] b, a; 
output [22:0] add;

assign soma = a+b;
     
endmodule

module shift_fraction(b, sinal, res);

input [22:0] b;
input [7:0] sinal; //8 bits do expoente 
output [22:0] res;

assign res= {res>>sinal[7:0]};
                           


endmodule

module shift_res(b, sinal, res);

input [22:0] b;
input [8:0] sinal; //o bit mais significativo pra indicar se é direita ou esquerda e 8 bits do expoente. Ainda nao sei exatamente qual será esse sinal 
output [22:0] res;

assign res= (sinal[8]==1)? {res<<sinal[7:0]}:
                            {res>> sinal[7:0]};

endmodule

module ULA_exp_one (b, sinal, res);

input signed [7:0] b; 
input sinal;
output signed [7:0] res;


assign res = (sinal == 1'b0) ? (b+1):
                                (b-1); 
     
endmodule
