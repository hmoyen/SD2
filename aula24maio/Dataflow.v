module ULA (b, a, sinal, soma, flag);

input signed [63:0] b, a; 
input [31:0] sinal; // Vem da IR
output signed [63:0] soma;
wire flagBEQ, flagBLT, flagBLTU;
output flag;
wire is_negative;

// Como nao temos uma UC para fazer o controle da ULA, a ULA recebe a palavra de 32 bits e analisa o opcode
// e funct7 (para diferenciar ADD e SUB) e faz subtração ou adição dependendo do que foi lido
// O sinal(instrução por enquanto) vem do IR

wire unsigned [63:0] au, bu;
wire unsigned [63:0] soma_;


assign au = a[63:0];
assign bu = b[63:0];
assign {is_negative, soma_} = au - bu; // Se der overflow, eh negativo e portanto a < b
// assign b_ = ~b + 1; // Transforma o que foi recebido para ser interpretado como unsigned (BLTU e BGEU)

// reg agora vai ter unsigned p a e p b, em vez do padrao ser unsigned

assign soma = (sinal[6:0] == 7'b0000011) ? (a + b): // load
                        (sinal[6:0] == 7'b0100011) ? (a + b): // store
                        (sinal[6:0] == 7'b0110011 && sinal[31:25] == 0 ) ? (a + b): // add - pega opcode e func7 p verificar se soma mesmo
                        (sinal[6:0] == 7'b0010011) ? (a + b): // addi
                        // (sinal[6:0] == 7'b1100011 && sinal[14:12]== 3'b110) ? (au + b_): // BLTU, analisamos o funct3
                        // (sinal[6:0] == 7'b1100011 && sinal[14:12]== 3'b111) ? (au + b_): // BGEU
                                                                                (a - b); // as outras (sub, por exemplo, que tem opcode igual ao add, mas funct7 diferente)

// assign soma_u = (sinal[6:0] == 7'b1100011 && sinal[14:12]== 3'b110) ? (au - bu): // BLTU, analisamos o funct3
//                 (sinal[6:0] == 7'b1100011 && sinal[14:12]== 3'b111) ? (au - bu): // BGEU, analisamoso funct3
//                                                                        (au+bu);

assign flagBEQ = (soma == 0) ? 1:
                               0;
assign flagBLT = (soma < 0) ? 1:
                              0;
assign flagBLTU = (is_negative == 1) ? 1:
                                    0;

 
// always@(a or b)
//     begin
//         if(sinal[6:0] == 7'b1100011 )
//             case(sinal[14:12])
//                 3'b000 : flag <= flagBEQ;
//                 3'b001 : flag <= !flagBEQ;
//                 3'b100 : flag <= flagBLT;
//                 3'b101 : flag <= !flagBLT;
//                 3'b110 : flag <= flagBLT;
//                 3'b111 : flag <= !flagBLT;
//                 default : flag <= 0;
//             endcase
//         else
//             flag <= 0;


//     end

assign flag = (sinal[6:0] == 7'b0000011) ? 0: // load
             (sinal[6:0] == 7'b0100011) ? 0: // store
             (sinal[6:0] == 7'b0110011) ? 0: // add
             (sinal[6:0] == 7'b0010011) ? 0: // addi
             (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b000) ? flagBEQ: // BEQ
             (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b001) ? !flagBEQ: // BNE
             (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b100) ? flagBLT: // BLT
             (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b101) ? !flagBLT: // BGE
             (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b110) ? flagBLTU: // BLTU
             (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b111) ? (!flagBLTU): // BGEU
                                                                            0;

// always@(flagBEQ) begin
//     $display("Flag BEQ:  %d",flagBEQ);
//     $finish;
// end
    
     
endmodule

module somador_four(dout_pc, soma);

input [31:0] dout_pc;
output [31:0] soma;

assign soma = {dout_pc<<2} + 4; // Shift left, pois o PC está em unidade de instrução e não de 4 em 4

endmodule

module somador_imm(dout_pc, imm, soma);

input [31:0] dout_pc;
input [63:0] imm;
output [31:0] soma;

assign soma = {dout_pc<<2} + imm[31:0]; // Shift left, pois o PC está em unidade de instrução e não de 4 em 4

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
    
end

  // Read operation
  assign dout = (we) ? din : registradores[ads];
  
  // Write operation
  always @(posedge we)
    registradores[ads] <= din;

endmodule

module memoria_ins(ads, dout, rs1, rs2, rd, opcode, we);
  
input [31:0] ads; // Program counter (PC) in RISC-V is 32 bits long (can addres 2³² instructions)
input we;
output [31:0] dout;
output [4:0] rs1;
output [4:0] rd;
output [4:0] rs2;
output [6:0] opcode;


    // add: 0110011 (funct7 = 0000000, funct3 = 000)
    // sub: 0110011 (funct7 = 0100000, funct3 = 000)
    // addi: 0010011 (funct3 = 000)
    // beq: 1100011 (funct3 = 000)
    // bne: 1100011 (funct3 = 001)
    // blt: 1100011 (funct3 = 100)
    // bge: 1100011 (funct3 = 101)
    // bltu: 1100011 (funct3 = 110)
    // bgeu: 1100011 (funct3 = 111)
    // load (e.g., lw, lh, lb): 0000011
    // store (e.g., sw, sh, sb): 0100011

reg signed [31:0] registradores [31:0]; // Registradores

initial begin


   // --------Palavras de instrução --------------------------------------------------
   // O imediato nas branch instructions podem ser colocadas em "unidade" de instrução 
   // Por exemplo, para ir para duas instruções para frente, colocamos no imediato "2"
   // Depois do sign extend do imediato, fazemos um shift left 2, multiplicando por 4
   // Ou seja, indo do registrador[i] para o registrador [i+8], o que seria, justamente, duas instruções para frente

    // registradores[0] = 32'b00000000010100011011000010000011; //LOAD no x1 do que tem no x2 #3 (endereço = 5) da memoria
    // registradores[1] = 32'b00000000001000010011001000100011; // STORE no x2 #4 do que tem no x2 do banco de registradores
    // registradores[2] = 32'b00000000001000001000000110110011; // ADD de x1 e x2 e registra em x3 (tudo no banco de registradores)
    // registradores[3] = 32'b01000000001000001000001000110011; //SUB de x1 e x2 e registra em x4 (tudo no banco de registradores)
    // registradores[4] = 32'b00000000001100001000001010010011; // ADDI de x1 e 3 e registra em x5 (tudo no banco de registradores)
    // // registradores[5] = 32'b00000000000100000100000101100011; // BEQ, compara x1 e x2, caso TRUE, vai para BNE
    // registradores[6] = 32'b00000000001000001000000001100011; // BLT
    // registradores[7] = 32'b00000000000100000100100001100011; // BNE, compara x1 e x2, caso TRUE, vai para BLTU
    registradores[0] = {1'b0, 6'b000000, 5'b00001, 5'b00010, 3'b000, 4'b0010, 1'b0, 7'b1100011}; // BEQ, compara x1 e x2, caso TRUE vai para BNE
    registradores[1] = {1'b0, 6'b000000, 5'b00001, 5'b00011, 3'b100, 4'b0010, 1'b0, 7'b1100011}; // BLT, compara x1 e x3, caso TRUE, vai para BGE
    registradores[2] = {1'b1, 6'b111111, 5'b00001, 5'b00011, 3'b001, 4'b1111, 1'b1, 7'b1100011}; // BNE, compara x1 e x3, caso TRUE, vai para BLT
    registradores[3] = {1'b1, 6'b111111, 5'b00001, 5'b00011, 3'b101, 4'b1111, 1'b1, 7'b1100011}; // BGE, compara x1 e x3, caso FALSE, vai para o próximo (BLTU)
    registradores[4] = {1'b1, 6'b000000, 5'b00100, 5'b00101, 3'b110, 4'b0010, 1'b0, 7'b1100011}; // BLTU, compara x5 e x4, caso TRUE, vai para BGEU
    registradores[6] = {1'b0, 6'b000000, 5'b00100, 5'b00101, 3'b111, 4'b0010, 1'b0, 7'b1100011}; // BGEU, compara x5 e x4, caso TRUE, vai para ...

    // Nao existe SUBI, como podemos apenar colocar o imediato do ADDI (sempre lido como complemento de 2) como um numero negativo

    
end


assign dout = (we) ? registradores[0] : registradores[ads];
assign rd = (we) ? registradores[0][11:7] : registradores[ads][11:7]; // Write addres for the registers in LOAD, ADD, SUB, ADDI instructions
assign rs1 = (we) ? registradores[0][19:15] : registradores[ads][19:15]; // Read addres for the registers in LOAD, ADD, SUB, STORE, ADDI, BNE, ... instructions
assign rs2 = (we) ? registradores[0][24:20] : registradores[ads][24:20]; // Another read addres for the registers in ADD, SUB, STORE, BNE, BEQ, ... instructions
assign opcode = (we) ? registradores[0][6:0] : registradores[ads][6:0]; // Opcode in all instructions


// Read operations
// assign dout =  registradores[ads];
// assign rd = registradores[ads][11:7]; // Write addres for the registers in LOAD, ADD, SUB, ADDI instructions
// assign rs1 = registradores[ads][19:15]; // Read addres for the registers in LOAD, ADD, SUB, STORE, ADDI, BNE, ... instructions
// assign rs2 = registradores[ads][24:20]; // Another read addres for the registers in ADD, SUB, STORE, BNE, BEQ, ... instructions
// assign opcode = registradores[ads][6:0]; // Opcode in all instructions


endmodule

module PC(clock, r_enable, data_in, data_out);

input             clock;
input             r_enable;
input      [31:0] data_in;
output reg [31:0] data_out;

initial begin
    data_out <=0;

end

always @(posedge clock)
begin
    if(r_enable)
        data_out <= data_in[7:2]; 
end

endmodule


module IR(clock, r_enable, data_in, data_out);

input             clock;
input             r_enable;
input      [31:0] data_in;
output reg [31:0] data_out;
output reg [6:0] opcode;

always @(posedge clock)
begin
    if(r_enable) begin
        data_out <= data_in[31:0]; // Sai a palavra de 32 bits
    end

end

endmodule

module imm_generator(
    palavra, // Vem da IR
    opcode, // Vem da Memoria de Instrução
    imm
);

input signed [31:0] palavra;
input [6:0] opcode;
output signed [63:0] imm;

wire signed [11:0] imm_field;

  // Select the appropriate bits for the immediate field based on the opcode (in case we dont need immediate, it takes the default field)
  assign imm_field = (opcode == 7'b0000011) ? palavra[31:20] : // LOAD
                     (opcode == 7'b0100011) ? {palavra[31:25],palavra[11:7]} : // STORE
                     (opcode == 7'b1100011) ? {palavra[31],palavra[7], palavra[30:25],palavra[11:8]}  : // BRANCH INSTRUCTIONS (BEQ, BNE, etc)
                     (opcode == 7'b0010011) ? palavra[31:20] : // ADDI
                                              palavra[31:20]; // ADD, SUB -> don't care

  // Sign-extend the immediate field to 64 bits and shifts left by 2 if it is a branch instruction
  assign imm = (opcode == 7'b1100011) ? {{50{imm_field[11]}}, imm_field} << 2:
                                        {{64{imm_field[11]}}, imm_field}; // se não for branch instruction, apenas faz o signal extend

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

    

endmodule

module Mux1 (imm , doutB, sinalMux, S1 );

input signed [63:0] doutB;
input signed [63:0] imm; // Imediato extendido
output signed [63:0] S1;
input sinalMux;


assign S1 = (sinalMux == 1'b0) ? imm: doutB;
            
endmodule


module Mux2 (dout, soma ,sinalMux, S2);

input signed [63:0] dout, soma;
output signed [63:0] S2;
input sinalMux;


assign S2 = (sinalMux == 1'b0) ? (dout):(soma);
            
endmodule

module Mux3 (imm_some, four_some, flag, S3);

input [31:0] imm_some; // Vem do somador_imm
input [31:0] four_some; // Vem do somador_four
output [31:0] S3; // Vai para o PC
input flag; // Vem da ULA


assign S3 = (flag == 1'b0) ? (four_some):(imm_some);
            
endmodule