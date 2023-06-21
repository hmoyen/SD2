module round(numero, sinal, arredondado);

input [63:0] numero;
output [63:0] arredondado;
input sinal;

assign arredondado[22:3] = (numero[2:0] == 3'b111) ? (numero[22:3]+1'b1):
                           (numero[2:0] == 3'b101) ? (numero[22:3]+1'b1):
                           (numero[2:0] == 3'b110) ? (numero[22:3]+1'b1):
                           (numero[2:0] == 3'b100 && numero[3]==1'b1) ? (numero[22:3]+1'b1):
                            numero[22:3];
                           
endmodule

module registrador(clock, data_in, data_out);

input             clock;
input      [7:0] data_in;
output  reg   [7:0] data_out;


always @(posedge clock)
begin
        data_out <= data_in[7:0]; 

end

endmodule

module normalize(mantissa_inicial, expoente_inicial, expoente_final, mantissa_final, clock);

input [7:0] expoente_inicial;
input [22:0] mantissa_inicial;
input clock;
output reg [7:0] expoente_final;
output reg [22:0] mantissa_final;

always @(posedge clock) begin

    mantissa_final <= mantissa_inicial;
    expoente_final <= expoente_inicial;

    while(mantissa_final[22] != 1'b1) begin

            if(mantissa_final[22] == 0)
            begin
                mantissa_final<=(mantissa_final<<1'b1);  // 0.011111111 -> 1.1111111 x 2⁻²
                expoente_final<=expoente_final-1'b1;
            end
            else begin
                
            end
    end
end

endmodule

module ULA_exp (b, a, sub);

input signed [7:0] b, a; 
output signed [7:0] sub;

assign soma = a-b;
     
endmodule

module ULA_fraction (b, a, add, sinal);

input [23:0] b, a; // Mantissa e o bit de sinal
output [22:0] add; 
output sinal;

assign {sinal, add} = (a[23]|b[23] == 1'b0) ? {1'b0,(a+b)} : // OR com os bits de sinal para verificar se os dois são positivos
              (a[23] == 1'b1 && (a[22:0] > b[22:0])) ? {1'b1,(a-b)}:
              (b[23] == 1'b1 && (b[22:0] > a[22:0])) ? {1'b1,(b-a)}:
              (a[23] == 1'b1 && (a[22:0] < b[22:0])) ? {1'b0,(b-a)}:
              (b[23] == 1'b1 && (b[22:0] < a[22:0])) ? {1'b0,(a-b)}:
              {1'b0, (a+b)};
              
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

module MuxFP1 (exp1, exp2, sinalMuxFP1, smallestExp);

input [7:0] exp1;
input [7:0] exp2;
output [7:0] smallestExp; // Vai para MuxFP4
input sinalMuxFP1;

assign smallestExp = (sinalMuxFP1 == 1'b0) ? (exp1) : (exp2);

endmodule

module MuxFP2 (fraction1, fraction2, sinalMuxFP2, biggerFraction);

input [22:0] fraction1;
input [22:0] fraction2;
output [22:0] biggerFraction; // Vai receber shift para a direita e ir pra ULA grande
input sinalMuxFP2;

assign biggerFraction = (sinalMuxFP2 == 1'b0) ? (fraction1) : (fraction2);

endmodule

module MuxFP3 (fraction1, fraction2, sinalMuxFP3, smallerFraction);

input [22:0] fraction1;
input [22:0] fraction2;
output [22:0] smallerFraction; // Vai para ULA grande
input sinalMuxFP3;

assign smallerFraction = (sinalMuxFP3 == 1'b0) ? (fraction1) : (fraction2);

endmodule

module MuxFP4 (exp1, exp2, sinalMuxFP4, exp);

input [7:0] exp1;
input [7:0] exp2;
output [7:0] exp; // Será incrementado ou decrementado
input sinalMuxFP4;

assign exp = (sinalMuxFP4 == 1'b0) ? (exp1) : (exp2);

endmodule

module MuxFP5 (fraction1, fraction2, sinalMuxFP5, fraction);

input [7:0] fraction1;
input [7:0] fraction2;
output [7:0] fraction; // receberá shift para a direita ou esquerda
input sinalMuxFP5;

assign fraction = (sinalMuxFP5 == 1'b0) ? (fraction1) : (fraction2);

endmodule