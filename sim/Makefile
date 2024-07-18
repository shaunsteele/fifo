
REPO_DIR := /home/shaun/repos/fifo

RTL_DIR := $(REPO_DIR)/rtl

SIM ?= verilator

EXTRA_ARGS += --trace --trace-structs

TOPLEVELLANG ?= verilog

VERILOG_SOURCES += $(RTL_DIR)/sp_ram.sv
VERILOG_SOURCES += $(RTL_DIR)/wr_ptr.sv
VERILOG_SOURCES += $(RTL_DIR)/rd_ptr.sv
VERILOG_SOURCES += $(RTL_DIR)/fifo.sv

TOPLEVEL = fifo

MODULE = tb_fifo

include $(shell cocotb-config --makefiles)/Makefile.sim

WAVEFILE = dump.vcd

.PHONY: waves
waves:
	gtkwave $(WAVEFILE)
