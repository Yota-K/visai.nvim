.PHONY: test test-unit test-integration test-file setup clean

PLENARY_DIR := $(HOME)/.local/share/nvim/site/pack/vendor/start/plenary.nvim

setup:
	@if [ ! -d "$(PLENARY_DIR)" ]; then \
		echo "Installing plenary.nvim..."; \
		mkdir -p $(dir $(PLENARY_DIR)); \
		git clone --depth 1 https://github.com/nvim-lua/plenary.nvim $(PLENARY_DIR); \
	else \
		echo "plenary.nvim already installed"; \
	fi

test: setup
	nvim --headless -u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua', sequential = true}"

test-unit: setup
	nvim --headless -u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/unit/ {minimal_init = 'tests/minimal_init.lua', sequential = true}"

test-integration: setup
	nvim --headless -u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/integration/ {minimal_init = 'tests/minimal_init.lua', sequential = true}"

test-file: setup
ifndef FILE
	$(error FILE is not set. Usage: make test-file FILE=tests/unit/selection_spec.lua)
endif
	nvim --headless -u tests/minimal_init.lua \
		-c "PlenaryBustedFile $(FILE)"

clean:
	rm -rf $(PLENARY_DIR)
