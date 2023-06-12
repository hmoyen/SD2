module uc (
    input clk, rst_n,                       // clock borda subida, reset assíncrono ativo baixo
    input [6:0] opcode,                     // OpCode direto do IR no FD
    output d_mem_we, rf_we,                 // Habilita escrita na memória de dados e no banco de registradores
    input  [3:0] alu_flags,                 // Flags da ULA
    output [3:0] alu_cmd,                   // Operação da ULA
    output alu_src, pc_src, rf_src          // Seletor dos MUXes
);
  
  wire [3:0] state_reg;
  wire Mux1, Mux4, weMem, weReg;
  wire [1:0] Mux2;
  wire wePc, weIR;

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
    .Mux1(Mux1),
    .Mux2(Mux2),
    .Mux4(Mux4),
    .weMem(weMem),
    .weReg(weReg),
    .wePc(wePc),
    .weIR(weIR)
  );


  assign d_mem_we = weMem;
  assign rf_we = weReg;
  assign alu_src = Mux1;
  assign pc_src = wePc;
  assign rf_src = Mux2;

endmodule



module state_machineUC (clk,reset,state_reg);
  input wire clk;
  input wire reset;
  output reg [3:0] state_reg;
  reg [3:0] state_next;
  parameter IDLE = 4'b0000, FETCH = 4'b0001, DECODE = 4'b0010, EXECUTE = 4'b0011,
  WRITE_BACK = 4'b0100;

/*   // Counter for tracking cycles spent in WB state
  reg [2:0] wb_counter; */

  always @(posedge clk) begin

    if (reset) begin
      state_reg <= IDLE;     // Set the initial state to IDLE
/*       wb_counter <= 0;       // Reset the WB counter */
    end
    else begin
      // Update the state based on the next state

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
            // state_next = state_reg;
            state_reg <= state_next;
    end
  end


endmodule

module UC (clk,state_reg,opcode,alu_cmd,Mux1, Mux2, Mux4, weMem, weReg, wePc, weIR);

  input wire clk;
  input wire [3:0] state_reg;
  reg [3:0] state_next;
  input [6:0] opcode;//opcode
  output [3:0] alu_cmd;//alu_cmd
  reg [6:0] reg_opcode;
  input [3:0] alu_flags;//ainda nao usado
  output  Mux1, Mux4, weMem, weReg;//weMem=d_mem_we e weReg=rf_we
  output reg wePc;//pc_src
  output [1:0] Mux2;
  output reg weIR;
  reg[8:0] control;
  //quem recebe a instrução é o FD
  parameter IDLE = 4'b0000, FETCH = 4'b0001, DECODE = 4'b0010, EXECUTE = 4'b0011,
  WRITE_BACK = 4'b0100;

  assign { weReg, weMem, Mux4, Mux2, Mux1, alu_cmd} = control;

/*   // Counter for tracking cycles spent in WB state
  reg [2:0] wb_counter; */

  always @(posedge clk) begin

      case (state_reg)
        IDLE:
        begin
          // weIR=1;

          end
        FETCH:
         begin
          weIR=1;
            //vai passar um sinal que vai permitir gravar a instrução da memória no IR e é lá que vai distrinchar as partes
          end
        DECODE:
          begin
          weIR=0;
  
          reg_opcode<=opcode;
            //vai pegar o opcode
          end
        EXECUTE:
        begin
            case(reg_opcode)
              7'b0000011: control <= 8'b10000000;
              7'b0100011: control <= 8'b01000000;
              7'b0110011: control <= 8'b10x01110;
              default: control <=  8'bxxxxxxxx;
              endcase
              weIR =0;
              wePc =1;

              // (Opcode == 7'b0110011) ? 8'b1,1,1,0,0,01,1 : // Add - weIR-1b,wePc-1b,weReg-1b,weMem-1b,Mux4-1n,Mux2-2b,Mux1-1b
              // (Opcode == 7'b0110011) ? 8'b001000010 : // Store
              // (Opcode == 7'b0100011) ? 8'b1x0010000 : // s-type
              // (Opcode == 7'b1100011) ? 8'b0x0001001 : // sb-type
              // (Opcode == 7'b0010011) ? 8'b101000011 : // I-type
              // (Opcode == 7'b1100111) ? 8'b111xx0100 : // jalr-type
              // (Opcode == 7'b1101111) ? 8'b111xx0100 : // jal-type
              
                      //vai fazer efetivamente as ações(parte do luiz)
        end   
        WRITE_BACK:
          /* if (wb_counter == 8) */
           begin  // Transition to IDLE after 8 cycles in WB state
           wePc =0;
          end
      endcase
    end


endmodule

