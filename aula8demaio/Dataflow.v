module adder (a,b,sinal, soma);

input signed [63:0] a, b;
output signed [63:0] soma;
input sinal;


assign soma = (sinal == 1'b0) ? (a + b):(a-b);
            
endmodule

module memoria(ads, clk, we, din, dout);
  
input [63 :0] ads;
input clk;
input we;
input signed [63:0] din;
output reg signed [63:0] dout;
reg signed [63:0] registradores [31:0]; // Registradores

initial begin
   
    registradores[0] = 45;
    registradores[1] = 11;
    
end

always@(posedge clk) begin

    $display("Registrador da memoria que recebe STORE         :", registradores[3]); 

    if (we)
        begin
          registradores[ads] <= din; // Escreve na memoria
        end
    else 
        begin
            dout <= registradores[ads]; // Lê a memoria
        end
end


endmodule

module memoriaIns(ads, clk, we, din, dout);
  
input [63 :0] ads;
input clk;
input we;
input signed [63:0] din;
output reg signed [63:0] dout;
reg signed [63:0] registradores [31:0]; // Registradores

initial begin
   // Mude aqui os enderecos de cada imediato aqui nos 12 bits mais significativos a partir da metade dos 64bits
    registradores[1] = 64'b0000000000000000000000000000000000000000000000000000000000000000; //LOAD
    registradores[2] = 64'b0000000000000000000000000000000000000000000100000000000000100001; // STORE
    registradores[3] = 64'b0000000000000000000000000000000000000000000000000000000000100001; // ADD
    registradores[4] = 64'b0000000000000000000000000000000000000000000000000000000000100001; //SUB
    registradores[5] = 64'b0000000000000000000000000000000000000000000100000000000000100001; // ADDI
    registradores[6] = 64'b0000000000000000000000000000000000000000001000000000000000100001; //SUBI

    
end

always@(posedge clk) begin


    if (we)
        begin
          registradores[ads] <= din; // Escreve na memoria
        end
    else 
        begin
            dout <= registradores[ads]; // Lê a memoria
        end
end


endmodule


module PC(clock, r_enable, data_in, data_out);

input             clock;
input             r_enable;
input      [63:0] data_in;
output reg [63:0] data_out;

initial begin

end

always @(posedge clock)
begin
    if(r_enable)
        data_out <= data_in;
end

endmodule


module IR(clock, r_enable, data_in, data_out);

input             clock;
input             r_enable;
input      [63:0] data_in;
output reg [31:0] data_out;

always @(posedge clock)
begin
    if(r_enable)
        data_out <= data_in[31:0];
end

endmodule

module registrador (clk, din, we, Rw, Ra, Rb, doutA, doutB);
    input clk;             // Clock do sistema
    input signed [63:0] din; // Dados de entrada  
    input we;          // Sinal de carregamento de dados
    output reg signed [64-1:0] doutA; 
    output reg signed [64-1:0]  doutB; // Dados de saída
    input [63:0] Rw;
    input [63:0] Ra;
    input [63:0] Rb;

    reg signed [63:0] registradores [31:0]; //Registradores

    initial begin
        
        registradores[0] = 1;
        registradores[1] = 1;
        registradores[2] = 3;
        registradores[3] = 0;
        registradores[5] = 2;
        registradores[6] = 36;

    end

    always @(posedge clk) begin

        $display("Registrador do banco onde ocorre o primeiro LOAD:", registradores[1]); 
        
        $display("Registrador do banco onde ocorre o primeiro ADD :", registradores[3]); 
        $display("Registrador do banco onde ocorre o primeiro SUB :", registradores[4]); 
        $display("Registrador do banco onde ocorre o ADDI :", registradores[2]); 
        $display("Registrador do banco onde ocorre o SUBI :", registradores[7]); 
        
        

        if (we) begin // Se o sinal de carregamento de dados estiver ativo
            registradores[Rw] <= din; // Carrega os dados de entrada no registrador
          
    
        end
        begin
            doutA <= registradores[Ra]; // Lê os dados do registrador 
            doutB <= registradores[Rb]; // Lê os dados do registrador 

    end
    end

    

endmodule

module Mux1 (C,Rb,sinalMux,S1 );

input signed [63:0] Rb;
input signed [31:0] C;
output signed [63:0] S1;
input sinalMux;


assign S1 = (sinalMux == 1'b0) ? C[31:20]: Rb;
            
endmodule


module Mux2 (dout, soma ,sinalMux, S2);

input signed [63:0] dout, soma;
output signed [63:0] S2;
input sinalMux;


assign S2 = (sinalMux == 1'b0) ? (dout):(soma);
            
endmodule