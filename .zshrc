# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------------------------------------
# ALIAS ETC
# (need to organize)
# ------------------------------------------------------------

alias ls="ls -G"
alias v="vim"
alias scripts="cat package.json | jq '.scripts'"
alias tree="tree -aC"
alias clipboard="pbcopy"

# git shortcuts:
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gb='git branch --show-current'
alias prettylog='git log -n 10 --pretty=oneline'

# weather cuz why not
alias weather="curl wttr.in/SanFrancisco"

# Default prompt (from /private/etc/zshrc)
PS1="%n@%m %1~ %# "

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

# add GNU grep to path
# PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

# ------------------------------------------------------------
# iTERM FIX
# ------------------------------------------------------------

# Fix keys for iTerm, see key mappings
# in Preferences -> Profiles -> Keys
# not necessary with "natural key binding" preset
# bindkey "^[[1~" beginning-of-line # Home
# bindkey "^[[4~" end-of-line # End
# bindkey "^[[1;5C" forward-word # Option-Right
# bindkey "^[[1;5D" backward-word # Option-Left

# ------------------------------------------------------------
# RANDOM
# TODO: ORGANIZE
# ------------------------------------------------------------

AZ_IP="$(cat .devbox_ip)"

devsh() {
  ssh -i ~/.ssh/id_rsa "alex@${AZ_IP}"
}

devtunnel() {
  ssh -i ~/.ssh/id_rsa -L 3000:0.0.0.0:3000 "alex@${AZ_IP}"
}

devtunnelotel() {
  ssh -i ~/.ssh/id_rsa \
    -L 3000:0.0.0.0:3000 \
    -L 9411:0.0.0.0:9411 \
    "alex@${AZ_IP}"
}

devcp() {
  local src="$1"
  local dest="$2"
  scp -i ~/.ssh/id_rsa "$src" "alex@${AZ_IP}:$dest"
}

# bat with useful params for logs, reads from stdin
logbat() {
  bat --paging=never --decorations=never -l log
}

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

# ------------------------------------------------------------
# FZF HAX
# lit fuzzy searching
# ------------------------------------------------------------

# Set FZF defaults
# Inspired by: https://github.com/sharkdp/bat/issues/357
local DEFAULT_PREVIEW="(bat --color=always --style=header,grid --line-range :300 {} || tree -aC -L 1 {} || cat {}) 2>/dev/null"
local DEFAULT_BINDING="ctrl-d:preview-page-down,ctrl-e:preview-down,ctrl-u:preview-page-up,ctrl-y:preview-up"
export FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --preview '$DEFAULT_PREVIEW' --bind=$DEFAULT_BINDING"

# fd - cd to selected directory
# Inspired by: https://github.com/junegunn/fzf/wiki/examples
fd() {
  local dir
  # Pass a directory to traverse (referenced with ${1}), otherwise '.' is used
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -path '*/sorbet*' -prune \
                  -o -path '*/node_modules*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) \
    && cd "$dir"
}

# fdr - cd to parent directory
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

# fco - interactive git checkout
# this one is lit
fco() {
  local branches branch previewcmd
  previewcmd="git --no-pager log -50 --color=always --pretty=format:'%Cgreen%h%Cred %al%Creset %s' {1}"
  branches=$(git --no-pager branch) &&
    branch=$(echo "$branches" | fzf +m --preview="$previewcmd") &&
    git checkout $(echo "$branch" | sed "s/.* //")
}

# flog - git log with fzf
flog() {
  git log --color=always --pretty=format:'%h %Cgreen%al%Cred%d %Creset%s' | fzf --preview 'git show --color=always {+1}'
}

# Add FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Add retool-sh
export RETOOL_SH_DIR='/Users/alexander/Developer/retool-sh'
. "$RETOOL_SH_DIR/retoolrc"

# ZSH config
autoload -Uz compinit
compinit
bindkey "^[[A" history-beginning-search-backward # prefix history search thing
if command -v kubectl &> /dev/null
then
  source <(kubectl completion zsh)
fi
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
