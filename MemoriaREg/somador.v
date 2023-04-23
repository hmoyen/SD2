module somador(a,b,sinal,soma);

    input [4:0] a;
    input [4:0] b;
    input sinal;
    output reg [5:0] soma;

    always @(a,b) begin
        if (sinal == 1'b0) begin
            soma = a + b;
        end  
        else begin
            soma <= a - b;
        end
      
    end

endmodule
