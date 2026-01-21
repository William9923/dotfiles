# DOTFILES KNOWLEDGE BASE

**Generated:** 2026-01-22 | **Commit:** 296b386 | **Branch:** master

## OVERVIEW

GNU Stow-managed dotfiles with template-based secret handling. Stack: Neovim (LazyVim), Zsh, Tmux, Kitty.

## STRUCTURE

```
dotfiles/
├── code/           # Editor configs (nvim, opencode, copilot)
├── git/            # Git + lazygit
├── terminal/       # Kitty + atuin
├── tmux/           # Tmux multiplexer
├── zsh/            # Shell + secrets
├── setup-secrets.sh    # Template processor
└── update-gitignore.sh # Auto-gitignore generator
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add nvim plugin | `code/.config/nvim/lua/plugins/` | Return plugin spec table |
| Change nvim keymap | `code/.config/nvim/lua/config/keymaps.lua` | Use `vim.keymap.set` |
| Edit nvim options | `code/.config/nvim/lua/config/options.lua` | `vim.opt` for options, `vim.g` for globals |
| Add secret/API key | `zsh/.zsh_secrets` + create `.tmpl` | Never commit secrets file |
| Configure opencode | `code/.config/opencode/` | Uses .tmpl for API keys |
| Add git alias | `git/.gitconfig` | Standard git config |

## COMMANDS

```bash
# Setup (first time or after adding secrets)
./setup-secrets.sh

# Install dotfiles (symlink to ~)
stow code git terminal tmux zsh

# Update gitignore after adding .tmpl files
./update-gitignore.sh > .gitignore
```

## CONVENTIONS

### Template System (CRITICAL)
- `.tmpl` files → committed, contain `${VAR}` placeholders
- Generated files → gitignored, contain real secrets
- Secrets source: `zsh/.zsh_secrets`
- Processor: `envsubst` via `setup-secrets.sh`

### Shell Scripts
- Always `set -e`
- Descriptive variables
- Proper error handling with exit codes

### JSON/Config
- 2 spaces indentation
- Follow schema when present (opencode uses `https://opencode.ai/config.json`)

### Lua (Neovim)
- See `code/.config/nvim/AGENTS.md` for LazyVim-specific patterns

## ANTI-PATTERNS

| Never | Do Instead |
|-------|------------|
| Commit `zsh/.zsh_secrets` | Keep in gitignore, use `.env.example` as template |
| Commit generated files (without `.tmpl`) | Run `update-gitignore.sh` after adding templates |
| Hardcode API keys in config | Create `.tmpl` with `${VAR}` placeholders |
| Edit generated files directly | Edit the `.tmpl` source, run `setup-secrets.sh` |

## STOW PACKAGES

| Package | Contents | Symlinks To |
|---------|----------|-------------|
| `code` | nvim, opencode, github-copilot | `~/.config/` |
| `git` | .gitconfig, lazygit | `~/`, `~/.config/lazygit/` |
| `terminal` | kitty, atuin | `~/.config/` |
| `tmux` | .tmux.conf | `~/` |
| `zsh` | .zshrc, .zshenv, .p10k.zsh, .zsh_secrets | `~/` |

## NOTES

- Neovim config is "Snorlax.nvim" - LazyVim-based with custom plugins
- Tmux integrates with nvim via `nvim-tmux-navigator`
- Terminal theme: Rose Pine (kitty)
- Shell theme: Powerlevel10k
