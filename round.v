module fd(clock, operando_a, operando_b, sinalMuxFP1, sinalMuxFP2, sinalMuxFP3, sinalMuxFP5, sinalShiftFract, sinalIncOrDec, exp_dif, ula, round_fract, resultado);

input [31:0] operando_a, operando_b;
input sinalMuxFP1, sinalMuxFP2, sinalMuxFP3, sinalMuxFP5;
input [7:0] sinalShiftFract;
input clock;
input sinalIncOrDec;
output [31:0] resultado;
output [7:0] exp_dif;
output [26:0] ula, round_fract;

wire [7:0] ula_exp_out;
wire [7:0] reg_exp_out;
wire [7:0] mux1_out;
wire [26:0] mux2_out;
wire [23:0] mux3_out;
wire [26:0] shift_right_out;
wire [26:0] ula_out;
wire [26:0] round_fract_out;
wire [7:0] round_exp_out;
wire [7:0] mux4_out;
wire [7:0] ula_exp_one_out;

assign exp_dif = reg_exp_out; // Saida do registrador da diferença de expoente
assign ula = ula_out; // Saida da ula
assign round_fract = round_fract_out;

ULA_exp ula_exp(
    .a(operando_a[30:23]),
    .b(operando_b[30:23]),
    .sub(ula_exp_out)
);

registrador registrador(
    .data_in(ula_exp_out),
    .data_out(reg_exp_out),
    .clock(clock)
);


MuxFP1 mux_fp1(
    .exp1(operando_a[30:23]),
    .exp2(operando_b[30:23]),
    .sinalMuxFP1(sinalMuxFP1),
    .smallestExp(mux1_out)
);

MuxFP2 mux_fp2(
    .fraction1({operando_a[31],operando_a[22:0]}),
    .fraction2({operando_b[31],operando_b[22:0]}),
    .sinalMuxFP2(sinalMuxFP2),
    .biggerFraction(mux2_out)
);

MuxFP3 mux_fp3(
    .fraction1({operando_a[31],operando_a[22:0]}),
    .fraction2({operando_b[31],operando_b[22:0]}),
    .sinalMuxFP3(sinalMuxFP3),
    .smallerFraction(mux3_out)
);

shift_fraction shift_fraction(
    .b(mux3_out),
    .sinal(sinalShiftFract),
    .res(shift_right_out)
);

ULA_fraction ula_fraction(
    .a(mux2_out),
    .b(shift_right_out),
    .add(ula_out)
);

MuxFP5 mux_fp5 (
    .fraction1(ula_out),
    .fraction2(round_fract),
    .sinalMuxFP5(sinalMuxFP5)
);

MuxFP4 mux_fp4 (
    .exp1(mux1_out),
    .exp2(round_exp_out),
    .sinalMuxFP4(sinalMuxFP4),
    .exp(mux4_out)

);

ULA_exp_one ula_exp_one (
    .b(mux4_out),
    .sinal(sinalIncOrDec),
    .res(ula_exp_one_out)

);

round round (
    .exp_inicial(ula_exp_one_out),
    .fract_inicial()
)


endmodule
module round(exp_inicial, fract_inicial, exp_final, fract_final, sinal, clock);

input clock;
input [7:0] exp_inicial;
output reg [7:0] exp_final;
input [25:0] fract_inicial;
output reg [25:0] fract_final;
wire [25:0] arredondado;
input sinal;

assign arredondado = (fract_inicial[2:0] == 3'b111) ? ({fract_inicial[25:3]+1'b1, 3'b000}):
                           (fract_inicial[2:0] == 3'b101) ? ({fract_inicial[25:3]+1'b1, 3'b000}):
                           (fract_inicial[2:0] == 3'b110) ? ({fract_inicial[25:3]+1'b1, 3'b000}):
                           (fract_inicial[2:0] == 3'b100 && fract_inicial[3]==1'b1) ? ({fract_inicial[25:3]+1'b1, 3'b000}):
                            {fract_inicial[25:3], 3'b000};

always @(posedge clock)
begin
        fract_final <= arredondado; 
        exp_final <= exp_inicial;

end
                           
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

module ULA_exp (b, a, sub);

input signed [7:0] b, a; 
output signed [7:0] sub;

assign soma = a - b;
     
endmodule

module ULA_fraction (b, a, add);

input [26:0] b, a; // Mantissa e o bit de sinal
output [26:0] add; 

assign {sinal, add} = (a[26]|b[26] == 1'b0) ? {1'b0,(a+b)} : // OR com os bits de sinal para verificar se os dois são positivos
              (a[26] == 1'b1 && (a[22:0] > b[22:0])) ? {1'b1,(a-b)}:
              (b[26] == 1'b1 && (b[22:0] > a[22:0])) ? {1'b1,(b-a)}:
              (a[26] == 1'b1 && (a[22:0] < b[22:0])) ? {1'b0,(b-a)}:
              (b[26] == 1'b1 && (b[22:0] < a[22:0])) ? {1'b0,(a-b)}:
              {1'b0, (a+b)};
              
endmodule

module shift_fraction(b, sinal, res);

input [23:0] b;
input [7:0] sinal; //8 bits do expoente 
output [26:0] res;

assign res = {b[23], b[22:0] >> sinal[7:0]};

endmodule

module shift_res(b, sinal, res);

input [26:0] b;
input [8:0] sinal; //o bit mais significativo pra indicar se é direita ou esquerda e 8 bits do expoente. Ainda nao sei exatamente qual será esse sinal 
output [26:0] res;

assign res = (sinal[8] ==1)? {b[26], b[25:0] << sinal[7:0]}:
                            {b[26], b[25:0] >> sinal[7:0]};

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

input [23:0] fraction1;
input [23:0] fraction2;
output [26:0] biggerFraction; // Vai receber shift para a direita e ir pra ULA grande
input sinalMuxFP2;

assign biggerFraction = (sinalMuxFP2 == 1'b0) ? (fraction1) : (fraction2);

endmodule

module MuxFP3 (fraction1, fraction2, sinalMuxFP3, smallerFraction);

input [23:0] fraction1;
input [23:0] fraction2;
output [23:0] smallerFraction; // Vai para ULA grande
input sinalMuxFP3;

assign smallerFraction = (sinalMuxFP3 == 1'b0) ? {(fraction1),3'b000} : {(fraction2), 3'b000};

endmodule

module MuxFP4 (exp1, exp2, sinalMuxFP4, exp);

input [7:0] exp1;
input [7:0] exp2;
output [7:0] exp; // Será incrementado ou decrementado
input sinalMuxFP4;

assign exp = (sinalMuxFP4 == 1'b0) ? (exp1) : (exp2);

endmodule

module MuxFP5 (fraction1, fraction2, sinalMuxFP5, fraction);

input [26:0] fraction1;
input [26:0] fraction2;
output [26:0] fraction; // receberá shift para a direita ou esquerda
input sinalMuxFP5;

assign fraction = (sinalMuxFP5 == 1'b0) ? (fraction1) : (fraction2);

endmodule
