
/* module Fpu(clock, reset, in_a, in_b, out, op, start, done);

input clock,
input reset, é assincrono, e quando for pra alto, automaticamente, o registrador vai pra zero
input [1:0] op,
input start,//start é 1 quando as entradas estão estaveis e por isso pode começar a calcular, e é 0 quando estao mudando e portanto o processo continua
input [31:0] in_a, in_b,
output [31:0] out,
output done;//done é 1 quando aparece o resultado no registrador final do resultado, e é 0 quando ainda houver mudanças. Será 1 até que start seja 0 */

// PRIMEIRO ESTADO: recebe start e começa

// SEGUNDO ESTADO: no caso da soma vai shiftar, e no caso da multiplicação vai adicionar os expoentes

//Aqui vai enviar o sinalMuxFP1(responsável por),

//TERCEIRO ESTADO: vai add(o caso da adição) ou vai multiplicar no caso da multiplicação

// QUARTO ESTADO: vamo acionar o normalize(shiftar e pá) nos dois casos(vai ter o lance do contador pra gente saber exatamente o que vai rolar)

// QUINTO ESTADO: ROUND

// SEXTO ESTADO: verifica se esta normalizado

// SETIMO ESTADO: faz as contas da multplicação e no caso do add não faz nada

// OITAVO ESTADO: Done

module UC (clk,exp_dif_bigger,Ula_Res,round_fract,sinalMuxFP1,sinalMuxFP2, sinalMuxFP3, sinalMuxFP5,sinalMuxFP4,sinalShiftFract, sinalShiftRes, sinalIncOrDec,sinalRound);
    input wire clk,rst;
    input exp_dif_bigger;//quando o primeiro for maior, enviará 0
    input [26:0] Ula_Res,round_fract;//o round_fract nao vai ter 27 bits, vai ser passado uma flag pra decidir o que fazer
    output sinalMuxFP1;
    output sinalMuxFP2;
    output sinalMuxFP3;
    output sinalMuxFP5;
    output sinalShiftFract;
    output [8:0] sinalShiftRes;
    output [8:0] sinalIncOrDec;
    output sinalMuxFP4;
    output sinalRound;  


  wire [3:0] state_reg;
  wire Mux1, Mux3, weMem, weReg;
  wire [1:0] Mux2;

  state_machineUC sm (
    .clk(clk),
    .reset(~rst_n),
    .state_reg(state_reg)
  );

  UC uc (
    .clk(clk),
    .state_reg(state_reg),
    .opcode(opcode),
    .alu_cmd(alu_cmd),
    .Mux1(alu_src),
    .Mux2(rf_src),
    .Mux3(pc_src),
    .weMem(d_mem_we),
    .weReg(rf_we),
    .alu_flags(alu_flags)
  );

endmodule 

module state_machineUC (clk,reset,state_reg);
  input wire clk;
  input wire reset;
  output reg [3:0] state_reg;
  reg [3:0] state_next;
  parameter IDLE = 4'b0000, CompareState = 4'b0001, AddOrMult = 4'b0010, Normalize = 4'b0011,
  Round = 4'b0100,CheckNormalize = 4'b0101,MultSignal = 4'b0110,Done = 4'b0111;


/*   // Counter for tracking cycles spent in WB state
  reg [2:0] wb_counter; */

  always @(posedge clk) begin

    if (reset) begin
      state_reg <= IDLE;

    end
    else begin

      case (state_reg)
        IDLE:
        begin
            state_next = CompareState;
          end
        CompareState:
         begin
            state_next = AddOrMult;
          end
        AddOrMult:
          begin
            state_next = Normalize;
          end
        Normalize:
          begin
            state_next = Round;
          end
        Round:
          /* if (wb_counter == 8) */
           begin  // Transition to IDLE after 8 cycles in WB state
            state_next = CheckNormalize;
          end
          CheckNormalize:
          begin
            state_next = MultSignal;
          end
        MultSignal:
          begin
            state_next = Done;
          end
          Done:
          begin
            state_next = IDLE;
          end
        default: state_next = IDLE;  // Default transition to IDLE if no conditions are met
      endcase
            // state_next = state_reg;
            state_reg <= state_next;
    end
  end


endmodule

module uc (clk,state_reg,exp_dif_bigger,Ula_Res,round_fract,sinalMuxFP1,sinalMuxFP2, sinalMuxFP3, sinalMuxFP5,sinalMuxFP4,sinalShiftFract, sinalShiftRes, sinalIncOrDec,sinalRound);

    input wire clk;
    input wire [3:0] state_reg;
    input exp_dif_bigger;
    input [26:0] Ula_Res,round_fract;                // OpCode direto do IR no FD
    output sinalMuxFP1;
    output sinalMuxFP2;
    output sinalMuxFP3;
    output sinalMuxFP5;
    output sinalShiftFract;
    output [8:0] sinalShiftRes;
    output [8:0] sinalIncOrDec;
    output sinalMuxFP4;
    output sinalRound;  

  parameter IDLE = 4'b0000, CompareState = 4'b0001, AddOrMult = 4'b0010, Normalize = 4'b0011,
  Round = 4'b0100,CheckNormalize = 4'b0101,MultSignal = 4'b0110,Done = 4'b0111;



/*   // Counter for tracking cycles spent in WB state
  reg [2:0] wb_counter; */

  always @(posedge clk) begin

      case (state_reg)

        IDLE:
        begin
            if(start==1)

          end
        CompareState:
         begin

            if(exp_dif_bigger==0)begin//significa que o primeiro é maior (a>b)

                sinalMuxFP1_tb = 0;
                sinalMuxFP2_tb = 0; // a > b
                sinalMuxFP3_tb = 1; // b < a
            end
            else begin

                sinalMuxFP1_tb = 1; // b > a
                sinalMuxFP2_tb = 1; // b > a
                sinalMuxFP3_tb = 0; // b > a
            end

            

            //vai enviar o sinalmuxfp1
            //tambem vai enviar o sinal muxfp2 e o sinal muxpf3

          end
        AddOrMult:
          begin

          end
        Normalize:
          begin

          end
        Round:
           begin  

          end
          CheckNormalize:
          begin

          end
        MultSignal:
          begin

          end
          Done:
          begin

          end
      endcase
    end


endmodule

/* endmodule; */
