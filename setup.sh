#!/usr/bin/env bash

set -euo pipefail

PROFILE="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"
PACKAGES_DIR="$DOTFILES_DIR/packages"
STOW_PACKAGES=(code git terminal tmux zsh config commitizen)
BACKUP_DIR=""
PROFILE_NAME=""
STOW_STATUS="not started"
MISE_STATUS="skipped"
COMMITIZEN_STATUS="skipped"
SETUP_SKIP_MISE="${SETUP_SKIP_MISE:-0}"
SETUP_SKIP_COMMITIZEN="${SETUP_SKIP_COMMITIZEN:-0}"
SETUP_SKIP_PACKAGES="${SETUP_SKIP_PACKAGES:-0}"

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
  if [[ "$SETUP_SKIP_PACKAGES" == "1" ]]; then
    echo "Skipping package install (SETUP_SKIP_PACKAGES=1)."
    return 0
  fi

  local profile_file="$1"
  local pkgs=()
  local installable=()
  local missing=()
  local pkg

  [[ -f "$profile_file" ]] || { echo "Missing package profile: $profile_file"; exit 1; }

  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    pkgs+=("$line")
  done < "$profile_file"

  if ((${#pkgs[@]})); then
    for pkg in "${pkgs[@]}"; do
      if sudo dnf -q info "$pkg" >/dev/null 2>&1; then
        installable+=("$pkg")
      else
        missing+=("$pkg")
      fi
    done

    if ((${#installable[@]})); then
      sudo dnf install -y "${installable[@]}"
    fi

    if ((${#missing[@]})); then
      echo "Warning: skipped unavailable packages: ${missing[*]}"
    fi
  fi
}

install_mise_tools() {
  if [[ "$SETUP_SKIP_MISE" == "1" ]]; then
    echo "Skipping mise tool install (SETUP_SKIP_MISE=1)."
    MISE_STATUS="skipped (SETUP_SKIP_MISE=1)"
    return 0
  fi

  local mise_config="$HOME/.config/mise/config.toml"

  if command -v mise >/dev/null 2>&1 && [[ -f "$mise_config" ]]; then
    if mise install -y; then
      MISE_STATUS="installed"
    else
      MISE_STATUS="failed (check mise config and tool definitions)"
      echo "Warning: mise install -y failed; continuing."
    fi
  else
    echo "Skipping mise tool install (missing mise command or config)."
    MISE_STATUS="skipped"
  fi
}

install_commitizen() {
  if [[ "$SETUP_SKIP_COMMITIZEN" == "1" ]]; then
    echo "Skipping Commitizen install (SETUP_SKIP_COMMITIZEN=1)."
    COMMITIZEN_STATUS="skipped (SETUP_SKIP_COMMITIZEN=1)"
    return 0
  fi

  if command -v npm >/dev/null 2>&1; then
    if ! npm install -g commitizen cz-conventional-changelog; then
      COMMITIZEN_STATUS="failed (try 'npm config set prefix ~/.local' and ensure ~/.local/bin is in PATH)"
      echo "Warning: failed to install Commitizen globally via npm; continuing."
    else
      COMMITIZEN_STATUS="installed"
    fi
  else
    echo "Skipping Commitizen install (npm not available; install runtimes via mise first)."
    COMMITIZEN_STATUS="skipped (npm missing; run 'mise install' then rerun setup)"
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
          mkdir -p "$conflict_root/$(dirname "$rel")"
          mv "$target" "$conflict_root/$rel"
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
  PROFILE_NAME="$PROFILE"
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
  STOW_STATUS="stowed ${#STOW_PACKAGES[@]} packages"

  install_mise_tools
  install_commitizen

  echo "Setup complete."
  echo "--- Summary ---"
  echo "Profile: $PROFILE_NAME"
  echo "Stowed packages: ${STOW_PACKAGES[*]}"
  echo "Backup path: ${backup_dir:-none}"
  echo "Optional: mise install => $MISE_STATUS"
  echo "Optional: commitizen install => $COMMITIZEN_STATUS"
}

main "$@"
