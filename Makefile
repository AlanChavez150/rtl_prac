*.sv: FORCE
	@mkdir -pv bin/
	iverilog $@ -o bin/$@ -I lib/ -g2005-sv
	@bin/$@
FORCE:

clean:
	rm -rf bin
