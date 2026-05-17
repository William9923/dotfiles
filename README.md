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
- `terminal/` → Kitty + Atuin
- `tmux/` → tmux config
- `zsh/` → shell config + secrets source

### Setup lifecycle

1. Define secrets in `zsh/.zsh_secrets`
2. Keep shareable config in `*.tmpl` files with `${VAR}` placeholders
3. Run `./setup-secrets.sh` to generate real config files via `envsubst`
4. The script refreshes `.gitignore` using `./update-gitignore.sh`
5. Apply symlinks with `stow code git terminal tmux zsh`

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

### 🎨 Themes & Appearance
- **Rose Pine** theme for Kitty terminal
- **Powerlevel10k** for Zsh prompt
- **LazyVim** setup with modern plugins

## 🚀 Quick Start

### Prerequisites

**Install GNU Stow:**
```bash
# Ubuntu/Debian
sudo apt-get install stow

# Arch Linux  
sudo pacman -S stow

# macOS
brew install stow
```

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/William9923/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. **Set up secrets (first time only):**
```bash
# Copy the example file and add your actual secrets
cp .env.example zsh/.zsh_secrets
vi zsh/.zsh_secrets  # Add your API keys and tokens
```

3. **Generate config files from templates:**
```bash
./setup-secrets.sh
```

4. **Apply configurations with Stow:**
```bash
# Install everything
stow code git terminal tmux zsh

# Or install selectively
stow code      # Neovim, OpenCode, GitHub Copilot
stow git       # Git and Lazygit configuration  
stow terminal  # Kitty and Atuin
stow tmux      # Tmux configuration
stow zsh       # Zsh shell and Powerlevel10k
```

5. **Restart your shell:**
```bash
exec zsh
```

### Stow maintenance

```bash
# Remove symlinks for one package
stow -D code

# Re-apply symlinks for one package
stow code

# Re-apply all packages
stow code git terminal tmux zsh
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
├── ⚙️ setup-secrets.sh        # Setup script
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
