# Aliases

alias ls="ls --color=auto"
alias v="vim"
alias scripts="cat package.json | jq '.scripts'"
alias tree="tree -aC"
alias clipboard="pbcopy"

# git shortcuts
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add'
alias gb='git branch --show-current'
alias gcm='git commit -m'
alias gp='git log -n 10 --pretty=oneline'
alias prettylog='git log -n 10 --pretty=oneline'

alias tat='tmux attach-session -t'

alias weather="curl wttr.in/SanFrancisco"

# Colors (from default bashrc)
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Other params:
# osascript -e 'display notification "hello world!" with title "Greeting" subtitle "More text" sound name "Submarine"'
# First arg: title
# All subsequent args: concatenated together for body
notify() {
  /usr/bin/osascript -e "display notification \"${*:2}\" with title \"$1\" sound name \"Submarine\""
}

remind() {
  local msg="
------------------------------------------------------------
$@
------------------------------------------------------------
"
  echo $msg
}

# FZF config

local preview_bind="ctrl-d:preview-page-down,ctrl-e:preview-down,ctrl-u:preview-page-up,ctrl-y:preview-up"
export FZF_DEFAULT_OPTS="--ansi --bind=$preview_bind"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Example command to preview file or folder:
# --preview="(bat --color=always --style=header,grid --line-range :300 {} || tree -aC -L 1 {}) 2>/dev/null"

# Custom FZF functions

# cd to selected directory
# Inspired by: https://github.com/junegunn/fzf/wiki/examples
fd() {
  local dir
  # Pass a directory to traverse (referenced with ${1}), otherwise '.' is used
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -path '*/sorbet*' -prune \
                  -o -path '*/node_modules*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m --preview 'tree -aC -L 1 {}') \
    && cd "$dir"
}

# cd to parent directory
# Note: on mac must install coreutils for realpath
fdr() {
  local declare dirs=()
  get_parent_dirs() {
    if [[ -d "${1}" ]]; then dirs+=("$1"); else return; fi
    if [[ "${1}" == '/' ]]; then
      for _dir in "${dirs[@]}"; do echo $_dir; done
    else
      get_parent_dirs $(dirname "$1")
    fi
  }
  local DIR=$(get_parent_dirs $(realpath "${1:-$PWD}") | fzf +m)
  cd "$DIR"
}

# interactive git checkout
fco() {
  local branches branch previewcmd
  previewcmd="git --no-pager log -50 --color=always --pretty=format:'%Cgreen%h%Cred %al%Creset %s' {1}"
  branches=$(git --no-pager branch) &&
    branch=$(echo "$branches" | fzf +m --preview="$previewcmd") &&
    git checkout $(echo "$branch" | sed "s/.* //")
}

# fuzzy search a job to foreground
fj() {
  local joblines jobnum
  joblines=$(jobs | fzf +m --layout=reverse --info=inline-right --border --height=10%) &&
    jobnum=$(echo "$joblines" | sed -nr "s/\[([0-9]+).*$/\1/p") &&
    fg "%$jobnum"
}

# git log (preview commits)
flog() {
  git log --color=always --pretty=format:'%h %Cgreen%al%Cred%d %Creset%s' | fzf --preview 'git show --color=always {+1}'
}

# ZSH config

zmodload zsh/complist
# navigate completion menu with vim bindings
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'l' vi-forward-char

autoload -Uz compinit
compinit
_comp_options+=(globdots) # include dotfiles
# man zshoptions "Completion"
unsetopt BEEP
unsetopt LIST_BEEP
setopt LIST_PACKED
setopt LIST_TYPES
setopt AUTO_MENU
setopt MENU_COMPLETE
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*' menu select
# disable git autocompletion because it lags when completing files
compdef -d git
bindkey "^[[A" history-beginning-search-backward # prefix history search thing
if command -v kubectl &> /dev/null
then
  source <(kubectl completion zsh)
fi
# source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Your employer

if [ -f ~/.retoolrc ]; then
  source ~/.retoolrc
fi

# export PATH="/opt/homebrew/opt/kubernetes-cli/bin:$PATH"
# autoload -U +X bashcompinit && bashcompinit
# complete -o nospace -C /opt/homebrew/bin/terraform terraform
