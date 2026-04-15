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

/* verilator lint_off SYNCASYNCNET */    
    input  wire       rst_n     // reset_n - low to reset
/* verilator lint_on SYNCASYNCNET */    
`ifdef VERILATOR_SIM
,
  output wire [9:0] pix_x,
  output wire [9:0] pix_y,
  output wire video_active,
  output reg [1:0] R,
  output reg [1:0] G,
  output reg [1:0] B
`endif
);

`ifndef VERILATOR_SIM
  wire [9:0] pix_x;
  wire [9:0] pix_y;
  wire video_active;
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;
`endif 

  wire [10:0] adj_y;
  wire hsync;
  wire vsync;

  reg [9:0] counter;
  reg hsync_r;
  reg vsync_r;

  wire [3:0] rom_q;

  tt_rom sprite(
    .addr({adj_y[5:0], pix_x[5:0]}),
    .q(rom_q)
  );

  reg [5:0] tt_colour;
  always @(*) begin
    case(rom_q)
0: tt_colour = 6'h3a;
1: tt_colour = 6'h3f;
2: tt_colour = 6'h2a;
3: tt_colour = 6'h19;
4: tt_colour = 6'h15;
5: tt_colour = 6'h29;
6: tt_colour = 6'h39;
7: tt_colour = 6'h1a;
8: tt_colour = 6'h2f;
9: tt_colour = 6'h0f;
10: tt_colour = 6'h3c;
11: tt_colour = 6'h25;
12: tt_colour = 6'h31;
13: tt_colour = 6'h36;
14: tt_colour = 6'h02;
default: tt_colour = 6'h00;
    endcase
  end

  vga_timing timing(
    .clk(clk),
    .rst_n(rst_n),
    .active(video_active),
    .x(pix_x),
    .y(pix_y),
    .hsync(hsync),
    .vsync(vsync)
  );

  // Starfield
  wire star_reset = (!hsync && pix_y == counter);

  reg [19:0] lfsr;
  always @(posedge clk) begin
    if (!rst_n || star_reset) lfsr <= 0;
    else if (video_active) begin
      lfsr <= {lfsr[0], lfsr[19], ~(lfsr[18] ^ lfsr[0]), ~(lfsr[17] ^ lfsr[0]), lfsr[16], ~(lfsr[15] ^ lfsr[0]), lfsr[14:1]};
    end
  end
  
  wire is_star = {lfsr[19:11]} == 0 && (lfsr[10:4] ^ counter[8:2]) != 0;
  wire [5:0] star_col = lfsr[3:0] == 0 ? 6'b110101 :
                        lfsr[3:0] == 2 ? 6'b010111 :
                        lfsr[3:0] == 1 ? 6'b111100 : 6'b111111;  

  wire is_tt = (pix_x[9:6] == 4'b0111) && (adj_y[10:6] == 5'b00010);
  wire [5:0] colour = is_tt ? tt_colour : is_star ? star_col : 6'h00;

  always @(posedge clk) begin
    hsync_r <= hsync;
    vsync_r <= vsync;

    if (!video_active) begin
      R <= 0;
      G <= 0;
      B <= 0;
    end else begin
      R <= colour[5:4];
      G <= colour[3:2];
      B <= colour[1:0];
    end
  end

  always @(posedge vsync_r or negedge rst_n) begin
    if (~rst_n) begin
      counter <= 600;
    end else begin
      counter <= counter - 1;
      if (counter == 0) counter <= 600;
    end
  end

  assign adj_y = {1'b0, pix_y} - {1'b0, counter};

  assign uo_out = {hsync_r, B[0], G[0], R[0], vsync_r, B[1], G[1], R[1]};

  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in, uio_in, 1'b0};

endmodule
