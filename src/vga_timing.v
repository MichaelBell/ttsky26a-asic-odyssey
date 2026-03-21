`default_nettype none

module vga_timing (
    input wire clk,
    input wire rst_n,
    output wire active,
    output wire [9:0] x,
    output wire [9:0] y,
    output wire hsync,
    output wire vsync
);

    wire count_rst_n;
    wire [19:0] count;

    incrementer counter (
        .clk(clk),
        .rst_n(count_rst_n),
        .inc(1'b1),
        .q(count)
    );

    assign x = count[9:0];
    assign y = count[19:10];

`ifdef SIM
    assign count_rst_n = rst_n & !(y[9] && y[6:4] == 3'b111);
`else
    wire count_max;

    // Lint for sky130 cells expects power pins, so disable the warning
    /* verilator lint_off PINMISSING */
    sky130_fd_sc_hd__nand4_1 i_nand(.Y(count_max), .A(y[9]), .B(y[6]), .C(y[5]), .D(y[4]));
    sky130_fd_sc_hd__and2_1 i_and(.X(count_rst_n), .A(rst_n), .B(count_max));
    /* verilator lint_on PINMISSING */
`endif

    assign active = (x < 800) && (y < 600);
    assign hsync = !((x >= 832) && (x < 912));
    assign vsync = y[9] && y[6:3] == 4'b1011 && (y[2:0] >= 3) && (y[2:0] < 7);

endmodule
