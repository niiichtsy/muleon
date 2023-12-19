# This file is public domain, it can be freely copied without restrictions.
import os
import random
import sys
import math
from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

# Definitions
CLK_PERIOD_NS = 10
TEST_DURATION = 100
CYCLES = 5


async def setup_clocks(dut):
    sclk = Clock(dut.clk, CLK_PERIOD_NS, units="ns")
    cocotb.start_soon(sclk.start())


async def reset_dut(dut):
    dut.resetn.value = 1
    await Timer(CLK_PERIOD_NS * 2, units="ns")
    dut.resetn.value = 0
    await Timer(CLK_PERIOD_NS * 2, units="ns")
    dut.resetn.value = 1
    await Timer(CLK_PERIOD_NS * 2, units="ns")


# From sine_wave.py
def scale_number(unscaled, to_min, to_max, from_min, from_max):
    val = (to_max - to_min) * (unscaled - from_min) / (from_max - from_min) + to_min
    return round(val)


def generate_sine_table(frequency, length=1024, maxVal=1023, minVal=0):
    raw_table = []

    for i in range(0, CYCLES):
        for index, item in enumerate(
            (math.sin(frequency * 2 * math.pi * i / length) for i in range(length))
        ):
            raw_table.append(int(scale_number(item, minVal, maxVal, -1, 1)))

    return raw_table


@cocotb.test()
async def fir_highpass_test(dut):
    await setup_clocks(dut)
    await RisingEdge(dut.clk)
    await reset_dut(dut)

    sine_slowest = generate_sine_table(1, 1024, 32767, -32768)
    sine_slow = generate_sine_table(10, 1024, 32767, -32768)
    sine_fast = generate_sine_table(100, 1024, 32767, -32768)
    sine_fastest = generate_sine_table(1000, 1024, 32767, -32768)

    sine = sine_slowest + sine_slow + sine_fast + sine_fastest

    for sineval in sine:
        dut.i2s_data_in.value = sineval
        await RisingEdge(dut.clk)

    assert dut.resetn.value == 1


def fir_highpass_test_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent
    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "model"))

    verilog_sources = [proj_path / "src" / "fir_highpass.v"]

    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "tests"))

    runner = get_runner(sim)
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="fir_highpass",
        always=True,
    )
    runner.test(
        hdl_toplevel="fir_highpass",
        test_module="fir_highpass_test",
    )


if __name__ == "__main__":
    fir_highpass_test_runner()
