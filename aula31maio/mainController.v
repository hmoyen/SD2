module mainController(
  input [6:0] Opcode,
  output Mux1, Mux2, Mux4, weMem, weReg, wePc, weIR
);
  reg [7:0] control;

  assign {Mux1, Mux2, Mux4, weMem, weReg, wePc, weIR} =
    (Opcode == 7'b0000011) ? 8'b11100000 : // Load - weIR-1b,wePc-1b,weReg-1b,weMem-1b,Mux4-1n,Mux2-2b,Mux1-1b
    (Opcode == 7'b0100011) ? 8'b11010000 : // Store - weIR-1b,wePc-1b,weReg-1b,weMem-1b,Mux4-1n,Mux2-2b,Mux1-1b
    (Opcode == 7'b0110011) ? 8'b11100011 : // Add - weIR-1b,wePc-1b,weReg-1b,weMem-1b,Mux4-1n,Mux2-2b,Mux1-1b

    // (Opcode == 7'b0110011) ? 8'b1,1,1,0,0,01,1 : // Add - weIR-1b,wePc-1b,weReg-1b,weMem-1b,Mux4-1n,Mux2-2b,Mux1-1b
    // (Opcode == 7'b0110011) ? 8'b001000010 : // Store
    // (Opcode == 7'b0100011) ? 8'b1x0010000 : // s-type
    // (Opcode == 7'b1100011) ? 8'b0x0001001 : // sb-type
    // (Opcode == 7'b0010011) ? 8'b101000011 : // I-type
    // (Opcode == 7'b1100111) ? 8'b111xx0100 : // jalr-type
    // (Opcode == 7'b1101111) ? 8'b111xx0100 : // jal-type
    8'bxxxxxxxx;
endmodule
