*.sv: FORCE
	@mkdir -pv tb_results/
	iverilog $@ -o tb_results/${basename $@}.vvp -I lib/ -g2012 -s tb_${basename $@}
	@vvp tb_results/${basename $@}.vvp

lib/*.sv: FORCE
	@mkdir -pv tb_results/lib/
	iverilog $@ -o tb_results/${basename $@}.vvp -I lib/ -g2012 -s tb_${basename $@}
	@vvp tb_results/$@.vvp

FORCE:
clean:
	rm -rf tb_results
