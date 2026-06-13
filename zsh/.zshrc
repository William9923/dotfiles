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

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
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

# Enable atuin - command history show
eval "$(atuin init zsh)"

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
