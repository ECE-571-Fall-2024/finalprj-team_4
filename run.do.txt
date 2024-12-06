#compiling design
vlog  fcfs_rrarbiter.sv
vlog  tb_fcfs_rrarbiter.sv

#simulation
vsim testbench filename without.sv

#run simulation
run-all

#exit
quit -f


