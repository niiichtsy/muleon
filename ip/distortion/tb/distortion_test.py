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


async def setup_clocks(dut):
    sclk = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(sclk.start())


async def reset_dut(dut):
    dut.resetn.value = 1
    await Timer(20, units="ns")
    dut.resetn.value = 0
    await Timer(20, units="ns")
    dut.resetn.value = 1
    await Timer(20, units="ns")


# From sine_wave.py
def scale_number(unscaled, to_min, to_max, from_min, from_max):
    val = (to_max - to_min) * (unscaled - from_min) / (from_max - from_min) + to_min
    return round(val)


async def generate_sine_table(length=1024, maxVal=1023, minVal=0):
    raw_table = []

    for index, item in enumerate(
        (math.sin(2 * math.pi * i / length) for i in range(length))
    ):
        raw_table.append(format(int(scale_number(item, minVal, maxVal, -1, 1))))
        await Timer(10, units="ns")

    yield raw_table


@cocotb.test()
async def distortion_test(dut):
    await setup_clocks(dut)
    await RisingEdge(dut.clk)
    await reset_dut(dut)

    sine = generate_sine_table(1024, 1024, 0)
    async for value in sine:
        dut.i2s_data_in = value

    assert dut.resetn.value == 1


def distortion_test_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent
    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "model"))

    verilog_sources = [proj_path / "src" / "distortion.v"]

    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "tests"))

    runner = get_runner(sim)
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="distortion",
        always=True,
    )
    runner.test(
        hdl_toplevel="distortion",
        test_module="distortion_test",
    )


if __name__ == "__main__":
    distortion_test_runner()
