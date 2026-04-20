`default_nettype none

module incrementer (
`ifdef GL_TEST
    inout wire VPWR,
    inout wire VGND,
`endif
/* verilator lint_off UNUSEDSIGNAL */
    input wire clk,
    input wire rst_n,
    input wire inc,
/* verilator lint_on UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */
    output reg [19:0] q
/* verilator lint_on UNDRIVEN */
);

`ifdef SIM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 0;
        else q <= q + {19'b0, inc};
    end
`endif

endmodule
