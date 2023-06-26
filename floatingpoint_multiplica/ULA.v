module ULA(multiplicador, multiplicando, produto, reset, clock);

input [3:0] multiplicador;
input [3:0] multiplicando;
input reset;
input clock;
output [7:0] produto;

wire [8:0] produto_in;
wire [8:0] produto_out;
wire [8:0] produto_soma;
wire [3:0] multiplicador_shift_in;
wire [3:0] multiplicador_shift_out;
wire [7:0] multiplicando_shift_in;
wire [7:0] multiplicando_shift_out;
wire [8:0] produto_shift;
wire [2:0] N_out;
wire [2:0] N_in;
wire done;

registrador_soma regA (
    .reset(reset),
    .clock(clock),
    .data_in(produto_soma),
    .data_out(produto_out)
);

registrador_N reg_N (
    .reset(reset),
    .clock(clock),
    .data_out(N_out),
    .data_in(N_in),
    .done(done)
);

subtracao sub(
    .N(N_out),
    .reset(reset),
    .sub(N_in)
);

registrador_multiplicador multR(
    .data_in(multiplicador_shift_in),
    .data_out(multiplicador_shift_out),
    .clock(clock),
    .reset(reset)
);

registrador_multiplicando multD(
    .data_in(multiplicando_shift_in),
    .data_out(multiplicando_shift_out),
    .clock(clock),
    .reset(reset)
);


assign multiplicador_shift_in = (reset) ? multiplicador: multiplicador_shift_out >> 1; //Shift do multiplicador
assign multiplicando_shift_in = (reset) ? {4'b0000, multiplicando}: multiplicando_shift_out << 1; // Shift do multiplicando
assign produto_soma = (multiplicador_shift_out[0] == 1) ? (produto_out + multiplicando_shift_out): produto_out; // Soma
assign produto = (done) ? produto_soma: 9'bz; // Produto final

endmodule

module registrador_multiplicador(data_in, data_out, clock, reset);

input             clock;
input      [3:0] data_in;
input               reset;
output  reg   [3:0] data_out;

always @(posedge clock or posedge reset)
begin   
            data_out <= data_in; 

end
endmodule

module registrador_multiplicando(data_in, data_out, clock, reset);

input             clock;
input      [7:0] data_in;
input               reset;
output  reg   [7:0] data_out;

always @(posedge clock or posedge reset)
begin   
            data_out <= data_in; 

end
endmodule

module registrador_soma(clock, data_in, data_out, reset);

input             clock;
input      [8:0] data_in;
input               reset;
output  reg   [8:0] data_out;

always @(posedge clock or posedge reset)
begin   
        if(reset) 
            data_out <=0;
        else 
            data_out <= data_in[8:0]; 

end
endmodule

module subtracao(N, sub, reset);

input [2:0]  N;
input reset;
output [2:0] sub;

assign sub = (~reset) ? N - 1 : N;

endmodule

module registrador_N(clock, data_out, data_in, reset, done);

input             clock;
input               reset;
output  reg   [2:0] data_out;
input           [2:0] data_in;
output   reg          done;

always @(posedge clock or posedge reset)
begin   
        if(reset) begin
            done <=0;
            data_out <= 3'b100;
        end
        else 
            data_out <= data_in[2:0]; 
            if(data_in == 0)
                done <= 1;

end
endmodule
