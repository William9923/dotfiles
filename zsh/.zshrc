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

# fzf shell integration
if [[ -o interactive ]] && command -v fzf >/dev/null 2>&1; then
  # Allow Ctrl-S to be used as a key binding instead of terminal flow control.
  stty -ixon 2>/dev/null

  if [[ -n "${DOT_THEME_FG:-}" ]]; then
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--color=fg:${DOT_THEME_FG},fg+:${DOT_THEME_FG},bg:-1,bg+:-1,hl:${DOT_THEME_YELLOW},hl+:${DOT_THEME_ORANGE},info:${DOT_THEME_MUTED},border:${DOT_THEME_DIM},prompt:${DOT_THEME_BLUE},pointer:${DOT_THEME_MAGENTA},marker:${DOT_THEME_GREEN},spinner:${DOT_THEME_CYAN},header:${DOT_THEME_MUTED},gutter:-1,query:${DOT_THEME_FG},disabled:${DOT_THEME_MUTED}"
  fi

  export FZF_CTRL_R_OPTS="
    --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
    --color header:italic
    --header 'Press CTRL-Y to copy command into clipboard'"

  export FZF_CTRL_T_OPTS="
    --walker-skip .git,node_modules,target
    --bind 'ctrl-y:execute-silent(wl-copy < {+f})+abort'
    --color header:italic
    --header 'ENTER opens in nvim; CTRL-Y copies selected path(s) into clipboard'"

  export FZF_ALT_C_OPTS="--walker-skip .git,node_modules,target"
  if command -v tree >/dev/null 2>&1; then
    FZF_ALT_C_OPTS+=" --preview 'tree -C {}'"
  fi

  source <(fzf --zsh)

  fzf-file-widget() {
    local selected="$(__fzf_select)"
    local ret=$?
    if [[ -n "${selected//[[:space:]]/}" ]]; then
      zle push-line
      BUFFER="nvim -- ${selected}"
      zle accept-line
      return $?
    fi
    zle reset-prompt
    return $ret
  }
  zle -N fzf-file-widget

  fzf-rg-widget() {
    if ! command -v rg >/dev/null 2>&1; then
      zle -M "rg is required for Ctrl-S search"
      return 1
    fi

    local selected ret file line rest
    local preview_opts=()

    if command -v bat >/dev/null 2>&1; then
      preview_opts=(--preview 'bat --style=numbers --color=always --highlight-line {2} -- {1}')
    fi

    selected="$(
      printf '' |
        fzf --disabled \
          --prompt='rg> ' \
          --delimiter=':' \
          --header='Type to search with rg; ENTER opens match in nvim' \
          --bind='change:reload:test -n {q} && rg --column --line-number --no-heading --color=never --smart-case -- {q} || true' \
          "${preview_opts[@]}"
    )"
    ret=$?

    if [[ -n "${selected//[[:space:]]/}" ]]; then
      file="${selected%%:*}"
      rest="${selected#*:}"
      line="${rest%%:*}"

      if [[ -n "$file" && "$line" =~ '^[0-9]+$' ]]; then
        zle push-line
        BUFFER="nvim +${line} -- ${(q)file}"
        zle accept-line
        return $?
      fi
    fi

    zle reset-prompt
    return $ret
  }
  zle -N fzf-rg-widget
  bindkey '^S' fzf-rg-widget
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
