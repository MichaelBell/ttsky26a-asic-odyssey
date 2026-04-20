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
    reg [7:0] sample;

    assign sample_for_pwm = {2'b01 + {1'b0, sample[7]}, sample[6:1]}; 
    assign pwm = sample_for_pwm > count[7:0];


    wire [9:0] divider;
    reg [9:0] thresh;
    /* verilator lint_off SYNCASYNCNET */
    wire wen = count[9:0] == thresh;
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
    function [9:0] divider_rom(input [1:0] idx);
        case (idx)
3: divider_rom = 10'd539;
2: divider_rom = 10'd359;
1: divider_rom = 10'd269;
0: divider_rom = 10'd269;
        endcase
    endfunction

    assign divider = divider_rom(frame[7:6] ^ 2'b10);

endmodule
