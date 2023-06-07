
// **** COMENTAMOS O CÓDIGO ANTIGO POIS PARAREMOS DE RECEBER A INSTRUÇÃO TODA COMO SINAL DA ULA
// ENTRETANTO, AINDA NAO CHEGAMOS A FAZER OS SINAIS DE CONTROLE PARA TODAS AS INSTRUÇOES
// POR ISSO, VAMOS APENAS CONSIDERAR QUE IREMOS FAZER ADD OU SUB *********************

module ULA (b, a, sinal, soma, flag);

input signed [63:0] b, a; 
input [3:0] sinal; // Vem da ALU_Control
output signed [63:0] soma;
output flag;

//************CÓDIGO ANTIGO**************************************************************************
// wire flagBEQ, flagBLT, flagBLTU;
// wire is_negative;

// wire unsigned [63:0] au, bu;
// wire unsigned [63:0] soma_;


// assign au = a[63:0];
// assign bu = b[63:0];
// assign {is_negative, soma_} = au - bu; // Se der overflow, eh negativo e portanto a < b

// assign b_ = ~b + 1; // Transforma o que foi recebido para ser interpretado como unsigned (BLTU e BGEU)

// reg agora vai ter unsigned p a e p b, em vez do padrao ser unsigned

// assign soma = (sinal[6:0] == 7'b0000011) ? (a + b): // load
//                         (sinal[6:0] == 7'b0100011) ? (a + b): // store
//                         (sinal[6:0] == 7'b0110011 && sinal[31:25] == 0 ) ? (a + b): // add - pega opcode e func7 p verificar se soma mesmo
//                         (sinal[6:0] == 7'b0010011) ? (a + b): // addi
//                         // (sinal[6:0] == 7'b1100011 && sinal[14:12]== 3'b110) ? (au + b_): // BLTU, analisamos o funct3
                        // (sinal[6:0] == 7'b1100011 && sinal[14:12]== 3'b111) ? (au + b_): // BGEU
                                                                                // (a - b); // as outras (sub, por exemplo, que tem opcode igual ao add, mas funct7 diferente)


// assign flagBEQ = (soma == 0) ? 1:
//                                0;
// assign flagBLT = (soma < 0) ? 1:
//                               0;
// assign flagBLTU = (is_negative == 1) ? 1:
//                                       0;

// assign flag = (sinal[6:0] == 7'b0000011) ? 0: // load
//              (sinal[6:0] == 7'b0100011) ? 0: // store
//              (sinal[6:0] == 7'b0110011) ? 0: // add
//              (sinal[6:0] == 7'b0010011) ? 0: // addi
//              (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b000) ? flagBEQ: // BEQ
//              (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b001) ? !flagBEQ: // BNE
//              (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b100) ? flagBLT: // BLT
//              (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b101) ? !flagBLT: // BGE
//              (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b110) ? flagBLTU: // BLTU
//              (sinal[6:0] == 7'b1100011 && sinal[14:12] == 3'b111) ? (!flagBLTU): // BGEU
//              (sinal[6:0] == 7'b1101111) ? 1: // JAL
//              (sinal[6:0] == 7'b1100111) ? 1: // JALR
            
                                                                            // 0;
//*************FIM DO CÓDIGO ANTIGO**********************************************************

assign soma = (sinal == 4'b0010) ? (a+b): //ADD
              (sinal == 4'b0110) ? (a-b): //SUB
                                   (a-b); // outras que por enquanto nao temos
assign flag = 0; //ADD e SUB
    
     
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
input [1:0] sinalMux;


assign S2 = (sinalMux == 2'b00) ? (dout):
            (sinalMux == 2'b01) ? (soma):
            (sinalMux == 2'b10) ? (PC_four):
                                  (PC_imm);
            
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

// Mux 5 (saída PC e testbench)
