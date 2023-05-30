module ALUControl(
input [1:0] aluop,
input funct7, input [2:0] funct3,
output [3:0] control);

assign control = (aluop == 2'b10 && {funct7,funct3} == 4'b0000) ?  4'b0010: // ADD
                 (aluop == 2'b10 && {funct7,funct3} == 4'b0110) ? 4'b0110: // SUB
                 (aluop == 2'b00) ? 4'b0010: // outras
                 (aluop == 2'b01) ? 4'b0110: // outras
                                    4'bxxxx; // default

endmodule