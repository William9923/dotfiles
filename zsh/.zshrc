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
alias ping=gping
alias ll="exa -l -g --icons"
alias lla="ll -a"
alias zshconfig="nvim ~/.zshrc"
alias syncnotes="z vimwiki && sh ~/vimwiki/sync.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[[ -s "/home/william-nobara/.gvm/scripts/gvm" ]] && source "/home/william-nobara/.gvm/scripts/gvm"

# Following line was automatically added by arttime installer
export MANPATH=/home/william-nobara/.local/share/man:$MANPATH

# Following line was automatically added by arttime installer
export PATH=/home/william-nobara/.local/bin:$PATH

# opencode
export PATH=/home/william-nobara/.opencode/bin:$PATH
