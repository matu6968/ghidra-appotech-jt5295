GHIDRA_INSTALL_DIR ?=
SLEIGH := $(GHIDRA_INSTALL_DIR)/support/sleigh

.PHONY: build install

build:
	@test -x "$(SLEIGH)" || { echo "Set GHIDRA_INSTALL_DIR to a Ghidra installation" >&2; exit 1; }
	cd data && "$(SLEIGH)" -i sleighArgs.txt -a ./languages

install: build
	@test -n "$(GHIDRA_INSTALL_DIR)" || { echo "Set GHIDRA_INSTALL_DIR to a Ghidra installation" >&2; exit 1; }
	./install.sh "$(GHIDRA_INSTALL_DIR)"
