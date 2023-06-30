
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
    input [26:0] Ula_Res,round_fract;
    input finished_shift;//usado para indicar se já acabaram os shifts da normalização
    output sinalMuxFP1;
    output sinalMuxFP2;
    output sinalMuxFP3;
    output sinalMuxFP5;
    output [7:0] sinalShiftFract;
    output sinalShiftRes;
    output reset_shift;//vai indicar se deve começar a shiftar
    output [8:0] sinalIncOrDec;
    output sinalMuxFP4;
    output sinalRound;  
    output sinal_shift;


  wire [3:0] state_reg;
  wire Mux1, Mux3, weMem, weReg;
  wire [1:0] Mux2;

  state_machineUC sm (
    .clk(clk),
    .reset(~rst_n),
    .state_reg(state_reg),
    .finished_shift(finished_shift)
  );

  UC uc (
    .clk(clk),
    .state_reg(state_reg),
    .exp_dif_bigger(exp_dif_bigger),
    .Ula_Res(Ula_Res),
    .round_fract(round_fract),           
    .sinalMuxFP1(sinalMuxFP1),
    .sinalMuxFP2(sinalMuxFP2),
    .sinalMuxFP3(sinalMuxFP3),
    .sinalMuxFP5(sinalMuxFP5),
    .sinalShiftFract(sinalShiftFract),
    .sinalShiftRes(sinalShiftRes),
    .sinalIncOrDec(sinalIncOrDec),
    .sinalMuxFP4(sinalMuxFP4),
    .sinalRound(sinalRound)
  );

endmodule 

module state_machineUC (clk,reset,state_reg, finished_shift);
  input wire clk;
  input wire reset;
  input wire finished_shift;//adicionado para indicar se pode mudar de estado
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
            if(finished_shift)
            begin
            state_next = Round;//vai permanecer nesse estado até acabar de shiftar
            end
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

module uc (clk,state_reg,exp_dif_bigger,Ula_Res,round_fract,sinalMuxFP1,sinalMuxFP2, sinalMuxFP3, sinalMuxFP5,sinalMuxFP4,sinalShiftFract, sinalShiftRes, sinalIncOrDec,sinalRound, sinal_shift);

    input wire clk;
    input wire [3:0] state_reg;
    input [7:0] exp_dif_bigger;
    input [26:0] Ula_Res,round_fract;                // OpCode direto do IR no FD
    output reg sinalMuxFP1;
    output reg sinalMuxFP2;
    output reg sinalMuxFP3;
    output sinalMuxFP5;
    output reg [7:0] sinalShiftFract;
    output sinalShiftRes;
    output [8:0] sinalIncOrDec;
    output sinalMuxFP4;
    output sinalRound;
    output reg reset_shift;
    output reg sinal_shift;

  parameter IDLE = 4'b0000, CompareState = 4'b0001, AddOrMult = 4'b0010, Normalize = 4'b0011,
  Round = 4'b0100,CheckNormalize = 4'b0101,MultSignal = 4'b0110,Done = 4'b0111;



/*   // Counter for tracking cycles spent in WB state
  reg [2:0] wb_counter; */

  always @(posedge clk) begin

      case (state_reg)

        IDLE:
        begin
            //if(start==1)

          end
        CompareState:
         begin

            if(exp_dif_bigger[7:6]==0)begin//depois de fazer a subtração, analisa o mais significativo. E se for positivo, significa que o primeiro é maior (a>b)

                sinalMuxFP1 <= 0;
                sinalMuxFP2 <= 0; // a > b
                sinalMuxFP3 = 1; // b < a
            end
            else begin

                sinalMuxFP1 = 1; // b > a
                sinalMuxFP2 = 1; // b > a
                sinalMuxFP3 = 0; // b > a
            end
                sinalShiftFract= exp_dif_bigger; //esse é o shift right depois de selecionar, talvez tenha que estar no proximo estado

          end
        AddOrMult:
          begin
            //aqui vai somar
          end
        Normalize:
          begin
            reset_shift=1; //vai acionar o shiftar no normalize e vai continuar mandando e shiftando
            sinal_shift=1;// OBS*************:aqui ainda nao sei qual vai ser. Mas se for shift pra esquerda, ele será um, e se for pra direita, será 0

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
