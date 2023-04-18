module somador(

    input [PARAM_BITS-1:0] a,
    input [PARAM_BITS-1:0] b,
    input sinal,
    output reg soma [PARAM_BITS:0]
);

    parameter PARAM_BITS = 8;

    always @(a,b) begin
        if (sinal == 1'b0) begin
            soma <= a + b;
        end  
        else begin
            soma <= a - b;
        end
    end

endmodule