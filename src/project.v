/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_sprite_rom_test (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [9:0] x;
  wire [9:0] y;
  wire hsync;
  wire vsync;
  wire active;
  reg hsync_r;
  reg vsync_r;
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;

  wire [3:0] rom_q;

  flag_rom sprite(
    .addr({y[5:0], x[5:0]}),
    .q(rom_q)
  );

  reg [5:0] colour;
  always @(*) begin
    case(rom_q)
0: colour = 6'h01;
1: colour = 6'h11;
2: colour = 6'h25;
3: colour = 6'h15;
4: colour = 6'h39;
5: colour = 6'h05;
6: colour = 6'h06;
7: colour = 6'h0a;
8: colour = 6'h1b;
9: colour = 6'h0b;
10: colour = 6'h35;
default: colour = 6'h38;
    endcase
  end

  vga_timing timing(
    .clk(clk),
    .rst_n(rst_n),
    .active(active),
    .x(x),
    .y(y),
    .hsync(hsync),
    .vsync(vsync)
  );

  always @(posedge clk) begin
    hsync_r <= hsync;
    vsync_r <= vsync;

    if (!active) begin
      R <= 0;
      G <= 0;
      B <= 0;
    end else begin
      R <= colour[5:4];
      G <= colour[3:2];
      B <= colour[1:0];
    end
  end


  assign uo_out = {hsync_r, B[0], G[0], R[0], vsync_r, B[1], G[1], R[1]};

  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in, uio_in, x[9:6], y[9:6], 1'b0};

endmodule
