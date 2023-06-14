
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

    wire clock; // Clock (3 vezes mais devagar que o da UC)
    // reg rst_n; // ~Reset
    wire [3:0] alu_control; // Controle da ULA feita pelo módulo ALU_Control
    wire funct7; // Da memória de instrução para a ALU_Control (bit 30 da instrução)
    wire [2:0] funct3; // Da memória de instrução para a ALU_Control (os 3 bits do funct 3)
    wire signed [63:0] res; // Resultado da ULA
    wire [4:0] Rw; // Endereço de escrita do RF
    wire [4:0] Ra, Rb; // Endereços de leitura do RF
    wire signed [63:0] doutA; // Dados do RF
    wire signed [63:0] doutB; // Dados do RF e entrada para a memória de dados
    wire signed [63:0] S1; // Saída do MUX1
    wire signed [63:0] S2; // Saída do MUX2
    wire [31:0] S3; // Saída do MUX3
    wire [31:0] PC;// Saída do PC
    wire [31:0] doutIR; // Saída do IR
    wire signed [63:0] imm; // Imediato
    wire [31:0] somafour, somaimm; // Soma PC+4 e soma Imm+PC
    reg [2:0] contador_clock; // Contador de clock para redução
    wire sinalMux3;

    assign d_mem_addr = res; // Fio de saída da ULA
    assign d_mem_data = (d_mem_we == 1) ? doutB: 64'bz; 
    assign i_mem_addr = PC;

    initial begin
        contador_clock <= 0;
    end
    
     assign clock = (contador_clock >= 2) ? 1:
                                            0;
     always@(posedge clk)
     begin
        contador_clock = contador_clock + 1;
        if(contador_clock == 4) 
            contador_clock <= 0;
     end

    ULA uut (
        .a(doutA), // Saída do RF
        .b(S1), // Saída do MUX1
        .soma(res), // Saída da ULA
        .sinal(alu_control), // sinal para soma, subtração, and ou or
        .alu_flags(alu_flags) // Flags (zero, MSB, overflow)
    );

    ALU_Control crtl (

        .alu_cmd(alu_cmd), // Vem da UC
        .funct7(funct7), // Vem do IR
        .funct3(funct3), // Vem do IR
        .control(alu_control) // Vai para ULA
    );

    registrador utt (
        .clk(clk),
        .din(S2), // Vem do MUX2
        .we(rf_we), // Write-enable do RF
        .Rw(Rw), 
        .Ra(Ra),
        .Rb(Rb),
        .doutA(doutA),
        .doutB(doutB)
    );

    Mux1 utv (
        .imm(imm),
        .doutB(doutB),
        .sinalMux(alu_src),
        .S1(S1)
    );

    Mux2 uvv (
        .doutMem(d_mem_data),
        .soma(res),
        .rf_src(rf_src),
        .S2(S2)
    );
    

    PC uhh(
        .clock(clock),
        .data_in(S3),
        .data_out(PC),
        .rst_n(rst_n)
    );

    AND_gate gate( 
        .alu_flags(alu_flags),
        .pc_src(pc_src),
        .sinalMux3(sinalMux3)
    );

    IR huu (
        .clock(clk),
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
        .PC(PC),
        .imm(imm),
        .soma(somaimm)
    );

    Mux3 ihs (
        .four_some(somafour),
        .imm_some(somaimm),
        .sinalMux3(sinalMux3),
        .S3(S3)
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

module ALU_Control(
input [3:0] alu_cmd,
input funct7, input [2:0] funct3,
output [3:0] control);

assign control = (alu_cmd == 4'b0000 && {funct7,funct3} == 4'b0000) ?  4'b0010: // ADD (R-type)
                 (alu_cmd == 4'b0000 && {funct7,funct3} == 4'b1000) ? 4'b0110: // SUB (R-type)
                 (alu_cmd == 4'b0000 && {funct7,funct3} == 4'b0111) ? 4'b0000: // AND (R-type)
                 (alu_cmd == 4'b0000 && {funct7,funct3} == 4'b0110) ? 4'b0001: // OR (R-type)
                 (alu_cmd == 4'b0001) ? 4'b0010: // LOAD (I - type)
                 (alu_cmd == 4'b0010) ? 4'b0010: // STORE (S-type)
                 (alu_cmd == 4'b0011) ? 4'b0110: //BEQ (SB - type)
                                        4'bxxxx; // default 

endmodule

module ULA (b, a, sinal, soma, alu_flags);

input signed [63:0] b, a; 
input [3:0] sinal; // Vem da ALU_Control
output signed [63:0] soma;
output [3:0] alu_flags; // zero, MSB, overflow e x (don't care)
wire overflow;
wire MSB;
wire zero;
wire soma_;

assign {overflow, soma_ } = a + b; // Checando se deu overflow na soma (inacabado, ainda nao estamos utilizando em nenhuma instrução)

assign soma = (sinal == 4'b0010) ? (a+b): //ADD, LOAD, STORE
              (sinal == 4'b0000) ? (a&b): //AND
              (sinal == 4'b0001) ? (a|b): //OR
              (sinal == 4'b0110) ? (a-b): //SUB, BEQ
                                   (a-b); // Outras que por enquanto nao temos
assign MSB = soma[63];
assign zero = (soma == 0) ? 1: 0;
assign alu_flags = {zero, MSB, overflow, 1'b0};
     
endmodule

module somador_four(dout_pc, soma);

input [31:0] dout_pc;
output [31:0] soma;

assign soma = {dout_pc<<2} + 4; // Shift left, pois o PC está em unidade de instrução e não de 4 em 4

endmodule

module somador_imm(PC, imm, soma);

input [31:0] PC;
input [63:0] imm;
output [31:0] soma;

assign soma = {PC << 2} + imm[31:0]; // Shift left, pois o PC está em unidade de instrução e não de 4 em 4

endmodule

module PC (
    input             clock,
    input      [31:0] data_in,
    output reg [31:0] data_out,
    input             rst_n
);

always@(posedge clock, negedge rst_n)
begin
if (~rst_n)
  data_out <= 0;
else
    if(data_in)
        data_out <= data_in[7:2];
end

endmodule


module IR(clock, data_in, data_out, rs1, rs2, rd, opcode, funct7, funct3);

input             clock;
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
        data_out <= data_in[31:0]; // Sai a palavra de 32 bits

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
    output signed [64-1:0] doutA; // Dado de saída
    output signed [64-1:0]  doutB; // Dado de saída
    input [4:0] Rw; // Vai vir da memoria de instrução
    input [4:0] Ra; // Vai vir da memoria de instrução
    input [4:0] Rb; // Vai vir da memoria de instrução

    reg signed [63:0] registradores [31:0]; //Registradores

    initial begin
        
        registradores[0] = 0;
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

        if (we) begin // Se o sinal de carregamento de dados estiver ativo
            registradores[Rw] <= din; // Carrega os dados de entrada no registrador

        end
    end

    assign doutA = registradores[Ra]; // Lê os dados do registrador
    assign doutB = registradores[Rb]; // Lê os dados do registrador 

    always@(registradores[9]) begin

        $display("Conteúdo do x9 no banco de registradores: %d", registradores[9]);
    
    end

    always@(registradores[10]) begin

        $display("Conteúdo do x10 no banco de registradores: %d", registradores[10]);
    
    end

    always@(registradores[12]) begin

        $display("Conteúdo do x12 no banco de registradores: %d", registradores[12]);
    
    end

    always@(registradores[13]) begin

        $display("Conteúdo do x13 no banco de registradores: %d", registradores[13]);
    
    end

endmodule

module Mux1 (imm , doutB, sinalMux, S1 );

input signed [63:0] doutB; // Dados do RF
input signed [63:0] imm; // Imediato extendido
output signed [63:0] S1; 
input sinalMux; 

// Se for 0, doutB eh passado para ULA

assign S1 = (sinalMux == 1'b0) ? doutB: imm;
            
endmodule


module Mux2 (doutMem, soma, rf_src, S2);

input signed [63:0] doutMem, soma; // Saída da memória de dados e da ULA, respectivamente
output signed [63:0] S2;//Saída do MUX
input rf_src; // Sinal de controle

assign S2 = (rf_src == 1) ? (doutMem): (soma);

            
endmodule

module AND_gate(input [3:0] alu_flags, input pc_src, output sinalMux3);

assign sinalMux3 = alu_flags[3]&pc_src;

endmodule

module Mux3 (imm_some, four_some, sinalMux3, S3);

input [31:0] imm_some; // Vem do somador_imm
input [31:0] four_some; // Vem do somador_four
output [31:0] S3; // Vai para o PC
input sinalMux3;  // Resultando de um AND do pc_src e do resultado da ULA

assign S3 = (sinalMux3 == 1'b0) ? (four_some): (imm_some);
            
endmodule

