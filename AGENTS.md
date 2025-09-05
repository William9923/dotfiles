# Agent Guidelines

This repository contains dotfiles and configuration for development environments including Neovim, tmux, git, and OpenCode.

## Commands
- **Setup**: `./setup-secrets.sh` - Generate config files from templates with secrets
- **Install dotfiles**: `stow code git terminal tmux zsh` - Symlink dotfiles to home directory
- **Update gitignore**: `./update-gitignore.sh > .gitignore` - Auto-generate gitignore for .tmpl files

## Code Style
- **Shell scripts**: Use `set -e`, descriptive variables, proper error handling with exit codes
- **JSON/Config**: 2 spaces indentation, follow schema requirements (OpenCode uses https://opencode.ai/config.json)
- **Security**: Never commit secrets - use .tmpl files with env substitution, check .gitignore patterns
- **Lua (Neovim)**: Follow existing patterns in config/, use vim.opt for options, vim.g for globals
- **Template files**: Use .tmpl extension with ${VAR} syntax for environment variable substitution
- **File organization**: Group by purpose (code/, terminal/, git/, etc.), maintain clear directory structure
- **Documentation**: Include usage examples, security reminders, clear setup instructions

## Project Structure
- Templates (.tmpl) are committed, generated files are gitignored
- Secrets stored in zsh/.zsh_secrets (never committed)
- Configuration organized by tool type in separate directories