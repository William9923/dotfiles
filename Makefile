PACKAGES ?= code commitizen config git mise terminal tmux zsh

.PHONY: help doctor check install restow uninstall setup-minimal setup-full sync setup-secrets test-bootstrap-fedora test-bootstrap-fedora-full

help:
	@printf '%s\n' "Targets: help doctor check install restow uninstall setup-minimal setup-full sync setup-secrets test-bootstrap-fedora test-bootstrap-fedora-full"

doctor:
	@command -v git >/dev/null
	@command -v stow >/dev/null
	@command -v dnf >/dev/null
	@printf '%s\n' "Fedora toolchain looks available."

check:
	@bash -n setup.sh
	@bash -n setup-secrets.sh
	@bash -n bin/.local/bin/sync-dots

install:
	@stow --no-folding --target="$$HOME" $(PACKAGES)

restow:
	@stow --no-folding --restow --target="$$HOME" $(PACKAGES)

uninstall:
	@stow --no-folding --delete --target="$$HOME" $(PACKAGES)

setup-minimal:
	@./setup.sh minimal

setup-full:
	@./setup.sh full

sync:
	@bin/.local/bin/sync-dots

setup-secrets:
	@./setup-secrets.sh

test-bootstrap-fedora:
	@./test-bootstrap-fedora.sh minimal

test-bootstrap-fedora-full:
	@./test-bootstrap-fedora.sh full
