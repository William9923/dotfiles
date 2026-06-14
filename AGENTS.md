# DOTFILES KNOWLEDGE BASE

## Overview

GNU Stow-managed dotfiles with secrets sourced from a central file.
Main stack: Neovim (LazyVim), Zsh, Tmux, Kitty.

## Structure

```text
dotfiles/
├── code/      # nvim, opencode, copilot
├── git/       # git + lazygit
├── terminal/  # kitty + atuin
├── tmux/      # tmux
├── zsh/       # shell + secrets
└── setup-secrets.sh
```

## Where to look

| Task | Location |
|------|----------|
| Add nvim plugin | `code/.config/nvim/lua/plugins/` |
| Change nvim keymap | `code/.config/nvim/lua/config/keymaps.lua` |
| Edit nvim options | `code/.config/nvim/lua/config/options.lua` |
| Add secret/API key | `zsh/.zsh_secrets` |
| Configure OpenCode | `code/.config/opencode/opencode.json` (uses `{env:VAR}` syntax) |
| Add git alias | `git/.gitconfig` |

## Secret rules

- All secrets live in `zsh/.zsh_secrets` (gitignored, never commit).
- `setup-secrets.sh` sources them and generates config files.
- Edit `zsh/.zsh_secrets`, then rerun `./setup-secrets.sh`.

## Core commands

```bash
./setup-secrets.sh
stow code git terminal tmux zsh
```

## Anti-patterns

| Never | Do instead |
|-------|------------|
| Commit `zsh/.zsh_secrets` | Keep it gitignored |
| Commit generated secret-bearing files | Keep them gitignored |
| Hardcode API keys | Use `zsh/.zsh_secrets` + `setup-secrets.sh` |
