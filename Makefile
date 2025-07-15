# Makefile for Gemini REPL
.PHONY: help install build dev run test lint clean setup all

# Default target
all: install build

help:
	@echo "Gemini REPL - Available targets:"
	@echo "  make install  - Install npm dependencies"
	@echo "  make build    - Build the application"
	@echo "  make dev      - Run in development mode with live reload"
	@echo "  make run      - Run the compiled REPL"
	@echo "  make test     - Run all tests"
	@echo "  make lint     - Run linter"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make setup    - Complete development setup"

install:
	npm install

build: resources/repl-banner.txt
	npx shadow-cljs compile app

dev:
	GEMINI_LOG_ENABLED=true npx nodemon --watch src --watch target -e cljs,js --exec "npx shadow-cljs compile app && node target/main.js"

run: build
	node target/main.js

test:
	npx shadow-cljs compile test && node target/test.js

lint:
	@if command -v clj-kondo >/dev/null 2>&1; then \
		npx clj-kondo --lint src test; \
	else \
		echo "clj-kondo not installed, skipping lint"; \
	fi

clean:
	rm -rf target .shadow-cljs node_modules

setup: install
	./scripts/setup-dev.sh

# Create banner resource
resources/repl-banner.txt: | resources
	@if command -v toilet >/dev/null 2>&1; then \
		toilet -f future "Gemini REPL" > $@; \
	else \
		echo "=== Gemini REPL ===" > $@; \
	fi

resources:
	mkdir -p resources

# Watch for changes
watch:
	npx shadow-cljs watch app

# REPL for development
repl:
	npx shadow-cljs cljs-repl app
