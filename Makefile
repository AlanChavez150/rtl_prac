*.sv: FORCE
	@mkdir -pv bin/
	iverilog $@ -o bin/$@ -I lib/ -g2012
	@bin/$@
FORCE:

clean:
	rm -rf bin
