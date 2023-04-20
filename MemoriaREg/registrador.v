module registrador (clk, din, we, Rw, Ra, Rb, doutA, doutB);
    input clk;             // Clock do sistema
    input [63:0] din; // Dados de entrada  
    input we;          // Sinal de carregamento de dados
    output reg [64-1:0] doutA; 
    output reg [64-1:0]  doutB; // Dados de saída
    input [4:0] Rw;
    input [4:0] Ra;
    input [4:0] Rb;

    reg [63:0] registradores [31:0]; //Registradores

    initial begin

        registradores[0] = 32;

    end

    always @(posedge clk) begin
          

        if (we) begin // Se o sinal de carregamento de dados estiver ativo
            registradores[Rw] <= din; // Carrega os dados de entrada no registrador
          
    
        end
        else
        begin
            doutA <= registradores[Ra]; // Lê os dados do registrador 
    end
    end

    

endmodule
