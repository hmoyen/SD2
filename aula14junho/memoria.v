module memoria // Inclui a memoria de instrução e a memoria de dados. Está separada do fluxo de dados 
    #(
        parameter i_addr_bits = 6,
        parameter d_addr_bits = 6
    ) (
        input [i_addr_bits-1:0]    i_mem_addr, // Endereço da memoria de instrução
        output  [31:0]            i_mem_data, // Conteúdo da memoria de instrução
        input                    d_mem_we, // Write-enable da memoria de dados
        input [d_addr_bits-1:0]  d_mem_addr, // Endereço da memoria de dados
        inout  [63:0]            d_mem_data // Conteúdo da memoria de dados
    );

    wire signed [63:0] data_in; 
    wire signed [63:0] data_out;

    data_mem d_mem(
        .ads(d_mem_addr),
        .we(d_mem_we),
        .din(data_in),
        .dout(data_out)
    );

    memoria_ins i_mem(
        .ads(i_mem_addr),
        .dout(i_mem_data)
    );

    assign d_mem_data = (d_mem_we == 1) ? 64'bz : data_out; // alta impedância se o we da memoria estiver ativado, ou seja, ocorre um store (apenas se recebe dados do fd)
    assign data_in = d_mem_data;

endmodule

module data_mem(
  input [5:0] ads,
  input we,
  input signed [63:0] din,
  output signed [63:0] dout
);
  
  reg signed [63:0] registradores [31:0]; // Registradores

  initial begin
    registradores[0] = 45;
    registradores[1] = 11;
    registradores[3] = 14;
    registradores[13] = 0;
  end

  // Read operation
  assign dout = registradores[ads];

  // Write operation
  always @(*) begin
    if(we)
        registradores[ads] <= din;
  end

  always @(registradores[13]) begin
    $display("Conteúdo registrador 13 da memória: %d", registradores[13]);
  end

endmodule


module memoria_ins(ads, dout);
  
input [5:0] ads; // Program counter (PC) in RISC-V is 32 bits long (can addres 2³² instructions)
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
    // beq: 1100011 (funct3 = 000)
    // load (e.g., lw, lh, lb): 0000011
    // store (e.g., sw, sh, sb): 0100011

reg signed [31:0] registradores [31:0]; // Registradores

initial begin


   // --------Palavras de instrução --------------------------------------------------
   // O imediato nas branch instructions podem ser colocadas em "unidade" de instrução 
   // Por exemplo, para ir para duas instruções para frente, colocamos no imediato "2"
   // Depois do sign extend do imediato, fazemos um shift left 2, multiplicando por 4
   // Ou seja, indo do registrador[i] para o registrador [i+8], o que seria, justamente, duas instruções para frente

    registradores[0] = {1'b0, 6'b000000, 5'b00001, 5'b00010, 3'b000, 4'b0010, 1'b0, 7'b1100011}; // BEQ, compara x1 e x2
    registradores[2] = {12'b000000000011, 5'b00011, 3'b010, 5'b00111, 7'b0000011}; // LOAD, escreve no x7 o que está no x3 #3 da memoria (0 + 3 = 3), logo o número 14
    registradores[3] = {7'b1111111, 5'b01000, 5'b00111, 3'b010, 5'b11111, 7'b0100011}; // STORE, armazena o valor do x8 no x7 #-1 da memoria
    registradores[4] = {7'b0000000, 5'b01000, 5'b00001,3'b000,  5'b01001, 7'b0110011}; // ADD, armazena o valor x8 + x1 no x9
    registradores[5] = {7'b0100000, 5'b00001, 5'b01000, 3'b000,  5'b01010, 7'b0110011}; // SUB, armazena o valor x8 - x1 no x10
    registradores[6] = {7'b0000000, 5'b00001, 5'b00010, 3'b111, 5'b01100, 7'b0110011}; // AND entre x1 e x2, armazena valor no x12
    registradores[7] = {7'b0000000, 5'b00001, 5'b00011, 3'b110, 5'b01101, 7'b0110011}; // OR entre x1 e x3, armazena valor no x13
    
    
end

//DECODE

assign dout = registradores[ads]; // Full instruction, goes to IR


endmodule