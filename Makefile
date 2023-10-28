*.sv: FORCE
	@mkdir -pv tb_results/
	iverilog $@ -o tb_results/$@.vvp -I lib/ -g2012
	@vvp tb_results/$@.vvp

lib/*.sv: FORCE
	@mkdir -pv tb_results/lib/
	iverilog $@ -o tb_results/$@.vvp -I lib/ -g2012
	@vvp tb_results/$@.vvp

FORCE:
clean:
	rm -rf tb_results
