#!/usr/bin/env bash

set -euo pipefail

PROFILE="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"
PACKAGES_DIR="$DOTFILES_DIR/packages"
STOW_PACKAGES=(code git terminal tmux zsh config commitizen)
BACKUP_DIR=""

usage() {
  echo "Usage: $0 minimal|full"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1"; exit 1; }
}

is_fedora() {
  if [[ -f /etc/fedora-release ]]; then
    return 0
  fi

  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    [[ "${ID:-}" == "fedora" ]]
    return
  fi

  return 1
}

install_packages() {
  local profile_file="$1"
  local pkgs=()

  [[ -f "$profile_file" ]] || { echo "Missing package profile: $profile_file"; exit 1; }

  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    pkgs+=("$line")
  done < "$profile_file"

  if ((${#pkgs[@]})); then
    sudo dnf install -y "${pkgs[@]}"
  fi
}

install_mise_tools() {
  local mise_config="$HOME/.config/mise/config.toml"

  if command -v mise >/dev/null 2>&1 && [[ -f "$mise_config" ]]; then
    mise install -y
  else
    echo "Skipping mise tool install (missing mise command or config)."
  fi
}

install_commitizen() {
  if command -v npm >/dev/null 2>&1; then
    if ! npm install -g commitizen cz-conventional-changelog; then
      echo "Warning: failed to install Commitizen globally via npm; continuing."
    fi
  else
    echo "Skipping Commitizen install (npm not available)."
  fi
}

backup_conflicts() {
  local backup_root="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)-setup"
  local conflict_root="$backup_root/conflicts"
  mkdir -p "$conflict_root"

  BACKUP_DIR="$backup_root"

  for pkg in "${STOW_PACKAGES[@]}"; do
    local src="$DOTFILES_DIR/$pkg"
    [[ -d "$src" ]] || continue

    while IFS= read -r source_file; do
      local rel="${source_file#"$src/"}"
      [[ -z "$rel" ]] && continue

      local target="$HOME/$rel"

      if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
          local resolved_target resolved_source
          resolved_target="$(readlink -f "$target" 2>/dev/null || true)"
          resolved_source="$(readlink -f "$source_file" 2>/dev/null || true)"
          [[ "$resolved_target" == "$resolved_source" ]] && continue
          rm -f "$target"
          continue
        fi

        mkdir -p "$conflict_root/$(dirname "$rel")"
        mv "$target" "$conflict_root/$rel"
      fi
    done < <(find "$src" \( -type f -o -type l \) -print)
  done
}

main() {
  [[ $# -eq 1 ]] || { usage; exit 1; }
  [[ "$PROFILE" == "minimal" || "$PROFILE" == "full" ]] || { usage; exit 1; }
  is_fedora || { echo "This setup script currently supports Fedora Linux only."; exit 1; }

  require_cmd sudo
  require_cmd dnf
  require_cmd stow

  echo "Installing Fedora $PROFILE packages..."
  install_packages "$PACKAGES_DIR/fedora-$PROFILE.txt"

  if [[ -x "$DOTFILES_DIR/setup-secrets.sh" ]]; then
    "$DOTFILES_DIR/setup-secrets.sh"
  fi

  local backup_dir
  backup_conflicts
  backup_dir="$BACKUP_DIR"

  for pkg in "${STOW_PACKAGES[@]}"; do
    stow --dir="$DOTFILES_DIR" --target="$HOME" --no-folding "$pkg"
  done

  install_mise_tools
  install_commitizen

  echo "Setup complete."
  echo "Backup dir: $backup_dir"
  echo "Packages: ${STOW_PACKAGES[*]}"
}

main "$@"
