# Makefile for Smart Parking System
# Icarus Verilog Simulation with Surfer Waveform Viewer
# Author: Akshat Raj (24BCE0043)

VERILOG = iverilog
VVP = vvp
SURFER = surfer

# Directories
RTL_DIR = rtl
TB_DIR = testbench
SIM_DIR = simulation

# Create simulation directory if it doesn't exist
$(shell mkdir -p $(SIM_DIR))

# Source files
RTL_FILES = $(RTL_DIR)/top_module.v \
            $(RTL_DIR)/vehicle_counter.v \
            $(RTL_DIR)/edge_detector.v \
            $(RTL_DIR)/sensor_debounce.v \
            $(RTL_DIR)/parking_fsm.v \
            $(RTL_DIR)/dual_sensor_validator.v \
            $(RTL_DIR)/display_controller.v \
            $(RTL_DIR)/timer_module.v

# Testbench files
TB_TOP = $(TB_DIR)/tb_top_module.v
TB_COUNTER = $(TB_DIR)/tb_vehicle_counter.v
TB_EDGE = $(TB_DIR)/tb_edge_detector.v
TB_FULL = $(TB_DIR)/tb_real_world_scenarios.v

# Output files
VVP_TOP = $(SIM_DIR)/sim_top.vvp
VVP_COUNTER = $(SIM_DIR)/sim_counter.vvp
VVP_EDGE = $(SIM_DIR)/sim_edge.vvp
VVP_FULL = $(SIM_DIR)/sim_full.vvp

VCD_TOP = $(SIM_DIR)/waveform_top.vcd
VCD_COUNTER = $(SIM_DIR)/waveform_counter.vcd
VCD_EDGE = $(SIM_DIR)/waveform_edge.vcd
VCD_FULL = $(SIM_DIR)/waveform_full.vcd

# Default target
all: test_full

# Compile and run top module
top: compile_top simulate_top

compile_top:
	@echo "══════════════════════════════════════════"
	@echo "  Compiling Top Module..."
	@echo "══════════════════════════════════════════"
	$(VERILOG) -DSIMULATION -o $(VVP_TOP) $(RTL_FILES) $(TB_TOP)
	@echo "✓ Compilation complete!"

simulate_top:
	@echo "Running top module simulation..."
	@$(VVP) $(VVP_TOP)
	@echo "✓ Simulation complete! Waveform: $(VCD_TOP)"

# Compile and run counter test
test_counter: compile_counter simulate_counter

compile_counter:
	@echo "══════════════════════════════════════════"
	@echo "  Compiling Vehicle Counter Test..."
	@echo "══════════════════════════════════════════"
	$(VERILOG) -DSIMULATION -o $(VVP_COUNTER) $(RTL_DIR)/vehicle_counter.v $(TB_COUNTER)
	@echo "✓ Compilation complete!"

simulate_counter:
	@echo "Running counter simulation..."
	@$(VVP) $(VVP_COUNTER)
	@echo "✓ Simulation complete! Waveform: $(VCD_COUNTER)"

# Compile and run edge detector test
test_edge: compile_edge simulate_edge

compile_edge:
	@echo "══════════════════════════════════════════"
	@echo "  Compiling Edge Detector Test..."
	@echo "══════════════════════════════════════════"
	$(VERILOG) -DSIMULATION -o $(VVP_EDGE) $(RTL_DIR)/edge_detector.v $(TB_EDGE)
	@echo "✓ Compilation complete!"

simulate_edge:
	@echo "Running edge detector simulation..."
	@$(VVP) $(VVP_EDGE)
	@echo "✓ Simulation complete! Waveform: $(VCD_EDGE)"

# Compile and run full system test
test_full: compile_full simulate_full

compile_full:
	@echo "══════════════════════════════════════════"
	@echo "  Compiling Full System Test..."
	@echo "══════════════════════════════════════════"
	$(VERILOG) -DSIMULATION -o $(VVP_FULL) $(RTL_FILES) $(TB_FULL)
	@echo "✓ Compilation complete!"

simulate_full:
	@echo "Running comprehensive system test..."
	@$(VVP) $(VVP_FULL)
	@echo ""
	@echo "══════════════════════════════════════════"
	@echo "  ✓ All Tests Complete!"
	@echo "══════════════════════════════════════════"
	@echo "Waveform saved to: $(VCD_FULL)"
	@echo "View with: make wave"
	@echo ""

# Run everything: compile, simulate, and open Surfer
run_all: compile_full simulate_full
	@echo "Opening waveform in Surfer..."
	@if command -v $(SURFER) >/dev/null 2>&1; then \
		$(SURFER) $(VCD_FULL) & \
		echo "✓ Surfer launched!"; \
	else \
		echo "✗ Error: Surfer not found. Install with: brew install surfer"; \
		echo "  Or view waveform manually: surfer $(VCD_FULL)"; \
	fi

# Run all tests sequentially
test_all: test_counter test_edge top test_full
	@echo ""
	@echo "╔════════════════════════════════════════════════════╗"
	@echo "║        ALL TESTS COMPLETED SUCCESSFULLY!           ║"
	@echo "╚════════════════════════════════════════════════════╝"
	@echo ""

# View waveforms with Surfer
wave:
	@echo "Opening full system waveform in Surfer..."
	@if [ -f $(VCD_FULL) ]; then \
		$(SURFER) $(VCD_FULL) & \
		echo "✓ Surfer launched with $(VCD_FULL)"; \
	else \
		echo "✗ Error: Waveform file not found!"; \
		echo "  Run 'make test_full' first to generate waveforms."; \
		exit 1; \
	fi

wave_top:
	@if [ -f $(VCD_TOP) ]; then \
		$(SURFER) $(VCD_TOP) & \
		echo "✓ Viewing top module waveform"; \
	else \
		echo "✗ Error: Run 'make top' first"; \
		exit 1; \
	fi

wave_counter:
	@if [ -f $(VCD_COUNTER) ]; then \
		$(SURFER) $(VCD_COUNTER) & \
		echo "✓ Viewing counter waveform"; \
	else \
		echo "✗ Error: Run 'make test_counter' first"; \
		exit 1; \
	fi

wave_edge:
	@if [ -f $(VCD_EDGE) ]; then \
		$(SURFER) $(VCD_EDGE) & \
		echo "✓ Viewing edge detector waveform"; \
	else \
		echo "✗ Error: Run 'make test_edge' first"; \
		exit 1; \
	fi

# Quick workflow: test and view
quick: test_full wave
	@echo "✓ Test and view complete!"

# Check if tools are installed
check:
	@echo "Checking required tools..."
	@command -v $(VERILOG) >/dev/null 2>&1 && echo "✓ iverilog found" || echo "✗ iverilog not found - install with: brew install icarus-verilog"
	@command -v $(VVP) >/dev/null 2>&1 && echo "✓ vvp found" || echo "✗ vvp not found"
	@command -v $(SURFER) >/dev/null 2>&1 && echo "✓ surfer found" || echo "✗ surfer not found - install with: brew install surfer"
	@echo ""

# Clean generated files
clean:
	@echo "Cleaning simulation files..."
	@rm -rf $(SIM_DIR)/*.vvp $(SIM_DIR)/*.vcd
	@echo "✓ Clean complete!"

# Deep clean (remove simulation directory)
distclean:
	@echo "Removing all generated files and directories..."
	@rm -rf $(SIM_DIR)
	@echo "✓ Deep clean complete!"

# Help
help:
	@echo ""
	@echo "╔════════════════════════════════════════════════════╗"
	@echo "║   Smart Parking System - Makefile Help            ║"
	@echo "║   Author: Akshat Raj (24BCE0043)                  ║"
	@echo "╚════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Quick Start:"
	@echo "  make test_full      # Run comprehensive tests"
	@echo "  make wave           # View waveforms in Surfer"
	@echo "  make quick          # Test and view in one command"
	@echo ""
	@echo "Compilation & Simulation:"
	@echo "  make all            # Run full system test (default)"
	@echo "  make test_full      # Comprehensive system tests"
	@echo "  make test_counter   # Test vehicle counter module"
	@echo "  make test_edge      # Test edge detector module"
	@echo "  make top            # Test top module integration"
	@echo "  make test_all       # Run all tests sequentially"
	@echo "  make run_all        # Compile, simulate, and auto-open Surfer"
	@echo ""
	@echo "Waveform Viewing (Surfer):"
	@echo "  make wave           # View full system waveform"
	@echo "  make wave_top       # View top module waveform"
	@echo "  make wave_counter   # View counter waveform"
	@echo "  make wave_edge      # View edge detector waveform"
	@echo ""
	@echo "Utilities:"
	@echo "  make check          # Check if tools are installed"
	@echo "  make clean          # Remove generated files"
	@echo "  make distclean      # Remove all generated content"
	@echo "  make help           # Show this help message"
	@echo ""
	@echo "Example Workflow:"
	@echo "  1. make check       # Verify tools installed"
	@echo "  2. make test_full   # Run all tests"
	@echo "  3. make wave        # View waveforms"
	@echo ""

.PHONY: all top test_counter test_edge test_full test_all wave wave_top wave_counter \
        wave_edge clean distclean help compile_top simulate_top compile_counter \
        simulate_counter compile_edge simulate_edge compile_full simulate_full \
        run_all quick check