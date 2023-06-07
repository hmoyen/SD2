// **********GRUPO ************
// Helena Bianchi Moyen
// Luiz Mariano
// Mariana Watanabe


`timescale 1ns/1ns

module testbench;

    // Sinais UC

    wire weMem_tb, wePC_tb, weIR_tb;
    wire sinalMux1_tb;
    wire [1:0] sinalMux2_tb;
    wire sinalMux4_tb;
    wire [1:0] aluop_tb; // UC para ALUControl

    ALUControl alu (
        .aluop(aluop_tb),
        .funct3(funct3_tb),
        .funct7(funct7_tb),
        .control(control_tb)
    );

    state_machineUC sta (
        .clk(clock_tb),
        .reset(reset_tb),
        .state_reg(state_reg_tb)
    );

    UC ucc(
        .clk(clock_tb),
        .state_reg(state_reg_tb),
        .opcode(opcode_tb),
        .aluop(aluop_tb),
        .Mux1(sinalMux1_tb),
        .Mux2(sinalMux2_tb),
        .Mux4(sinalMux4_tb),
        .weMem(weMem_tb),
        .weReg(weReg_tb),
        .weIR(weIR_tb),
        .wePc(wePC_tb)

    );



    initial $dumpfile("testbench.vcd");
    initial $dumpvars(0, testbench);

    initial 
    begin
        
        //*******************************Abaixo é a simulação: ********************************************************************
        clock_tb = 0;
        reset_tb = 1;
        #10
        sinalMux5_tb = 1;
        reset_tb = 0;
        instruction_tb = 0; // ADD
        #10
        #10
        #10
        // INSTRUCTION FETCH FINISHED
        #10
        // DECODE FINISHED
        #10
        // EXECUTE FINISHED
        sinalMux5_tb = 0;
        #10
        #10
        #10
        #10
        #10
        #10
        #10
        #10
        // WB FINISHED -> NEXT INSTRUCTION IS SUB
        #10
        // INSTRUCTION FETCH FINISHED
        #10
        // DECODE FINISHED
        #10
        // EXECUTE FINISHED
        #10
        #10
        #10
        #10
        #10
        #10
        #10
        #10
        // WB FINISHED -> END
        $display("Fim da simulação");
        $finish;

     
    end

        always #10 clock_tb = ~clock_tb;
    
    



endmodule