module processador(clk, rst_n);

input clk, rst_n;

wire [5:0] i_mem_addr;
wire [31:0] i_mem_data;
wire d_mem_we;
wire [5:0] d_mem_addr;
wire [63:0] d_mem_data;

polirv prv (
    .clk(clk),
    .rst_n(rst_n),
    .i_mem_addr(i_mem_addr),
    .i_mem_data(i_mem_data),
    .d_mem_we(d_mem_we),
    .d_mem_addr(d_mem_addr),
    .d_mem_data(d_mem_data)
);

memoria mem(
    .i_mem_addr(i_mem_addr),
    .i_mem_data(i_mem_data),
    .d_mem_we(d_mem_we),
    .d_mem_data(d_mem_data),
    .d_mem_addr(d_mem_addr)
);

endmodule