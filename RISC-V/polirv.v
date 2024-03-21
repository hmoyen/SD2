module polirv 
    #(
        parameter i_addr_bits = 6,
        parameter d_addr_bits = 6
    ) (
        input clk, rst_n,                       // clock borda subida, reset assíncrono ativo baixo
        output [i_addr_bits-1:0] i_mem_addr,
        input  [31:0]            i_mem_data,
        output                   d_mem_we,
        output [d_addr_bits-1:0] d_mem_addr,
        inout  [63:0]            d_mem_data
    );

    wire [6:0] opcode;
    wire d_mem_we, rf_we;
    wire [3:0] alu_flags;
    wire [3:0] alu_cmd;
    wire alu_src, pc_src, rf_src;

    uc uc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .d_mem_we(d_mem_we),
        .rf_we(rf_we),
        .alu_flags(alu_flags),
        .alu_cmd(alu_cmd),
        .alu_src(alu_src),
        .pc_src(pc_src),
        .rf_src(rf_src)
    );

    fd #(
        .i_addr_bits(i_addr_bits),
        .d_addr_bits(d_addr_bits)
    ) fd_inst (
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .d_mem_we(d_mem_we),
        .rf_we(rf_we),
        .alu_cmd(alu_cmd),
        .alu_flags(alu_flags),
        .alu_src(alu_src),
        .pc_src(pc_src),
        .rf_src(rf_src),
        .i_mem_addr(i_mem_addr),
        .i_mem_data(i_mem_data),
        .d_mem_addr(d_mem_addr),
        .d_mem_data(d_mem_data)
    );

endmodule
