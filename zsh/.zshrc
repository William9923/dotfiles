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


# Homebrew path
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export GOPATH=$HOME/go

# Go binary path
export PATH="$PATH:$HOME/go/bin"

# Cargo / Rust path
export PATH="$PATH:$HOME/.cargo/env"
export PATH="$PATH:$HOME/.cargo/bin"

# Enable syntax highlighting
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Enable auto-suggestion
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Enable direnv
eval "$(direnv hook zsh)"

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
alias syncnotes="z vimwiki && sh ~/vimwiki/sync.sh"

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

# opencode preset switcher
op-preset() {
  local config_file="$HOME/.config/opencode/oh-my-opencode-slim.json"
  local presets=("tier-google" "tier-opencode" "tier-github" "tier-antigravity")

  # Show current preset if no arguments
  if [[ $# -eq 0 ]]; then
    local current=$(grep -o '"preset": "[^"]*"' "$config_file" | cut -d'"' -f4)
    echo "Current preset: $current"
    echo ""
    echo "Available presets:"
    for p in "${presets[@]}"; do
      if [[ "$p" == "$current" ]]; then
        echo "  * $p (active)"
      else
        echo "    $p"
      fi
    done
    echo ""
    echo "Usage: op-preset <preset-name>"
    echo "       op-preset --fzf    # interactive selection"
    return 0
  fi

  # Interactive fzf mode
  if [[ "$1" == "--fzf" ]] || [[ "$1" == "-i" ]]; then
    local current=$(grep -o '"preset": "[^"]*"' "$config_file" | cut -d'"' -f4)
    local selected=$(printf '%s\n' "${presets[@]}" | fzf --prompt="Select opencode preset: " --preview="echo Current: $current")
    if [[ -n "$selected" ]]; then
      op-preset "$selected"
    fi
    return 0
  fi

  # Validate preset name
  local preset="$1"
  local valid=false
  for p in "${presets[@]}"; do
    if [[ "$p" == "$preset" ]]; then
      valid=true
      break
    fi
  done

  if [[ "$valid" == false ]]; then
    echo "Error: Invalid preset '$preset'"
    echo "Valid presets: ${presets[*]}"
    return 1
  fi

  # Switch preset
  sed -i "s/\"preset\": \".*\"/\"preset\": \"$preset\"/" "$config_file"
  echo "Switched to preset: $preset"
}

# Aliases for quick preset switching
alias op-google='op-preset tier-google'
alias op-opencode='op-preset tier-opencode'
alias op-github='op-preset tier-github'
