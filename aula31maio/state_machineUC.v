module state_machineUC (clk,reset,state_reg);
  input wire clk;
  input wire reset;
  output reg [3:0] state_reg;
  reg [3:0] state_next;
  parameter IDLE = 4'b0000, FETCH = 4'b0001, DECODE = 4'b0010, EXECUTE = 4'b0011,
  WRITE_BACK = 4'b0100;

/*   // Counter for tracking cycles spent in WB state
  reg [2:0] wb_counter; */

  always @(posedge clk, posedge reset) begin

    if (reset) begin
      state_reg <= IDLE;     // Set the initial state to IDLE
/*       wb_counter <= 0;       // Reset the WB counter */
    end
    else begin
      state_reg <= state_next;  // Update the state based on the next state

      // Increment the WB counter if in the WRITE_BACK state
/*       if (state_reg == WRITE_BACK)
        wb_counter <= wb_counter + 1;
      else
        wb_counter <= 0;  // Reset the WB counter for other states */

      // Conditions to transition to the next state
    
    /*always@(state)*/ //vou ver se vamos precisar desse segundo always(acho que sim)
      case (state_reg)
        IDLE:
        begin
            state_next = FETCH;
          end
        FETCH:
         begin
            state_next = DECODE;
          end
        DECODE:
          begin
            state_next = EXECUTE;
          end
        EXECUTE:
          begin
            state_next = WRITE_BACK;
          end
        WRITE_BACK:
          /* if (wb_counter == 8) */
           begin  // Transition to IDLE after 8 cycles in WB state
            state_next = IDLE;
          end
        default: state_next = IDLE;  // Default transition to IDLE if no conditions are met
      endcase
            state_next = state_reg;
    end
  end


endmodule

module UC (clk,state_reg,opcode,aluop,r_enableMUX);

  input wire clk;
  input wire [3:0] state_reg;
  reg [3:0] state_next;
  input [6:0] opcode;
  output [1:0] aluop;
  output reg r_enableMUX;
  reg [6:0] reg_opcode;
  //quem recebe a instrução é o FD
  parameter IDLE = 4'b0000, FETCH = 4'b0001, DECODE = 4'b0010, EXECUTE = 4'b0011,
  WRITE_BACK = 4'b0100;

/*   // Counter for tracking cycles spent in WB state
  reg [2:0] wb_counter; */

  always @(posedge clk) begin

      case (state_reg)
        IDLE:
        begin

          end
        FETCH:
         begin
          r_enableMUX=1;
            //vai passar um sinal que vai permitir gravar a instrução da memória no IR e é lá que vai distrinchar as partes
          end
        DECODE:
          begin
          r_enableMUX=0;
          reg_opcode<=opcode;
            //vai pegar o opcode
          end
        EXECUTE:
          begin
            //vai fazer efetivamente as ações(parte do luiz)
          end
        WRITE_BACK:
          /* if (wb_counter == 8) */
           begin  // Transition to IDLE after 8 cycles in WB state
          end
      endcase
    end


endmodule
