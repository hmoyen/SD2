module registrador (
    input clk,             // Clock do sistema
    input [PARAM_BITS-1:0] data_in, // Dados de entrada
    input load,            // Sinal de carregamento de dados
    output reg [PARAM_BITS-1:0] data_out // Dados de saída
);

    parameter PARAM_BITS = 9; // Define o número de bits do registrador

    always @(posedge clk) begin
        if (load) begin // Se o sinal de carregamento de dados estiver ativo
            data_out <= data_in; // Carrega os dados de entrada no registrador
        end
    end

endmodule