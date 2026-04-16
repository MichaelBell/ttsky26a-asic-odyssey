/*
 * Copyright (c) 2026 Michael Bell
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module cell_auto #(parameter CELLS=30, parameter RULE=30) (
    input wire clk,
    input wire rst_n,
    output reg [CELLS-1:0] q
);

  wire [7:0] rule = RULE;

  genvar i;
  generate
    for (i = 1; i < CELLS-1; i = i + 1) begin
      always @(posedge clk) begin
        if (!rst_n) q[i] <= (i == CELLS / 2) ? 1 : 0;
        else q[i] <= rule[{q[i+1], q[i], q[i-1]}];
      end
    end
  endgenerate

    always @(posedge clk) begin
      if (!rst_n) q[0] <= 0;
      else q[0] <= rule[{q[1], q[0], q[CELLS-1]}];
    end
    always @(posedge clk) begin
      if (!rst_n) q[CELLS-1] <= 0;
      else q[CELLS-1] <= rule[{q[0], q[CELLS-1], q[CELLS-2]}];
    end

endmodule
