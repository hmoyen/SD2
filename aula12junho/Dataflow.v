
// **** COMENTAMOS O CÓDIGO ANTIGO POIS PARAREMOS DE RECEBER A INSTRUÇÃO TODA COMO SINAL DA ULA
// ENTRETANTO, AINDA NAO CHEGAMOS A FAZER OS SINAIS DE CONTROLE PARA TODAS AS INSTRUÇOES
// POR ISSO, VAMOS APENAS CONSIDERAR QUE IREMOS FAZER ADD OU SUB *********************
module fd 
    #(  // Tamanho em bits dos barramentos
        parameter i_addr_bits = 6,
        parameter d_addr_bits = 6
    )(
        input  clk, rst_n,                   // clock borda subida, reset assíncrono ativo baixo
        output [6:0] opcode,                    
        input  d_mem_we, rf_we,              // Habilita escrita na memória de dados e no banco de registradores
        input  [3:0] alu_cmd,                // ver abaixo
        output [3:0] alu_flags,
        input  alu_src,                      // 0: rf, 1: imm
               pc_src,                       // 0: +4, 1: +imm
               rf_src,                       // 0: alu, 1:d_mem
        output [i_addr_bits-1:0] i_mem_addr,
        input  [31:0]            i_mem_data,
        output [d_addr_bits-1:0] d_mem_addr,
        inout  [63:0]            d_mem_data

    );
    // AluCmd     AluFlags
    // 0000: R    0: zero
    // 0001: I    1: MSB 
    // 0010: S    2: overflow
    // 0011: SB
    // 0100: U
    // 0101: UJ

    wire clock;
    reg reset;
    wire [31:0] instruction;
    wire sinalMux5;
    wire sinalMux4;
    wire sinalMux2;
    wire [31:0] S5;
    wire funct7; // Da memória de instrução para a ALUControl
    wire [2:0] funct3; // Da memória de instrução para a ALUControl
    wire [3:0] control; // Da ALUControl para a ULA
    wire signed [63:0] res;
    wire [63:0] doutMem;
    wire [3:0] state_reg;
    wire [4:0] Rw;
    wire [4:0] Ra, Rb;
    wire signed [63:0] doutA;
    wire signed [63:0] doutB;
    wire signed [63:0] S1;
    wire signed [63:0] S2;
    wire signed [63:0] S4;
    wire [31:0] C;
    wire [31:0] PC;
    wire [31:0] doutIR;
    wire flag;
    wire signed [63:0] imm;
    wire [31:0] somafour, somaimm;
    reg [1:0] contador_clock;

    assign d_mem_addr = res; // fio de saída da ULA
    assign i_mem_addr = PC[7:2];

     initial begin //redutor de clock
        contador_clock <= 0;
     end

     assign clock = (contador_clock == 3) ? 1:
                                            0;
     always@(clk)
     begin
        contador_clock = contador_clock + 1;
        if(contador_clock == 3) 
            contador_clock <= 0;
     end

    ULA uut (
        .a(doutA), 
        .b(S1), 
        .soma(res),
        .sinal(alu_cmd),
        .flag(flag)
    );

    registrador utt (

        .clk(clock),
        .din(S2),
        .we(rf_we),
        .Rw(Rw),
        .Ra(Ra),
        .Rb(Rb),
        .doutA(doutA),
        .doutB(doutB)
    );

    memoria utu (

        .ads(res),
        .we(d_mem_we),
        .din(doutB),
        .dout(d_mem_data)
    );

    Mux1 utv (
        .imm(imm),
        .doutB(doutB),
        .sinalMux(alu_src),
        .S1(S1)
    );

    Mux2 uvv (
        .dout(d_mem_data),
        .soma(res),
        .PC_four(somafour),
        .PC_imm(somaimm),
        .sinalMux(rf_src),
        .S2(S2)
    );
    

    PC uhh(
        .clock(clock),
        .r_enable(wePC),
        .data_in(C),
        .data_out(PC)
    );

    IR huu (
        .clock(clock),
        .r_enable(weIR),
        .data_in(i_mem_data),
        .data_out(doutIR),
        .rs1(Ra),
        .rs2(Rb),
        .rd(Rw),
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3)

    );

    imm_generator hii (
        .palavra(doutIR),
        .opcode(opcode),
        .imm(imm)

    );

    somador_four itt(
        .dout_pc(PC),
        .soma(somafour)

    );

    somador_imm its (
        .dout(S4),
        .imm(imm),
        .soma(somaimm)
    );

    Mux3 ihs (
        .four_some(somafour),
        .imm_some(somaimm),
        .flag(flag),
        .S3(C)
    );

    Mux4 iss (
        .doutA(doutA),
        .PC(PC),
        .sinalMux(pc_src),
        .S4(S4)
    );

    Mux5 hhh (
        .dout_PC(PC),
        .tb(instruction),
        .S5(S5),
        .sinalMux(sinalMux5)
    );

//as entradas estao diferentes e por isso precisa criar assign para associar os nomes
              
endmodule

    // AluCmd     AluFlags
    // 0000: R    0: zero
    // 0001: I    1: MSB 
    // 0010: S    2: overflow
    // 0011: SB
    // 0100: U
    // 0101: UJ

module ALUControl(
input [3:0] alu_cmd,
input funct7, input [2:0] funct3,
output [3:0] control);

assign control = (alu_cmd == 4'b0000 && {funct7,funct3} == 4'b0000) ?  4'b0010: // ADD (R-type)
                 (alu_cmd == 4'b0000 && {funct7,funct3} == 4'b0110) ? 4'b0110: // SUB (R-type)
                 (alu_cmd == 4'b0001) ? 4'b1010: // ADDI and LOAD (I - type)
                 (alu_cmd == 4'b0010) ? 4'b0110: // STORE (S-type)
                   (alu_cmd == 4'b0011) ? 4'b1111: //BEQ
                                    4'bxxxx; // default (BEQ)

endmodule

module ULA (b, a, sinal,  soma, flag);

input signed [63:0] b, a; 
input [3:0] sinal; // Vem da ALU_Control
output signed [63:0] soma;
output flag;
wire overflow;

assign {overflow, soma} = a + b; // Checando

assign soma = (sinal == 4'b0010) ? (a+b): //ADD, ADDI, LOAD, STORE
              (sinal == 4'b0110) ? (a+b):
              (sinal == 4'b1010) ? (a+b):
              (sinal == 4'b0110) ? (a-b): //SUB
                                   (a-b); // outras que por enquanto nao temos
assign flag = (sinal == 4'b0000) ? 0: //zero for ADD and SUB
                (sinal == 4'b1010) ? 0: // MSB for I-type
                (sinal == 4'b0110) ? 0 : // overflow for S-type
                1;
// assign alu_flags = (sinal == 4'b0000) ? 0: //zero for ADD and SUB
//                 (sinal == 4'b1010) ? soma[63]: // MSB for I-type
//                 (sinal == 4'b0110 && overflow) ? : // overflow for S-type
//                 0;
     
endmodule

module somador_four(dout_pc, soma);

input [31:0] dout_pc;
output [31:0] soma;

assign soma = {dout_pc<<2} + 4; // Shift left, pois o PC está em unidade de instrução e não de 4 em 4

endmodule

module somador_imm(dout, imm, soma);

input [63:0] dout;
input [63:0] imm;
output [31:0] soma;

assign soma = {dout} + imm[31:0]; 

endmodule


module memoria(ads, we, din, dout);
  
input [63:0] ads; // Perguntar para os prof se o endereço da memoria é de 5 ou 64 bits (como sai do somador, a saída padrão é de 64 bits).
input we;
input signed [63:0] din;
output signed [63:0] dout;
reg signed [63:0] registradores [31:0]; // Registradores

initial begin
   
    registradores[0] = 45;
    registradores[1] = 11;
    registradores[3] = 14;
    
end

  // Read operation
  assign dout = (we) ? din : registradores[ads];
  
  // Write operation
  always @(posedge we)
    registradores[ads] <= din;

    always@(registradores[13]) begin

        $display("Conteúdo registrador 13 da memória: %d", registradores[13]);
    
    end

endmodule


module PC(clock, r_enable, data_in, data_out);

input             clock;
input             r_enable;
input      [31:0] data_in;
output reg [31:0] data_out;

initial begin
    data_out <=0;

end

always @(negedge clock)
begin
    if(r_enable)
        data_out <= data_in[7:2]; 
end

endmodule


module IR(clock, r_enable, data_in, data_out, rs1, rs2, rd, opcode, funct7, funct3);

input             clock;
input             r_enable;
input      [31:0] data_in;
output  reg   [31:0] data_out;
output [6:0] opcode;
output  [4:0] rs1;
output  [4:0] rd;
output  [4:0] rs2;
output  funct7;
output  [2:0] funct3;


always @(posedge clock)
begin
    if(r_enable) begin
        data_out <= data_in[31:0]; // Sai a palavra de 32 bits
    end

end

assign rd = data_out[11:7]; // Write addres for the registers in LOAD, ADD, SUB, ADDI instructions
assign rs1 =  data_out[19:15]; // Read addres for the registers in LOAD, ADD, SUB, STORE, ADDI, BNE, ... instructions
assign rs2 = data_out[24:20]; // Another read addres for the registers in ADD, SUB, STORE, BNE, BEQ, ... instructions
assign opcode =  data_out[6:0]; // Opcode in all instructions
assign funct7 =  data_out[30]; // For ADD and SUB
assign funct3 =  data_out[14:12]; // For ADD and SUB

endmodule

module imm_generator(
    palavra, // Vem da IR
    opcode, // Vem da Memoria de Instrução
    imm
);

input signed [31:0] palavra;
input [6:0] opcode;
output signed [63:0] imm;

wire signed [11:0] imm_field_typeA; // LOAD, STORE, BRANCH, ADD, SUB, ADDI...
wire signed [19:0] imm_field_typeB; // AUIPC

  // Select the appropriate bits for the immediate field based on the opcode (in case we dont need immediate, it takes the default field)
assign imm_field_typeA = (opcode == 7'b0000011) ? palavra[31:20] : // LOAD
                     (opcode == 7'b0100011) ? {palavra[31:25],palavra[11:7]} : // STORE
                     (opcode == 7'b1100011) ? {palavra[31],palavra[7], palavra[30:25],palavra[11:8]}  : // BRANCH INSTRUCTIONS (BEQ, BNE, etc)
                     (opcode == 7'b0010011) ? palavra[31:20] : // ADDI
                                              palavra[31:20]; // ADD, SUB -> don't care e para o JALR
assign imm_field_typeB = (opcode == 7'b0010111) ? palavra[31:12]: // AUIPC
                        (opcode == 7'b1101111) ? {palavra[31], palavra[19:12], palavra[20], palavra[30:21]}: // JAL
                                                                                             palavra[31:12]; 

  // Sign-extend the immediate field to 64 bits and shifts left by 2 if it is a branch instruction
assign imm = (opcode == 7'b1100011) ? {{50{imm_field_typeA[11]}}, imm_field_typeA} << 2:
               (opcode == 7'b0010111) ? {{32{imm_field_typeB[19]}}, imm_field_typeB} << 12: // AUIPC
               (opcode == 7'b1101111) ? {{43{imm_field_typeB[19]}}, imm_field_typeB} << 1: // JAL
                                        {{52{imm_field_typeA[11]}}, imm_field_typeA}; // se não for branch instruction, apenas faz o signal extend

endmodule



module registrador (clk, din, we, Rw, Ra, Rb, doutA, doutB);
    input clk;             // Clock do sistema
    input signed [63:0] din; // Dados de entrada  
    input we;          // Sinal de carregamento de dados
    output reg signed [64-1:0] doutA; // Dado de saída
    output reg signed [64-1:0]  doutB; // Dado de saída
    input [4:0] Rw; // Vai vir da memoria de instrução
    input [4:0] Ra; // Vai vir da memoria de instrução
    input [4:0] Rb; // Vai vir da memoria de instrução

    reg signed [63:0] registradores [31:0]; //Registradores

    initial begin
        
        registradores[0] = 1;
        registradores[1] = 1;
        registradores[2] = 1;
        registradores[3] = 0;
        registradores[4] = 64'b1111111111111111111111111111111111111111111111111111111111111111;
        // registradores[5] = 64'b1111111111111111111111111111111111111111111111111111111111111110;;
        registradores[5] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
        registradores[8] = 62;

    end

    // Temos clock em registradores, por isso vamos usar o always

    always @(posedge clk) begin

        // $display("Registrador do banco onde ocorre o primeiro LOAD:", registradores[1]); 
        // $display("Registrador do banco onde ocorre o primeiro ADD :", registradores[3]); 
        // $display("Registrador do banco onde ocorre o primeiro SUB :", registradores[4]); 
        // $display("Registrador do banco onde ocorre o ADDI :", registradores[2]); 
        // $display("Registrador do banco onde ocorre o SUBI :", registradores[7]); 
        
        

        if (we) begin // Se o sinal de carregamento de dados estiver ativo
            registradores[Rw] <= din; // Carrega os dados de entrada no registrador

        end
        begin
            doutA <= registradores[Ra]; // Lê os dados do registrador 
            doutB <= registradores[Rb]; // Lê os dados do registrador 
        end
        // $display(doutA);
        // $finish;
        

    end

    always@(registradores[9]) begin

        $display("Conteúdo do x9 no banco de registradores: %d", registradores[9]);
    
    end

    always@(registradores[10]) begin

        $display("Conteúdo do x10 no banco de registradores: %d", registradores[10]);
    
    end

    

endmodule

module Mux1 (imm , doutB, sinalMux, S1 );

input signed [63:0] doutB;
input signed [63:0] imm; // Imediato extendido
output signed [63:0] S1;
input sinalMux;


assign S1 = (sinalMux == 1'b0) ? imm: doutB;
            
endmodule


module Mux2 (dout, soma , PC_four, PC_imm, sinalMux, S2);

input signed [63:0] dout, soma;
input signed [31:0] PC_four, PC_imm;
output signed [63:0] S2;
input sinalMux;


assign S2 = (sinalMux == 0) ? (dout):
            (sinalMux == 1) ? (soma):
                                0;
            
endmodule

module Mux3 (imm_some, four_some, flag, S3);

input [31:0] imm_some; // Vem do somador_imm
input [31:0] four_some; // Vem do somador_four
output [31:0] S3; // Vai para o PC
input flag; // Vem da ULA


assign S3 = (flag == 1'b0) ? (four_some):(imm_some);
            
endmodule

module Mux4 (doutA, PC, sinalMux, S4);

input [63:0] doutA;
input [31:0] PC; 
output [63:0] S4; 
input sinalMux; 


assign S4 = (sinalMux == 1'b0) ? (PC << 2):(doutA); // Shift left, pois o PC está em unidade de instrução e não de 4 em 4
            
endmodule

module Mux5 (dout_PC, tb, sinalMux, S5);

input [31:0] dout_PC;
input [31:0] tb; 
output [31:0] S5; 
input sinalMux; 


assign S5 = (sinalMux == 1'b0) ? (dout_PC):(tb); //  Se houver reset, pega a entrada do endereço da instrução pelo testbench
            
endmodule
