module control_unit(clock, start, sinal, state);

    output reg [3:0] state;
    reg [3:0] next_state;
    input wire clock, start;
    output reg sinal;
    parameter IDLE = 4'b0000, MUL0 = 4'b0001, MUL1 = 4'b0010, MUL2 = 4'b0011,
    MUL3 = 4'b0100, MUL4 = 4'b0101, MUL5 = 4'b0110, MUL6 = 4'b0111, MUL7 = 4'b1000, MUL8 = 4'b1001, DONE = 4'b1010;

// state register
    always@(posedge clock or posedge start)
    begin

        // $display(bH,bL);
        if(start == 1)
        begin
            state <= IDLE;
        end
        else
            state <= next_state;
    end


always@(state)
    begin
        case (state)
            IDLE:
            if(start == 1)
                begin
                    sinal <= 1'b0;
                    
                    next_state <= MUL0;
                end
            else
                next_state <= IDLE;

            MUL0: 
                begin
                    sinal <= 1'b0;
                    next_state <= MUL1;

                end
            MUL1:
                begin
                    sinal <= 1'b0;
                    next_state <= MUL2;
                end
            MUL2:
                begin
                
                    sinal <= 1'b0;
                    next_state <= MUL3;
                end
            MUL3:
                begin
                    sinal <= 1'b0;
                    next_state <= MUL4;
                end
            MUL4:
                begin
                    sinal <= 1'b1;
                    next_state <= MUL5;
                end
            MUL5:
                begin
                    sinal <= 1'b0;
                    // $strobe(res);
                    next_state <= MUL6;
                end
            MUL6:
                begin
                    sinal <=1'b0;
                    next_state <=MUL7;
                end
            MUL7:
                begin
                    sinal <= 1'b0;
                    next_state <=MUL8;
                end
            MUL8:
                begin
                    sinal <= 1'b0;
                    next_state <= DONE;
                end
            DONE:
                begin
                    next_state <= IDLE;
                end

                
                
        endcase
    end

endmodule