# Makefile for Gemini REPL

# Project configuration
PROJECT_NAME ?= gemini-repl-002
PROJECT_ROOT ?= $(shell pwd)
EMACS_CONFIG := $(PROJECT_NAME).el
TMUX_SESSION := $(PROJECT_NAME)

.PHONY: help install build dev run test lint clean setup all emacs-setup emacs-start emacs-stop

# Default target
all: install build

help:
	@echo "Gemini REPL - Available targets:"
	@echo "  make install     - Install npm dependencies"
	@echo "  make build       - Build the application"
	@echo "  make dev         - Run in development mode with live reload"
	@echo "  make run         - Run the compiled REPL"
	@echo "  make test        - Run all tests"
	@echo "  make lint        - Run linter"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make setup       - Complete development setup"
	@echo "  make emacs-setup - Create Emacs configuration"
	@echo "  make emacs-start - Start Emacs in tmux session"
	@echo "  make emacs-stop  - Stop tmux/Emacs session"

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

# Emacs/tmux integration for Clojure development
emacs-setup: $(EMACS_CONFIG)

$(EMACS_CONFIG):
	@echo "Creating Emacs configuration for $(PROJECT_NAME)..."
	@echo ";; Emacs configuration for $(PROJECT_NAME)" > $(EMACS_CONFIG)
	@echo ";; Generated on $$(date)" >> $(EMACS_CONFIG)
	@echo "" >> $(EMACS_CONFIG)
	@echo ";; Project settings" >> $(EMACS_CONFIG)
	@echo "(setq project-root \"$(PROJECT_ROOT)\")" >> $(EMACS_CONFIG)
	@echo "(setq project-name \"$(PROJECT_NAME)\")" >> $(EMACS_CONFIG)
	@echo "" >> $(EMACS_CONFIG)
	@echo ";; Load essential packages" >> $(EMACS_CONFIG)
	@echo "(require 'package)" >> $(EMACS_CONFIG)
	@echo "(add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\") t)" >> $(EMACS_CONFIG)
	@echo "(package-initialize)" >> $(EMACS_CONFIG)
	@echo "" >> $(EMACS_CONFIG)
	@echo ";; Install packages if not present" >> $(EMACS_CONFIG)
	@echo "(unless (package-installed-p 'cider)" >> $(EMACS_CONFIG)
	@echo "  (package-refresh-contents)" >> $(EMACS_CONFIG)
	@echo "  (package-install 'cider))" >> $(EMACS_CONFIG)
	@echo "(unless (package-installed-p 'clojure-mode)" >> $(EMACS_CONFIG)
	@echo "  (package-install 'clojure-mode))" >> $(EMACS_CONFIG)
	@echo "(unless (package-installed-p 'paredit)" >> $(EMACS_CONFIG)
	@echo "  (package-install 'paredit))" >> $(EMACS_CONFIG)
	@echo "" >> $(EMACS_CONFIG)
	@echo ";; Configure Clojure development" >> $(EMACS_CONFIG)
	@echo "(require 'cider)" >> $(EMACS_CONFIG)
	@echo "(require 'clojure-mode)" >> $(EMACS_CONFIG)
	@echo "(require 'paredit)" >> $(EMACS_CONFIG)
	@echo "" >> $(EMACS_CONFIG)
	@echo ";; Enable paredit for Clojure" >> $(EMACS_CONFIG)
	@echo "(add-hook 'clojure-mode-hook #'paredit-mode)" >> $(EMACS_CONFIG)
	@echo "(add-hook 'cider-repl-mode-hook #'paredit-mode)" >> $(EMACS_CONFIG)
	@echo "" >> $(EMACS_CONFIG)
	@echo ";; CIDER configuration" >> $(EMACS_CONFIG)
	@echo "(setq cider-repl-display-help-banner nil)" >> $(EMACS_CONFIG)
	@echo "(setq cider-shadow-cljs-command \"npx shadow-cljs\")" >> $(EMACS_CONFIG)
	@echo "(setq cider-default-cljs-repl 'shadow)" >> $(EMACS_CONFIG)
	@echo "(setq cider-shadow-default-options \"app\")" >> $(EMACS_CONFIG)
	@echo "" >> $(EMACS_CONFIG)
	@echo ";; Org-mode configuration for literate programming" >> $(EMACS_CONFIG)
	@echo "(require 'org)" >> $(EMACS_CONFIG)
	@echo "(org-babel-do-load-languages" >> $(EMACS_CONFIG)
	@echo " 'org-babel-load-languages" >> $(EMACS_CONFIG)
	@echo " '((clojure . t)))" >> $(EMACS_CONFIG)
	@echo "" >> $(EMACS_CONFIG)
	@echo ";; Start in project directory" >> $(EMACS_CONFIG)
	@echo "(cd project-root)" >> $(EMACS_CONFIG)
	@echo "(message \"Emacs configured for %s\" project-name)" >> $(EMACS_CONFIG)
	@echo "Configuration created: $(EMACS_CONFIG)"

emacs-start: emacs-setup
	@echo "Starting Emacs in tmux session: $(TMUX_SESSION)"
	@if tmux has-session -t $(TMUX_SESSION) 2>/dev/null; then \
		echo "Session $(TMUX_SESSION) already exists. Attaching..."; \
		tmux attach-session -t $(TMUX_SESSION); \
	else \
		tmux new-session -d -s $(TMUX_SESSION) "emacs -nw -Q -l $(EMACS_CONFIG)"; \
		echo "Started tmux session: $(TMUX_SESSION)"; \
		echo "TTY: $$(tmux list-panes -t $(TMUX_SESSION) -F '#{pane_tty}')"; \
		echo "Run 'tmux attach -t $(TMUX_SESSION)' to connect"; \
	fi

emacs-stop:
	@echo "Stopping tmux session: $(TMUX_SESSION)"
	@if tmux has-session -t $(TMUX_SESSION) 2>/dev/null; then \
		tmux kill-session -t $(TMUX_SESSION); \
		echo "Session $(TMUX_SESSION) terminated"; \
	else \
		echo "No session named $(TMUX_SESSION) found"; \
	fi

# Get the TTY of the running Emacs session
emacs-tty:
	@if tmux has-session -t $(TMUX_SESSION) 2>/dev/null; then \
		echo "TTY: $$(tmux list-panes -t $(TMUX_SESSION) -F '#{pane_tty}')"; \
	else \
		echo "No session named $(TMUX_SESSION) found"; \
	fi
