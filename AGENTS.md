# DOTFILES KNOWLEDGE BASE

## Overview

GNU Stow-managed dotfiles with secrets sourced from a central file.
Main stack: Neovim (LazyVim), Zsh, Tmux, Kitty.

## Structure

```text
dotfiles/
├── code/      # nvim, opencode, copilot, pi agent config + pi-skills
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
| Update pi-skills | `code/.pi/agent/skills/pi-skills/` (tracked directly in dotfiles, no .git) |

## Secret rules

- All secrets live in `zsh/.zsh_secrets` (gitignored, never commit).
- `setup-secrets.sh` sources them and generates config files.
- Edit `zsh/.zsh_secrets`, then rerun `./setup-secrets.sh`.

## Core commands

```bash
./setup-secrets.sh
stow code git terminal tmux zsh
```

## Updating pi-skills

pi-skills is tracked directly in the dotfiles repo (not a submodule). To update:

```bash
# Refresh from upstream, then commit the changes
git remote add upstream git@github.com:badlogic/pi-skills  # once
git fetch upstream
git checkout origin/master -- code/.pi/agent/skills/pi-skills
git add code/.pi/agent/skills/pi-skills
git commit -m "chore: update pi-skills"
```

## Anti-patterns

| Never | Do instead |
|-------|------------|
| Commit `zsh/.zsh_secrets` | Keep it gitignored |
| Commit generated secret-bearing files | Keep them gitignored |
| Hardcode API keys | Use `zsh/.zsh_secrets` + `setup-secrets.sh` |
