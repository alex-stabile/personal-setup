# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Aliases

alias ls="ls -G"
alias v="vim"
alias scripts="cat package.json | jq '.scripts'"
alias tree="tree -aC"
alias clipboard="pbcopy"

# git shortcuts
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gb='git branch --show-current'
alias gcm='git commit -m'
alias prettylog='git log -n 10 --pretty=oneline'

alias tat='tmux attach-session -t'

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

# Homebrew
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Functions

setdisplays() {
  displayplacer "id:09AB8CAB-6950-4F4B-A1EC-7FE88BDAC82C res:2560x1440 hz:60 color_depth:8 scaling:on origin:(0,0) degree:0" "id:0E1A97FC-530E-4647-A9D1-FE84277A7F16 res:2560x1440 hz:60 color_depth:8 scaling:on origin:(-2560,0) degree:0"
}

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

start_ssh() {
  eval $(ssh-agent)
  echo "now do ssh-add"
}

fix_submodules() {
  git submodule deinit -f . && git submodule update --init
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

autoload -Uz compinit
compinit
# disable git autocompletion because it lags when completing files
compdef -d git
bindkey "^[[A" history-beginning-search-backward # prefix history search thing
if command -v kubectl &> /dev/null
then
  source <(kubectl completion zsh)
fi
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Your employer

if [ -f ~/.retoolrc ]; then
  source ~/.retoolrc
else
  echo ".retoolrc not found"
fi

# Add NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# Call nvm use automatically in a directory with a .nvmrc
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# update PATH for the Google Cloud SDK.
if [ -f '/Users/alexander/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/alexander/google-cloud-sdk/path.zsh.inc'; fi
# shell command completion for gcloud.
if [ -f '/Users/alexander/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/alexander/google-cloud-sdk/completion.zsh.inc'; fi

export PATH="/opt/homebrew/opt/kubernetes-cli/bin:$PATH"
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

export JAVA_HOME="$(/usr/libexec/java_home)"
export PATH="${JAVA_HOME}/bin:$PATH"
