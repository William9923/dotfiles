# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source secrets if available
[ -f ~/.zsh_secrets ] && source ~/.zsh_secrets

# Allow defer load for long source job...
source ~/zsh-defer/zsh-defer.plugin.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme

# History file in its own directory
[[ -d ~/.zsh_history.d ]] || mkdir -p ~/.zsh_history.d
HISTFILE=~/.zsh_history.d/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
# End of lines configured by zsh-newuser-install

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Homebrew path (removed)
export GOPATH=$HOME/go

# Go binary path
export PATH="$PATH:$HOME/go/bin"

# Cargo / Rust path
source "$HOME/.cargo/env"
export PATH="$PATH:$HOME/.cargo/bin"

# Enable syntax highlighting
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Enable auto-suggestion
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# FZF shell integration: Ctrl-R history search, Ctrl-T file search, Alt-C cd
source /usr/share/fzf/shell/key-bindings.zsh
# One-time atuin→zsh_history migration (run after switching):
#   atuin history export --format=raw >> ~/.zsh_history.d/.zsh_history
# Then atuin can be uninstalled: cargo uninstall atuin

# Enable directory jumping
source ~/zsh-z/zsh-z.plugin.zsh
zstyle ':completion:*' menu select

# Custom aliases - for daily purposes
alias ls="ls -p -G"
alias la="ls -A"
alias ll="ls -l"
alias lla="ll -A"
alias g=git
alias lg=lazygit
alias t=tmux
alias v=nvim
alias ll="exa -l -g --icons"
alias lla="ll -a"
alias zshconfig="nvim ~/.zshrc"
alias bw="~/bw"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Source color palette for shell-driven tools (fzf, tmux, etc.)
[[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/theme/kanagawa-dragon/palette.zsh" ]] && source "$_"

# FZF default options with theme-aware colors
if [[ -n "${DOT_THEME_FG:-}" ]]; then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--color=fg:${DOT_THEME_FG},fg+:${DOT_THEME_FG},bg:-1,bg+:-1,hl:${DOT_THEME_YELLOW},hl+:${DOT_THEME_ORANGE},info:${DOT_THEME_MUTED},border:${DOT_THEME_DIM},prompt:${DOT_THEME_BLUE},pointer:${DOT_THEME_MAGENTA},marker:${DOT_THEME_GREEN},spinner:${DOT_THEME_CYAN},header:${DOT_THEME_MUTED},gutter:-1,query:${DOT_THEME_FG},disabled:${DOT_THEME_MUTED}"
fi

export NVM_DIR="$HOME/.nvm"
zsh-defer [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
zsh-defer [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

zsh-defer [ -s "/home/william-nobara/.gvm/scripts/gvm" ] && source "/home/william-nobara/.gvm/scripts/gvm"

# Following line was automatically added by arttime installer
export MANPATH=/home/william-nobara/.local/share/man:$MANPATH

# Following line was automatically added by arttime installer
export PATH=/home/william-nobara/.local/bin:$PATH

# opencode
export PATH=/home/william-nobara/.opencode/bin:$PATH

# bun completions
zsh-defer [ -s "/home/william-nobara/.bun/_bun" ] && source "/home/william-nobara/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

# mise
if command -v mise >/dev/null 2>&1; then
  zsh-defer eval "$(mise activate zsh)"
fi

# opencode - Function to run OpenCode on an available port
unalias op 2>/dev/null
op() {
  local start_port=3000
  local end_port=3010 # with the assumption that opencode will be run max 10 session
  local found_port=""

  for port in {$start_port..$end_port}; do
    if ! lsof -i :$port -stcp:listen -P -n >/dev/null 2>&1; then
      found_port=$port
      break
    fi
  done

  if [[ -n "$found_port" ]]; then
    echo "Launching opencode on port $found_port"
    opencode --port "$found_port" "$@"
  else
    echo "No ports available in range 3000-3010. Trying default ..."
    opencode "$@"
  fi
}
