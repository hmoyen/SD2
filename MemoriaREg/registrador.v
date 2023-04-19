module registrador (clk, din, we, Rw, Ra, Rb, doutA, doutB);
    input clk;             // Clock do sistema
    input [PARAM_BITS-1:0] din; // Dados de entrada  
    input we;          // Sinal de carregamento de dados
    output reg [PARAM_BITS-1:0] doutA; 
    output reg [PARAM_BITS-1:0]  doutB; // Dados de saída
    input [4:0] Rw;
    input [4:0] Ra;
    input [4:0] Rb;

    parameter PARAM_BITS = 64; // Define o número de bits do registrador
    reg [63:0] registradores [31:0]; //Registradores

    initial begin

        registradores[0] = 32;

    end

    always @(posedge clk) begin

        if (we) begin // Se o sinal de carregamento de dados estiver ativo
            registradores[Rw] <= din; // Carrega os dados de entrada no registrador
        end
            doutA <= registradores[Ra]; // Lê os dados do registrador 
            doutB <= registradores[Rb]; // Lê os dados do registrador 
    end

    

endmodule
