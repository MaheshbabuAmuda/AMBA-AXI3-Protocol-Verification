#===============================================================================
# Makefile for AXI3-Protocol-Verification IP Testbench
# (SystemVerilog + UVM)
#===============================================================================

# Simulator
SIMULATOR = Questa

# DESIGN / TESTBENCH FILE PATHS
RTL   = ../Interface/*
SVTB1 = ../tb_top/Axi3_top.sv
SVTB2 = ../test/Axi3_package.sv

# Questa work library
work = work

# INCLUDE DIRECTORIES
INC = +incdir+../test \
      +incdir+../env_lib \
      +incdir+../Master_UVC \
      +incdir+../Slave_UVC \
      +incdir+../Interface

# QUESTA SIMULATION OPTIONS
VSIMOPT = -vopt -voptargs=+acc
VSIMCOV = -coverage -sva

# BATCH MODE COMMANDS
VSIMBATCH1 = -c -do "log -r /* ; coverage save -onexit mem_cov1 ; run -all ; exit"
VSIMBATCH2 = -c -do "log -r /* ; coverage save -onexit mem_cov2 ; run -all ; exit"
VSIMBATCH3 = -c -do "log -r /* ; coverage save -onexit mem_cov3 ; run -all ; exit"
VSIMBATCH4 = -c -do "log -r /* ; coverage save -onexit mem_cov4 ; run -all ; exit"
VSIMBATCH5 = -c -do "log -r /* ; coverage save -onexit mem_cov5 ; run -all ; exit"

#===============================================================================
# HELP
#===============================================================================

help:
	@echo "==========================================================================="
	@echo "                 AXI3 UVM TESTBENCH - MAKEFILE"
	@echo "==========================================================================="
	@echo ""
	@echo "Compilation:"
	@echo " make clean       : Clean previous simulation files"
	@echo " make sv_cmp      : Compile AXI3 UVM testbench"
	@echo ""
	@echo "Test Execution:"
	@echo " make run_test    : Run fixed_seq_test"
	@echo " make run_test1   : Run incr_seq_test"
	@echo " make run_test2   : Run wrap_seq_test"
	@echo " make run_test3   : Run random_seq_test"
	@echo " make run_test4   : Run multiple_outs_test"
	@echo ""
	@echo "Waveform:"
	@echo " make view_wave   : View fixed_seq_test waveform"
	@echo " make view_wave1  : View incr_seq_test waveform"
	@echo " make view_wave2  : View wrap_seq_test waveform"
	@echo " make view_wave3  : View random_seq_test waveform"
	@echo " make view_wave4  : View multiple_outs_test waveform"
	@echo ""
	@echo "Coverage:"
	@echo " make regress     : Run all 5 tests and merge coverage"
	@echo " make report      : Generate HTML coverage report"
	@echo " make cov         : Open merged coverage report"
	@echo "==========================================================================="

     # GENERIC TARGETS
clean      : clean_$(SIMULATOR)
sv_cmp     : sv_cmp_$(SIMULATOR)

run_test   : run_test_$(SIMULATOR)
run_test1  : run_test1_$(SIMULATOR)
run_test2  : run_test2_$(SIMULATOR)
run_test3  : run_test3_$(SIMULATOR)
run_test4  : run_test4_$(SIMULATOR)

view_wave  : view_wave_$(SIMULATOR)
view_wave1 : view_wave1_$(SIMULATOR)
view_wave2 : view_wave2_$(SIMULATOR)
view_wave3 : view_wave3_$(SIMULATOR)
view_wave4 : view_wave4_$(SIMULATOR)

regress    : regress_$(SIMULATOR)
report     : report_$(SIMULATOR)
cov        : cov_$(SIMULATOR)

# COMPILATION

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1)

#===============================================================================
# TEST 1 - FIXED BURST
#===============================================================================

run_test_Questa: clean sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1) \
	-wlf wave_file1.wlf -l test1.log -sv_seed random \
	work.top +UVM_TESTNAME=fixed_seq_test

	vcover report -cvg -details -nocompactcrossbins \
	-codeAll -assert -directive -html mem_cov1

#===============================================================================
# TEST 2 - INCR BURST
#===============================================================================

run_test1_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2) \
	-wlf wave_file2.wlf -l test2.log -sv_seed random \
	work.top +UVM_TESTNAME=incr_seq_test

	vcover report -cvg -details -nocompactcrossbins \
	-codeAll -assert -directive -html mem_cov2

#===============================================================================
# TEST 3 - WRAP BURST
#===============================================================================

run_test2_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3) \
	-wlf wave_file3.wlf -l test3.log -sv_seed random \
	work.top +UVM_TESTNAME=wrap_seq_test

	vcover report -cvg -details -nocompactcrossbins \
	-codeAll -assert -directive -html mem_cov3

#===============================================================================
# TEST 4 - RANDOM
#===============================================================================

run_test3_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4) \
	-wlf wave_file4.wlf -l test4.log -sv_seed random \
	work.top +UVM_TESTNAME=random_seq_test

	vcover report -cvg -details -nocompactcrossbins \
	-codeAll -assert -directive -html mem_cov4

#===============================================================================
# TEST 5 - MULTIPLE OUTSTANDING
#===============================================================================

run_test4_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH5) \
	-wlf wave_file5.wlf -l test5.log -sv_seed random \
	work.top +UVM_TESTNAME=multiple_outs_test

	vcover report -cvg -details -nocompactcrossbins \
	-codeAll -assert -directive -html mem_cov5


# WAVEFORM VIEWERS

view_wave_Questa:
	vsim -view wave_file1.wlf

view_wave1_Questa:
	vsim -view wave_file2.wlf

view_wave2_Questa:
	vsim -view wave_file3.wlf

view_wave3_Questa:
	vsim -view wave_file4.wlf

view_wave4_Questa:
	vsim -view wave_file5.wlf

# COVERAGE MERGE / REPORT

report_Questa:
	vcover merge mem_cov mem_cov1 mem_cov2 mem_cov3 mem_cov4 mem_cov5
	vcover report -cvg -details -nocompactcrossbins \
	-codeAll -assert -directive -html mem_cov
	vcover report -details mem_cov > sum_report.txt

# REGRESSION

regress_Questa: clean_Questa run_test_Questa run_test1_Questa \
	run_test2_Questa run_test3_Questa run_test4_Questa report_Questa

# OPEN COVERAGE REPORT

cov_Questa:
	firefox covhtmlreport/index.html &

# CLEAN

clean_Questa:
	rm -rf transcript* *log* fcover* covhtml* mem_cov* \
	*.wlf modelsim.ini work
	clear
