alias v="vim"
alias scripts="cat package.json | jq '.scripts'"
alias tree="tree -aC"
alias clipboard="pbcopy"
# git shortcuts:
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gb='git branch | grep "*"'
alias prettylog='git log -n 10 --pretty=oneline'

# bat with useful params for logs, reads from stdin
logbat() {
  bat --paging=never --decorations=never -l log
}

start_ssh() {
  eval $(ssh-agent)
  echo "now do the ssh-add thing"
}

export RETOOL_SH_DIR='/home/alex/dev/retool-sh'

# ------------------------------------------------------------
# FZF HAX
# lit fuzzy searching
# ------------------------------------------------------------

# Set FZF defaults
# Inspired by: https://github.com/sharkdp/bat/issues/357
DEFAULT_PREVIEW="(bat --color=always --style=header,grid --line-range :300 {} || tree -aC -L 1 {} || cat {}) 2>/dev/null"
DEFAULT_BINDING="ctrl-d:preview-page-down,ctrl-e:preview-down,ctrl-u:preview-page-up,ctrl-y:preview-up"
# export FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --preview '$DEFAULT_PREVIEW' --bind=$DEFAULT_BINDING"
export FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --bind=$DEFAULT_BINDING --preview='cat {} || tree -d {} 2>/dev/null'"

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


# man wtf
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi
