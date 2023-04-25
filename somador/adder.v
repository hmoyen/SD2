module adder (a,b,soma);

input signed [8:0] a, b;
output signed [8:0] soma;

assign soma = a - b;
    
endmodule