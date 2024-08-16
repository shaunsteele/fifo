
REPO_DIR := /home/shaun/repos/fifo

RTL_DIR := $(REPO_DIR)/rtl

SIM ?= icarus
WAVES = 1

TOPLEVELLANG ?= verilog

VERILOG_SOURCES += $(RTL_DIR)/sp_ram.sv
VERILOG_SOURCES += $(RTL_DIR)/wr_ptr.sv
VERILOG_SOURCES += $(RTL_DIR)/rd_ptr.sv
VERILOG_SOURCES += $(RTL_DIR)/fifo.sv

TOPLEVEL = fifo
WAVEFILE = sim_build/$(TOPLEVEL).fst

MODULE = tb_fifo

include $(shell cocotb-config --makefiles)/Makefile.sim


.PHONY: waves
waves:
	gtkwave $(WAVEFILE)
