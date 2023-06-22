module fd(clock, operando_a, operando_b, sinalMuxFP1, sinalMuxFP2, sinalMuxFP3, sinalMuxFP4, sinalMuxFP5, sinalShiftFract, sinalShiftRes, sinalIncOrDec, sinalRound, exp_dif, ula, round_fract, resultado);

input [31:0] operando_a, operando_b;
input sinalMuxFP1, sinalMuxFP2, sinalMuxFP3, sinalMuxFP4, sinalMuxFP5;
input [7:0] sinalShiftFract;
input [8:0] sinalShiftRes;
input clock;
input [8:0] sinalIncOrDec;
input sinalRound;
output [31:0] resultado;
output [7:0] exp_dif;
output [26:0] ula, round_fract;


wire [7:0] ula_exp_out;
wire [7:0] reg_exp_out;
wire [7:0] mux1_out;
wire [27:0] mux2_out;
wire [24:0] mux3_out;
wire [27:0] shift_right_out;
wire [27:0] ula_out;
wire [25:0] round_fract_out;
wire [7:0] round_exp_out;
wire [7:0] mux4_out;
wire [27:0] mux5_out;
wire [7:0] ula_exp_one_out;
wire [27:0] shift_res_out;

assign exp_dif = reg_exp_out; // Saida do registrador da diferença de expoente
assign ula = ula_out; // Saida da ula
assign round_fract = round_fract_out;
assign resultado = {shift_res_out[27], round_exp_out, round_fract_out[25:3]};

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
    .greatestExp(mux1_out)
);

MuxFP2 mux_fp2(
    .fraction1({operando_a[31], 1'b1, operando_a[22:0]}),
    .fraction2({operando_b[31], 1'b1, operando_b[22:0]}),
    .sinalMuxFP2(sinalMuxFP2),
    .biggerNumber(mux2_out)
);

MuxFP3 mux_fp3(
    .fraction1({operando_a[31], 1'b1, operando_a[22:0]}),
    .fraction2({operando_b[31], 1'b1, operando_b[22:0]}),
    .sinalMuxFP3(sinalMuxFP3),
    .smallerNumber(mux3_out)
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
    .fraction2({1'b1, round_fract}),
    .sinalMuxFP5(sinalMuxFP5),
    .fraction(mux5_out)
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

shift_res shift_res (
    .b(mux5_out),
    .sinal(sinalShiftRes),
    .res(shift_res_out)
);

round round (
    .exp_inicial(ula_exp_one_out),
    .fract_inicial(shift_res_out[26:1]),
    .clock(clock),
    .sinal(sinalRound),
    .exp_final(round_exp_out),
    .fract_final(round_fract_out)
);


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
    if(sinal) begin
        fract_final <= arredondado; 
    end
    else begin
        fract_final <= fract_inicial;
    end
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

input [7:0] b, a; 
output [7:0] sub;

assign sub = (a>b) ? (a - b): (b - a);
     
endmodule

module ULA_fraction (b, a, add);

input [27:0] b, a; // Mantissa e o bit de sinal
wire [26:0] soma; 
wire overflow;
wire sinal;
output [27:0] add;

assign {sinal, overflow, soma} = (a[27]|b[27] == 1'b0) ? {1'b0,(a+b)} : // OR com os bits de sinal para verificar se os dois são positivos
              (a[27] == 1'b1 && (a[26:0] > b[26:0])) ? {1'b1,(a-b)}:
              (b[27] == 1'b1 && (b[26:0] > a[26:0])) ? {1'b1,(b-a)}:
              (a[27] == 1'b1 && (a[26:0] < b[26:0])) ? {1'b0,(b-a)}:
              (b[27] == 1'b1 && (b[26:0] < a[26:0])) ? {1'b0,(a-b)}:
              {1'b0, (a+b)};

assign add = {sinal, soma};
              
endmodule

module shift_fraction(b, sinal, res);

input [24:0] b;
input [7:0] sinal; //8 bits do expoente 
output [27:0] res;

assign res = (sinal[7:0] == 0) ? {b[24], b[23:0] >> sinal[7:0], 3'b000}:
             (sinal[7:0] == 1) ? {b[24], b[23:0] >> sinal[7:0], b[sinal-1], 2'b00}:
             (sinal[7:0] == 2) ? {b[24], b[23:0] >> sinal[7:0], b[sinal-1], b[sinal-2], 1'b0}:
             {b[24], b[23:0] >> sinal[7:0], b[sinal-1], b[sinal-2], b[sinal-3]};


endmodule

module shift_res(b, sinal, res);

input [27:0] b;
input [8:0] sinal; //o bit mais significativo pra indicar se é direita ou esquerda e 8 bits do expoente. Ainda nao sei exatamente qual será esse sinal 
output [27:0] res;

assign res = (sinal[8] == 1)? {b[27], b[26:0] << sinal[7:0]}:
                            {b[27], b[26:0] >> sinal[7:0]};

endmodule

module ULA_exp_one (b, sinal, res);

input signed [7:0] b; 
input [8:0] sinal;
output signed [7:0] res;

assign res = (sinal[8] == 1'b0) ? (b+sinal[7:0]):
                                  (b-sinal[7:0]); 
     
endmodule

module MuxFP1 (exp1, exp2, sinalMuxFP1, greatestExp);

input [7:0] exp1;
input [7:0] exp2;
output [7:0] greatestExp; // Vai para MuxFP4
input sinalMuxFP1;

assign greatestExp = (sinalMuxFP1 == 1'b0) ? (exp1 + 1'b1) : (exp2 + 1'b1); // adicionando um bit ao expoente pois colocamos o 1 implicito para fazer as contas

endmodule

module MuxFP2 (fraction1, fraction2, sinalMuxFP2, biggerNumber);

input [24:0] fraction1;
input [24:0] fraction2;
output [27:0] biggerNumber; // Vai receber shift para a direita e ir pra ULA grande
input sinalMuxFP2;

assign biggerNumber = (sinalMuxFP2 == 1'b0) ? {(fraction1),3'b000}  : {(fraction2), 3'b000};

endmodule

module MuxFP3 (fraction1, fraction2, sinalMuxFP3, smallerNumber);

input [24:0] fraction1;
input [24:0] fraction2;
output [24:0] smallerNumber; // Vai para ULA grande
input sinalMuxFP3;

assign smallerNumber = (sinalMuxFP3 == 1'b0) ? (fraction1) : (fraction2);

endmodule

module MuxFP4 (exp1, exp2, sinalMuxFP4, exp);

input [7:0] exp1;
input [7:0] exp2;
output [7:0] exp; // Será incrementado ou decrementado
input sinalMuxFP4;

assign exp = (sinalMuxFP4 == 1'b0) ? (exp1) : (exp2);

endmodule

module MuxFP5 (fraction1, fraction2, sinalMuxFP5, fraction);

input [27:0] fraction1;
input [27:0] fraction2;
output [27:0] fraction; // receberá shift para a direita ou esquerda
input sinalMuxFP5;

assign fraction = (sinalMuxFP5 == 1'b0) ? (fraction1) : (fraction2);

endmodule