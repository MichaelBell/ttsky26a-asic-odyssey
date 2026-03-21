// ROM behavioural model

`default_nettype none

`ifndef ROM_VMEM_PATH
`define ROM_VMEM_PATH "../src/flag_rom.hex"
`endif

module flag_rom (
    // Power pins for the Gate Level test:
`ifdef GL_TEST
    inout wire VPWR,
    inout wire VGND,
`endif
    input wire [11:0] addr,
    output wire [3:0] q
);

  reg [7:0] rom_data[4095:0];
  initial begin
    $readmemh(`ROM_VMEM_PATH, rom_data);
  end

  assign q = rom_data[addr][3:0];

endmodule
