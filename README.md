# Dotfiles

Personal configuration files for my development environment, managed with GNU Stow.

## Structure

- `.config/`
  - `nvim/` - Neovim configuration using LazyVim
  - `github-copilot/` - GitHub Copilot settings
  - `kitty/` - Kitty terminal configuration
  - `atuin/` - Shell history search
- `git/` - Git configuration and Lazygit settings
- `terminal/` - Terminal-related configurations
- `tmux/` - Tmux configuration
- `zsh/` - Zsh shell configuration

## Tools

- Neovim (IDE)
- Kitty (Terminal)
- Tmux (Terminal multiplexer)
- Zsh (Shell)
- Atuin (Shell history)
- Lazygit (Git TUI)
- GitHub Copilot

## Setup

1. Install GNU Stow:
```bash
# macOS
brew install stow

# Ubuntu/Debian
apt-get install stow

# Arch Linux
pacman -S stow
```

2. Clone this repository:
```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

3. Use Stow to create symlinks:
```bash
stow */  # This creates symlinks for all config directories
```

Or selectively:
```bash
stow nvim    # Only Neovim config
stow zsh     # Only Zsh config
stow tmux    # Only Tmux config
```

GNU Stow will automatically create symbolic links in your home directory that point to the configuration files in this repository. When you update the configs in this repository, the changes are immediately reflected in your system.