`default_nettype none

module music (
    input wire clk,
    input wire rst_n,

    output wire pwm,

/* verilator lint_off UNUSEDSIGNAL */
    input wire [10:0] count,
    input wire [10:0] frame  // Note counts down from 1624
/* verilator lint_on UNUSEDSIGNAL */
);

    // The PWM module converts the sample of our triangle wave to a PWM output
    wire [7:0] sample_for_pwm;
    wire [6:0] tri_sample;
    reg [7:0] sample;

    assign tri_sample = sample[6:0] ^ {7{sample[7]}};
    assign sample_for_pwm = {2'b01 + {1'b0, tri_sample[6]}, tri_sample[5:0]};
    assign pwm = sample_for_pwm > count[7:0];


    wire [9:0] divider;
    reg [9:0] thresh;
    /* verilator lint_off SYNCASYNCNET */
    wire wen = count[9:0] == thresh && (frame[10:9] != 2'b11 && frame[9:6] != 0);
    /* verilator lint_on SYNCASYNCNET */
    wire [9:0] next_thresh = thresh + divider;
    always @(posedge clk) begin
        if (~rst_n) thresh <= 0;
        else if (wen) thresh <= next_thresh;
    end

    // TODO can be an incrementer
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            sample <= 0;
        end else if (wen) begin
            sample <= sample + 1;
        end
    end

    // Dawn of man theme, 36MHz project clock
    function [9:0] divider_rom(input [4:0] idx);
        case (idx)        
23: divider_rom = 10'd539;
22: divider_rom = 10'd539;
21: divider_rom = 10'd359;
20: divider_rom = 10'd359;
19: divider_rom = 10'd269;
18: divider_rom = 10'd269;
17: divider_rom = 10'd269;

15: divider_rom = 10'd539;
14: divider_rom = 10'd539;
13: divider_rom = 10'd359;
12: divider_rom = 10'd359;
11: divider_rom = 10'd269;
10: divider_rom = 10'd269;
9: divider_rom = 10'd269;
8: divider_rom = 10'd226; // Eb
7: divider_rom = 10'd213; // E
6: divider_rom = 10'd213; // E
5: divider_rom = 10'd180; // G
4: divider_rom = 10'd180; // G
3: divider_rom = 10'd134; // high C
2: divider_rom = 10'd134;
1: divider_rom = 10'd134;

default: divider_rom = 10'dx;
        endcase
    endfunction

    assign divider = divider_rom(frame[10:6]);

endmodule
