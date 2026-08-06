# Default simulator
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
N ?= 16

# RTL source file (Make sure the path matches your file location)
VERILOG_SOURCES = $(PWD)/src/fp_arb.sv

# SystemVerilog top-level module name inside fp_arb.sv
TOPLEVEL = fp_arb

# Point Python search path to working directory
export PYTHONPATH := $(PWD):$(PYTHONPATH)

# Python test module name (without .py extension)
MODULE = sim.test_fp_arb
COCOTB_TEST_MODULES = sim.test_fp_arb

# Direct test results to sim_build directory so it doesn't clutter root
COCOTB_RESULTS_FILE = $(PWD)/sim_build/results.xml

# Pass RTL parameters (-G<PARAM>=<VALUE>)
COMPILE_ARGS += -GN=$(N)

# Verilator specific flags
EXTRA_ARGS += --trace --trace-structs -Wall -Wno-WIDTHEXPAND -Wno-ALWCOMBORDER -Wno-UNOPTFLAT --coverage

# Makefile include statement
include $(shell cocotb-config --makefiles)/Makefile.sim

#clean target
.PHONY: clean_all
clean_all:
	@rm -rf sim_build
	@rm -rf __pycache__ *.pyc
	@rm -f *.vcd *.fst results.xml

clean:: clean_all
