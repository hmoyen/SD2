module memoria_ins(ads, dout, rs1, rs2, rd, opcode, funct7, funct3);
  
input [31:0] ads; // Program counter (PC) in RISC-V is 32 bits long (can addres 2³² instructions)
// input reset;
output [31:0] dout;
output [4:0] rs1;
output [4:0] rd;
output [4:0] rs2;
output [6:0] opcode;
output funct7;
output [2:0] funct3;


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

    // registradores[0] = {1'b0, 6'b000000, 5'b00001, 5'b00010, 3'b000, 4'b0010, 1'b0, 7'b1100011}; // BEQ, compara x1 e x2, caso TRUE vai para BNE
    // registradores[1] = {1'b0, 6'b000000, 5'b00001, 5'b00011, 3'b100, 4'b0010, 1'b0, 7'b1100011}; // BLT, compara x1 e x3, caso TRUE, vai para BGE
    // registradores[2] = {1'b1, 6'b111111, 5'b00001, 5'b00011, 3'b001, 4'b1111, 1'b1, 7'b1100011}; // BNE, compara x1 e x3, caso TRUE, vai para BLT
    // registradores[3] = {1'b1, 6'b111111, 5'b00001, 5'b00011, 3'b101, 4'b1111, 1'b1, 7'b1100011}; // BGE, compara x1 e x3, caso FALSE, vai para o próximo (BLTU)
    // registradores[4] = {1'b1, 6'b000000, 5'b00100, 5'b00101, 3'b110, 4'b0010, 1'b0, 7'b1100011}; // BLTU, compara x5 e x4, caso TRUE, vai para BGEU
    // registradores[6] = {1'b0, 6'b000000, 5'b00100, 5'b00101, 3'b111, 4'b0010, 1'b0, 7'b1100011}; // BGEU, compara x5 e x4, caso FALSE, vai para o próximo (LOAD)
    // registradores[7] = {12'b000000000011, 5'b00011, 3'b010, 5'b00111, 7'b0000011}; // LOAD, escreve no x7 o que está no x3 #3 da memoria (0 + 3 = 3), logo o número 14
    // registradores[8] = {7'b1111111, 5'b01000, 5'b00111, 3'b010, 5'b11111, 7'b0100011}; // STORE, armazena o valor do x8 no x7 #-1 da memoria
    registradores[9] = {7'b0000000, 5'b01000, 5'b00001,3'b000,  5'b01001, 7'b0110011}; // ADD, armazena o valor x8 + x1 no x9
    registradores[10] = {7'b0100000, 5'b00001, 5'b01000, 3'b000,  5'b01010, 7'b0110011}; // SUB, armazena o valor x8 - x1 no x10
    // registradores[11] = {12'b000000000011, 5'b00001, 3'b000,  5'b01011, 7'b010011}; // ADDI, armazena o valor x1 + 3 no x11
    // registradores[12] = {20'b00000000000000000001, 5'b01100, 7'b0010111 };// AUIPC, imediato vale 1, soma-se ele << 12 com o PC (que vale 12) e armazena-se no x12;
    // registradores[13] = {1'b0, 10'b0000000100, 1'b0, 8'b00000000, 5'b01101, 7'b1101111};// JAL, vai registrar PC + 4 no x13 e vai somar 2 no PC (proxima instrução eh JALR)
    // registradores[15] = {12'b000000000011, 5'b00111, 3'b000, 5'b01110, 7'b1100111};// JALR, vai registrar PC+ 4 no x14 e vai fazer PC = x7 + 3
    
    // Nao existe SUBI, como podemos apenar colocar o imediato do ADDI (sempre lido como complemento de 2) como um numero negativo

    
end

//DECODE


assign dout = registradores[ads]; // Full instruction, goes to IR
assign rd = registradores[ads][11:7]; // Write addres for the registers in LOAD, ADD, SUB, ADDI instructions
assign rs1 =  registradores[ads][19:15]; // Read addres for the registers in LOAD, ADD, SUB, STORE, ADDI, BNE, ... instructions
assign rs2 = registradores[ads][24:20]; // Another read addres for the registers in ADD, SUB, STORE, BNE, BEQ, ... instructions
assign opcode =  registradores[ads][6:0]; // Opcode in all instructions
assign funct7 = registradores[ads][30]; // For ADD and SUB
assign funct3 = registradores[ads][14:12]; // For ADD and SUB



endmodule