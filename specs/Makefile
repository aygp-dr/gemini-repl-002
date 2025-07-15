# Makefile for formal specifications
.PHONY: all check-tla check-alloy clean

all: check-tla check-alloy

check-tla:
	@echo "Checking TLA+ specifications..."
	@for spec in *.tla; do \
		if [ -f "$$spec" ]; then \
			echo "Checking $$spec..."; \
			java -jar ../tools/formal-methods/tla2tools.jar $$spec || true; \
		fi \
	done

check-alloy:
	@echo "Checking Alloy models..."
	@for model in *.als; do \
		if [ -f "$$model" ]; then \
			echo "Checking $$model..."; \
			java -jar ../tools/formal-methods/alloy.jar $$model || true; \
		fi \
	done

clean:
	rm -f *.log *.out
