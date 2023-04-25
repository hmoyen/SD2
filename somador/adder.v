module adder (a,b,sinal, soma);

input signed [8:0] a, b;
output signed [8:0] soma;
input sinal;


assign soma = (sinal == 1'b0) ? (a + b):
              (a-b);
            
endmodule