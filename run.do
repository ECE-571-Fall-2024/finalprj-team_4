vlog +define+DEBUG fcfs_rrarbiter.sv tb_fcfs_rrarbiter.sv

#vlog fcfs_rrarbiter
#vlog tb_fcfs_rrarbiter

vsim work.tb_FCFS_Weighted_RR_Arbiter
vsim -voptargs=+acc work.tb_FCFS_Weighted_RR_Arbiter
add wave sim:tb_FCFS_Weighted_RR_Arbiter/*

run -all