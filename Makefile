.PHONY: test-install test test-clean help

# Default target
help:
	@echo "Dotfiles Testing Targets:"
	@echo "  make test-install  - Install Bats testing framework"
	@echo "  make test          - Run all Bats tests"
	@echo "  make test-clean    - Clean test artifacts and temp files"

# Install Bats testing framework
test-install:
	@echo "Installing Bats testing framework..."
	@if command -v bats >/dev/null 2>&1; then \
		echo "✓ Bats already installed: $$(bats --version)"; \
	elif command -v brew >/dev/null 2>&1; then \
		echo "Installing via Homebrew..."; \
		brew install bats-core; \
	elif command -v apt-get >/dev/null 2>&1; then \
		echo "Installing via apt..."; \
		sudo apt-get update && sudo apt-get install -y bats; \
	elif command -v npm >/dev/null 2>&1; then \
		echo "Installing via npm..."; \
		npm install -g bats; \
	else \
		echo "❌ Error: No supported package manager found (brew, apt, npm)"; \
		echo "Please install Bats manually: https://bats-core.readthedocs.io/"; \
		exit 1; \
	fi
	@echo "✓ Bats installation complete"

# Run all tests
test:
	@echo "Running dotfiles tests..."
	@if ! command -v bats >/dev/null 2>&1; then \
		echo "❌ Error: Bats not installed. Run 'make test-install' first."; \
		exit 1; \
	fi
	@chmod +x tests/fixtures/bin/*
	@bats tests/logic/

# Clean test artifacts
test-clean:
	@echo "Cleaning test artifacts..."
	@rm -rf tests/tmp/
	@find tests/ -name "*.log" -type f -delete 2>/dev/null || true
	@echo "✓ Test cleanup complete"
