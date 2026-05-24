# 🏠 William's Dotfiles

<p align="center">
  <img src="https://img.shields.io/badge/OS-Linux-informational?style=flat-square&logo=linux&logoColor=white" />
  <img src="https://img.shields.io/badge/Editor-Neovim-57A143?style=flat-square&logo=neovim&logoColor=white" />
  <img src="https://img.shields.io/badge/Shell-Zsh-89e051?style=flat-square&logo=zsh&logoColor=white" />
  <img src="https://img.shields.io/badge/Terminal-Kitty-000000?style=flat-square&logo=gnome-terminal&logoColor=white" />
  <img src="https://img.shields.io/badge/Multiplexer-Tmux-1BB91F?style=flat-square&logo=tmux&logoColor=white" />
  <img src="https://img.shields.io/badge/Git-Lazygit-F05032?style=flat-square&logo=git&logoColor=white" />
</p>

<p align="center">
  <b>My personal development environment configuration, managed with GNU Stow</b>
</p>

---

## ✨ Table of Contents

- [🎯 Overview](#-overview)
- [🧠 Architecture / How It Works](#-architecture--how-it-works)
- [🛠️ Tools & Applications](#️-tools--applications)
- [🚀 Quick Start](#-quick-start)
- [🔒 Security & Secrets](#-security--secrets)
- [📁 Structure](#-structure)
- [🎨 Tools](#-tools)
- [🤝 Contributing](#-contributing)

## 🎯 Overview

This repository contains my personal dotfiles and development environment configuration. It's designed to be:

- **🔧 Modular**: Each tool has its own package for selective installation
- **🔒 Secure**: Secrets are managed with templates and environment variables
- **🏃 Portable**: Works across different Linux distributions
- **⚡ Efficient**: Optimized for software development workflows

## 🧠 Architecture / How It Works

This repo is organized as GNU Stow packages by responsibility:

- `code/` → editor + AI tooling (Neovim, OpenCode, Copilot)
- `git/` → git + lazygit config
- `config/` → shared app config (mise)
- `commitizen/` → Commitizen config
- `terminal/` → Kitty + Atuin
- `tmux/` → tmux config
- `zsh/` → shell config + secrets source

### Setup lifecycle

1. Define secrets in `zsh/.zsh_secrets`
2. Keep shareable config in `*.tmpl` files with `${VAR}` placeholders
3. Run `./setup-secrets.sh` to generate real config files via `envsubst`
4. The script refreshes `.gitignore` using `./update-gitignore.sh`
5. Apply symlinks with `stow code git terminal tmux zsh config commitizen`

## 🛠️ Tools & Applications

### 💻 Terminal & Shell
| Tool | Description | Config Location |
|------|-------------|-----------------|
| **Kitty** | GPU-accelerated terminal emulator | `terminal/.config/kitty/` |
| **Zsh** | Modern shell with Powerlevel10k theme | `zsh/` |
| **Tmux** | Terminal multiplexer for session management | `tmux/` |
| **Atuin** | Magical shell history with sync | `terminal/.config/atuin/` |

### ⚙️ Development Tools
| Tool | Description | Config Location |
|------|-------------|-----------------|
| **Neovim** | Modern Vim-based editor with LazyVim | `code/.config/nvim/` |
| **Lazygit** | Simple terminal UI for git commands | `git/.config/lazygit/` |
| **GitHub Copilot** | AI-powered code completion | `code/.config/github-copilot/` |
| **OpenCode** | Advanced development assistant | `code/.config/opencode/` |
| **mise** | Runtime/tool manager for per-project tool installs | `config/.config/mise/` |
| **Commitizen** | Conventional commit helper | `commitizen/.czrc` |

### 🎨 Themes & Appearance
- **Rose Pine** theme for Kitty terminal
- **Powerlevel10k** for Zsh prompt
- **LazyVim** setup with modern plugins

## 🚀 Quick Start

### Fedora-first setup

This repo is set up for Fedora Linux first. The one-command entrypoint installs packages, generates secret-backed files, and stows the config.

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/William9923/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. **Set up secrets (first time only):**
```bash
cp .env.example zsh/.zsh_secrets
vi zsh/.zsh_secrets
```

3. **Run the setup entrypoint:**
```bash
./setup.sh minimal
# or
./setup.sh full
```

4. **Manual stow if needed:**
```bash
stow --no-folding code git terminal tmux zsh config commitizen

# Or install selectively
stow code      # Neovim, OpenCode, GitHub Copilot
stow git       # Git and Lazygit configuration  
stow config    # mise config and shared tooling
stow commitizen # Commitizen config
stow terminal  # Kitty and Atuin
stow tmux      # Tmux configuration
stow zsh       # Zsh shell and Powerlevel10k
```

5. **Restart your shell:**
```bash
exec zsh
```

### Make targets

```bash
make help
make doctor
make check
make setup-minimal
make setup-full
make install
make restow
make uninstall
make sync
```

`make check` validates script syntax, and `make install/restow` controls only symlink operations. `setup.sh` also runs `mise install -y` when mise/config are present and attempts Commitizen global install via npm.

### Secrets lifecycle

- `.tmpl` files are committed and contain placeholders
- `setup-secrets.sh` reads `zsh/.zsh_secrets` and generates local files
- `update-gitignore.sh` keeps generated outputs ignored
- Never commit `zsh/.zsh_secrets`

### Stow maintenance

```bash
# Remove symlinks for one package
stow -D code

# Re-apply symlinks for one package
stow code

# Re-apply all packages
stow --no-folding code git terminal tmux zsh config commitizen
```

## 🔒 Security & Secrets

This dotfiles repository uses a **template-based approach** for handling secrets:

### How it works:
- **Templates** (`.tmpl` files) are committed to git with `${VARIABLE}` placeholders
- **Real config files** are generated locally with actual secrets
- **Secrets file** (`zsh/.zsh_secrets`) is never committed

### Safety rules:
- Never commit `zsh/.zsh_secrets`
- Never edit generated non-`.tmpl` files directly
- Always edit the `.tmpl` source, then regenerate

### When to rerun setup:
Run this whenever you update secrets or any template file:

```bash
./setup-secrets.sh
```

### Example:
```json
// opencode.json.tmpl (committed)
{
  "mcp": {
    "ref-tools": {
      "url": "https://api.ref.tools/mcp?apiKey=${REF_API_KEY}"
    }
  }
}

// opencode.json (generated locally, gitignored)
{
  "mcp": {
    "ref-tools": {
      "url": "https://api.ref.tools/mcp?apiKey=your-actual-key"
    }
  }
}
```

### Managing secrets:
```bash
# Edit your secrets
nano zsh/.zsh_secrets

# Regenerate config files
./setup-secrets.sh

# Check what will be committed (should be no secrets!)
git status
```

## 📁 Structure

```
dotfiles/
├── 🔧 code/
│   └── .config/
│       ├── nvim/              # Neovim configuration (LazyVim)
│       ├── opencode/          # OpenCode AI assistant
│       └── github-copilot/    # GitHub Copilot settings
├── 📝 git/
│   ├── .gitconfig             # Git configuration
│   └── .config/lazygit/       # Lazygit TUI settings
├── 💻 terminal/
│   └── .config/
│       ├── kitty/             # Kitty terminal emulator
│       └── atuin/             # Shell history search
├── 🖥️ tmux/
│   └── .tmux.conf             # Tmux configuration
├── 🐚 zsh/
│   ├── .zshrc                 # Zsh configuration
│   ├── .zshenv                # Zsh environment
│   ├── .p10k.zsh              # Powerlevel10k config
│   └── .zsh_secrets           # Secrets (gitignored)
├── 🔒 .env.example            # Template for secrets
├── ⚙️ setup.sh                # Fedora bootstrap entrypoint
├── ⚙️ setup-secrets.sh        # Template rendering script
├── 📦 packages/               # Fedora package profiles
│   ├── fedora-minimal.txt
│   └── fedora-full.txt
├── 🧰 Makefile                # Operator shortcuts
├── 🔁 bin/.local/bin/sync-dots # Safe git sync helper
└── 📖 README.md               # This file
```

## 🎨 Tools

### 🚀 Shell
- **Smart autocompletion** with zsh-autosuggestions
- **Fast directory navigation** with zsh-z
- **Beautiful prompt** with Powerlevel10k
- **Command history search** with Atuin

### 📝 Editor  
- **LazyVim** - Modern Neovim configuration
- **LSP support** for multiple languages
- **Git integration** with LazyGit
- **AI assistance** with GitHub Copilot and OpenCode

### 🎛️ Terminal
- **GPU acceleration** with Kitty
- **Session management** with Tmux
- **Rose Pine theme** for consistent aesthetics

---

<p align="center">
  <i>Happy coding! 🚀</i>
</p>
