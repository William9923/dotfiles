#!/usr/bin/env bash

set -euo pipefail

PROFILE="${1:-minimal}"
FEDORA_IMAGE="${FEDORA_IMAGE:-fedora:latest}"
TEST_CONTAINER_NAME="${TEST_CONTAINER_NAME:-dotfiles-bootstrap-$(date +%Y%m%d%H%M%S)}"
SKIP_MISE_INSTALL="${SKIP_MISE_INSTALL:-1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$SCRIPT_DIR"
CONTAINER_EXIT_CODE=0

cleanup() {
  docker rm -f "$TEST_CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

usage() {
  printf 'Usage: %s [minimal|full]\n' "${0##*/}"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1"; exit 1; }
}

[[ "$PROFILE" == "minimal" || "$PROFILE" == "full" ]] || { usage; exit 1; }

require_cmd docker
[[ -f "$DOTFILES_DIR/setup.sh" ]] || { echo "Missing required repo script: setup.sh"; exit 1; }

docker rm -f "$TEST_CONTAINER_NAME" >/dev/null 2>&1 || true
docker run -d --name "$TEST_CONTAINER_NAME" --entrypoint /bin/bash "$FEDORA_IMAGE" -lc 'while true; do sleep 60; done' >/dev/null

docker exec "$TEST_CONTAINER_NAME" dnf -y install sudo git stow findutils which >/dev/null
docker exec "$TEST_CONTAINER_NAME" bash -lc 'command -v sudo >/dev/null && command -v git >/dev/null && command -v stow >/dev/null'

docker exec "$TEST_CONTAINER_NAME" mkdir -p /root/dotfiles
docker cp "$DOTFILES_DIR/." "$TEST_CONTAINER_NAME:/root/dotfiles"

if [[ -f "$DOTFILES_DIR/.env.example" ]]; then
  docker cp "$DOTFILES_DIR/.env.example" "$TEST_CONTAINER_NAME:/root/dotfiles/zsh/.zsh_secrets"
fi

if [[ "$SKIP_MISE_INSTALL" == "1" ]]; then
  docker exec -e SETUP_SKIP_MISE=1 -e SETUP_SKIP_COMMITIZEN=1 "$TEST_CONTAINER_NAME" bash -lc 'cd /root/dotfiles && ./setup.sh "'$PROFILE'"'
else
  docker exec -e SETUP_SKIP_MISE=0 -e SETUP_SKIP_COMMITIZEN=0 "$TEST_CONTAINER_NAME" bash -lc 'cd /root/dotfiles && ./setup.sh "'$PROFILE'"'
fi

docker exec "$TEST_CONTAINER_NAME" bash -lc 'test -L /root/.zshrc && test -L /root/.gitconfig && test -L /root/.tmux.conf'
echo "PASS: Fedora $PROFILE bootstrap test"
