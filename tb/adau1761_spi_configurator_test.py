# This file is public domain, it can be freely copied without restrictions.
import os
import random
import sys
from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock


async def setup_clocks(dut):
    sclk = Clock(dut.clk, 1, units="ns")
    cocotb.start_soon(sclk.start())


async def reset_dut(dut):
    dut.resetn.value = 1
    await Timer(2, units="ns")
    dut.resetn.value = 0
    await Timer(2, units="ns")
    dut.resetn.value = 1
    await Timer(2, units="ns")


@cocotb.test()
async def adau1761_spi_configurator_test(dut):
    await setup_clocks(dut)
    await RisingEdge(dut.clk)
    await reset_dut(dut)
    await Timer(200, units="ns")
    assert dut.cs.value == 1 or dut.cs.value == 0


def adau1761_spi_configurator_test_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent
    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "model"))

    verilog_sources = [proj_path / "src" / "adau1761_spi_configurator.v"]

    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "tests"))

    runner = get_runner(sim)
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="adau1761_spi_configurator",
        always=True,
    )
    runner.test(
        hdl_toplevel="adau1761_spi_configurator",
        test_module="adau1761_spi_configurator_test",
    )


if __name__ == "__main__":
    adau1761_spi_configurator_test_runner()
