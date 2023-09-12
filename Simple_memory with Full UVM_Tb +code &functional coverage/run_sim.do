vlib work
vlog memory.v memory_tb.sv +cover
vsim -voptargs=+acc work.memory_tb -cover
add wave -position insertpoint  \
sim:/memory_tb/in1/Address \
sim:/memory_tb/in1/clk \
sim:/memory_tb/in1/clk_period \
sim:/memory_tb/in1/Data_in \
sim:/memory_tb/in1/Data_out \
sim:/memory_tb/in1/read_En \
sim:/memory_tb/in1/rst \
sim:/memory_tb/in1/write_En
coverage save memory_tb.ucdb -onexit -du memory
run -all
coverage report -output functional_coverage_rpt.txt -srcfile=* -detail -all -dump -annotate -directive -cvg
quit -sim
vcover report memory_tb.ucdb -details -annotate -all -output code_coverage_rpt.txt

 