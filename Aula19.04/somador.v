module somador(a,b,sinal,soma);

    input [7:0] a;
    input [7:0] b;
    input sinal;
    output reg [8:0] soma;

    always @(a,b) begin
        if (sinal == 1'b0) begin
            soma = a + b;
        end  
        else begin
            soma <= a - b;
        end
    end

endmodule