module fd(multiplicador, multiplicando, produto, clock, sinalMuxFP1, sinalMuxFP2, sinalRound, sinalShiftRes, sinalIncOrDec, round_fract, ula, reset);

input [31:0] multiplicador;
input [31:0] multiplicando;
input sinalMuxFP1, sinalMuxFP2, sinalRound;
input [8:0] sinalIncOrDec;
input [8:0] sinalShiftRes;
input clock, reset;
output [31:0] produto;
output [53:0] ula;
output [25:0] round_fract;

wire [7:0] soma_exp;
wire sinal;
wire [7:0] mux1_out;
wire [27:0] mux2_out;
wire [7:0] round_exp_out;
wire [7:0] round_exp_in;
wire [25:0] round_fract_out;

wire [27:0] shift_res_out;
wire [53:0] ula_out;

assign sinal = multiplicador[31]^multiplicando[31]; //  0 1 -> 1, 1 0 -> 1, 0 0 -> 0, 1 1 -> 0
assign ula = ula_out; // Saida da ula
assign round_fract = round_fract_out;
assign produto = {shift_res_out[27], round_exp_out, round_fract_out[25:3]};


ULA_exp ULA_exp(
    .exp1(multiplicador[30:23]),
    .exp2(multiplicando[30:23]),
    .soma_exp(soma_exp)
);

MuxFP1 mux_fp1 (
    .exp1(soma_exp),
    .exp2(round_exp_out),
    .sinalMuxFP1(sinalMuxFP1),
    .exp(mux1_out)

);

shift_res shift_res (
    .b(mux2_out),
    .sinal(sinalShiftRes),
    .res(shift_res_out)
);

MuxFP2 mux_fp2 (
    .fraction1({sinal,ula_out[53:27]}),
    .fraction2({sinal, 1'b1, round_fract}),
    .sinalMuxFP2(sinalMuxFP2),
    .fraction(mux2_out)
);

ULA_Float ula_f(
    .multiplicador({1'b1, multiplicador[22:0], 3'b000}),
    .multiplicando({1'b1, multiplicando[22:0], 3'b000}),
    .produto(ula_out),
    .reset(reset),
    .clock(clock)
);

ULA_exp_one ula_exp_one(
    .b(mux1_out),
    .sinal(sinalIncOrDec),
    .res(round_exp_in)
);

round round(
    .exp_inicial(round_exp_in),
    .exp_final(round_exp_out),
    .fract_inicial(shift_res_out[26:1]),
    .fract_final(round_fract_out),
    .clock(clock),
    .sinal(sinalRound)
);

endmodule

module ULA_exp(exp1, exp2, soma_exp);

input [7:0] exp1;
input [7:0] exp2;
output [7:0] soma_exp;

assign soma_exp = (exp1-127) + (exp2-127) + 2'b10; 

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

module ULA_exp_one (b, sinal, res);

input [7:0] b; 
input [8:0] sinal;
output [7:0] res;

assign res = (sinal[8] == 1'b0) ? (b+sinal[7:0]+127):
                                  (b-sinal[7:0]+127); 
     
endmodule

module shift_res(b, sinal, res);

input [27:0] b;
input [8:0] sinal; //o bit mais significativo pra indicar se é direita ou esquerda e 8 bits do expoente. Ainda nao sei exatamente qual será esse sinal 
output [27:0] res;

assign res = (sinal[8] == 1)? {b[27], b[26:0] << sinal[7:0]}:
                            {b[27], b[26:0] >> sinal[7:0]};

endmodule

module MuxFP1 (exp1, exp2, sinalMuxFP1, exp);

input [7:0] exp1;
input [7:0] exp2;
output [7:0] exp; // Será incrementado ou decrementado
input sinalMuxFP1;

assign exp = (sinalMuxFP1 == 1'b0) ? (exp1) : (exp2);

endmodule

module MuxFP2 (fraction1, fraction2, sinalMuxFP2, fraction);

input [27:0] fraction1;
input [27:0] fraction2;
output [27:0] fraction; // receberá shift para a direita ou esquerda
input sinalMuxFP2;

assign fraction = (sinalMuxFP2 == 1'b0) ? (fraction1) : (fraction2);

endmodule