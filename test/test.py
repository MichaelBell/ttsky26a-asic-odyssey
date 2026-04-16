# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from PIL import Image

@cocotb.test()
async def test_sync(dut):
    dut._log.info("Start")

    # Set the clock period to 27.78 us (~36MHz)
    clock = Clock(dut.clk, 27.78, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")
    await ClockCycles(dut.clk, 2)

    image = Image.new("RGB", (800, 600))

    # Test sync
    for i in range(624*2+5):
        vsync = 1 if (600+3) <= i % 624 < (600+7) else 0
        for j in range(800+32):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            if i < 600 and j < 800:
                red = dut.red.value.to_unsigned() * 85
                green = dut.green.value.to_unsigned() * 85
                blue = dut.blue.value.to_unsigned() * 85
                image.putpixel((j, i), (red, green, blue))            
            await ClockCycles(dut.clk, 1)
        for j in range(80):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 0
            await ClockCycles(dut.clk, 1)
        for j in range(112):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            await ClockCycles(dut.clk, 1)

        if i == 600:
            image.save("frame.png")
