module memoria(ads, clk, we, din, dout);
  
input [5 :0] ads;
input clk;
input we;
input [63:0] din;
output reg [63:0] dout;
reg [63:0] registradores [31:0]; // Registradores

initial begin
    registradores[16] = 45;
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