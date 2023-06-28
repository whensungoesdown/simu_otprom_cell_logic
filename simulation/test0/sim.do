# list all signals in decimal format
add list -decimal *

#change radix to symbolic
radix -symbolic

#add wave *
#add wave u_top.clk
#add wave u_top.resetn

add wave -position end  sim:/top_tb/clk
add wave -position end  sim:/top_tb/resetn
add wave -position end  sim:/top_tb/u_top/u_agent/timing0n
add wave -position end  sim:/top_tb/u_top/u_agent/timing1n
add wave -position end  sim:/top_tb/u_top/u_agent/timing2n

add wave -position end  sim:/top_tb/u_top/u_agent/s_ram_raddr
add wave -position end  sim:/top_tb/u_top/u_agent/s_ram_rdata
add wave -position end  sim:/top_tb/u_top/u_agent/s_ram_ren
add wave -position end  sim:/top_tb/u_top/u_agent/otprom_secure_debug_disable

add wave -position end  sim:/top_tb/u_top/u_agent/sec_en
add wave -position end  sim:/top_tb/u_top/u_agent/secure_debug_disable
run 500ns

# read in stimulus
#do stim.do

# output results
write list test.lst

# quit the simulation
quit -f
