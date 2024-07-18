# tb_fifo.py
# test cases:
# - full test
# - empty test
# - underflow test
# - overflow test

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge


async def reset_check(dut):
  await FallingEdge(dut.clk)
  assert dut.o_wfull.value == 0
  assert dut.o_woverflow.value == 0
  assert dut.o_rempty.value == 1
  cocotb.log.info("Reset Test Passed")


async def full_test(dut, model):
  await FallingEdge(dut.clk)
  for i in range(len(model)):
    dut.i_wen.value = 1
    dut.i_wdata.value = i
    model[i] = i
    await RisingEdge(dut.clk)

  await FallingEdge(dut.clk)
  assert dut.o_wfull.value
  cocotb.log.info("Full Test Passed")
  dut.i_wen.value = 0

  await RisingEdge(dut.clk)
  return model


async def empty_test(dut, model):
  await FallingEdge(dut.clk)
  for i in range(len(model)):
    dut.i_ren.value = 1

    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.o_rdata.value == model[i]
  assert dut.o_rempty.value
  cocotb.log.info("Empty Test Passed")
  dut.i_ren.value = 0

  await RisingEdge(dut.clk)


async def underflow_test(dut):
  await FallingEdge(dut.clk)
  dut.rstn.value = 0

  await RisingEdge(dut.clk)
  await FallingEdge(dut.clk)
  dut.rstn.value = 1

  assert dut.o_rempty.value
  dut.i_ren.value = 1

  await RisingEdge(dut.clk)
  await FallingEdge(dut.clk)
  assert dut.o_runderflow.value
  cocotb.log.info("Underflow Test Passed")
  dut.i_ren.value = 0

  await RisingEdge(dut.clk)


async def overflow_test(dut):
  await FallingEdge(dut.clk)
  dut.rstn.value = 0

  await RisingEdge(dut.clk)
  await FallingEdge(dut.clk)
  dut.rstn.value = 1

  for _ in range((2 ** dut.ALEN.value) + 1):
    dut.i_wen.value = 1
    await RisingEdge(dut.clk)
  await FallingEdge(dut.clk)
  assert dut.o_wfull.value
  assert dut.o_woverflow.value
  dut.i_wen.value = 0

  await RisingEdge(dut.clk)


@cocotb.test()
async def tb_fifo(dut):
  fifo_model = [None] * (2 ** dut.ALEN.value)
  # initialize inputs
  dut.rstn.value = 0
  dut.i_wen.value = 0
  dut.i_wdata.value = 0
  dut.i_ren.value = 0

  # start clock
  cocotb.start_soon(Clock(dut.clk, 10, "ns").start())

  # reset raise
  await ClockCycles(dut.clk, 10)
  dut.rstn.value = 1

  # test cases
  await reset_check(dut)
  fifo_model = await full_test(dut, fifo_model)
  await empty_test(dut, fifo_model)
  await underflow_test(dut)
  await overflow_test(dut)

  await ClockCycles(dut.clk, 10)
  cocotb.log.info("Testing Completed")
