`include "reg.v"
module tb;

reg         clock = 0;
reg         enable = 1;
reg  [15:0] value_in;
wire [15:0] value_out;

always #1 clock = !clock;

initial $dumpfile("registertestbench.vcd");
initial $dumpvars(0, tb);

Register r(clock, enable, value_in, value_out);

initial begin
    //These events must be in chronological order.
    # 5 value_in = 31;
    # 5 value_in = 127;
    # 5 enable = 0;
    # 5 value_in = 1023;
    # 5 $finish;
end
endmodule