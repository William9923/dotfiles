# DOTFILES KNOWLEDGE BASE

## Overview

GNU Stow-managed dotfiles with template-based secret handling.
Main stack: Neovim (LazyVim), Zsh, Tmux, Kitty.

## Structure

```text
dotfiles/
├── code/      # nvim, opencode, copilot
├── git/       # git + lazygit
├── terminal/  # kitty + atuin
├── tmux/      # tmux
├── zsh/       # shell + secrets
├── setup-secrets.sh
└── update-gitignore.sh
```

## Where to look

| Task | Location |
|------|----------|
| Add nvim plugin | `code/.config/nvim/lua/plugins/` |
| Change nvim keymap | `code/.config/nvim/lua/config/keymaps.lua` |
| Edit nvim options | `code/.config/nvim/lua/config/options.lua` |
| Add secret/API key | `zsh/.zsh_secrets` + `.tmpl` source |
| Configure OpenCode | `code/.config/opencode/opencode.json.tmpl` |
| Add git alias | `git/.gitconfig` |

## Critical template rules

- Commit `.tmpl` files with `${VAR}` placeholders only.
- Do not commit generated secret-bearing files.
- Source secrets from `zsh/.zsh_secrets`.
- Use `setup-secrets.sh` (`envsubst`) to render templates.
- For OpenCode, keep config minimal and edit `opencode.json.tmpl` (not generated `opencode.json`).

## Core commands

```bash
./setup-secrets.sh
stow code git terminal tmux zsh
./update-gitignore.sh > .gitignore
```

## Anti-patterns

| Never | Do instead |
|-------|------------|
| Commit `zsh/.zsh_secrets` | Keep it gitignored; use templates |
| Commit generated non-template config | Commit `.tmpl` source only |
| Hardcode API keys | Use `${VAR}` placeholders in templates |
| Edit generated config directly | Edit `.tmpl`, then regenerate |
