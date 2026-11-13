.PHONY: all sim synth clean

all: sim

sim:
	mkdir -p sim
	iverilog -g2012 -Wall -o sim/sim.out rtl/priority_encoder_8to3.v tb/tb_priority_encoder.v
	cd sim && vvp sim.out | tee sim.log

synth:
	yosys -q -s synth/syn.ys
	@cat synth/stat.txt

clean:
	rm -f sim/sim.out sim/priority_encoder.vcd
