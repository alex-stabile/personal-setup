#!/usr/bin/env zsh

####
# Restack: Build a `git rebase` command interactively using FZF
####

set -e

current_branch=$(git branch --show-current)
if [[ -z "$current_branch" ]]; then
  echo "Error: not on a branch (detached HEAD?)" >&2
  exit 1
fi

# Step 0: Optionally fetch master
echo "Fetch master first?" >&2
echo "(if already fetched, use \`git fetch . origin/master:master\` to update local ref)" >&2
echo -n "[y/N] " >&2
read fetch_reply
echo >&2
if [[ "$fetch_reply" == "y" ]]; then
  echo "Fetching..." >&2
  git fetch origin master:master
fi

# Step 1: Select the upstream commit/branch from git log
echo -n "Select the upstream ref: " >&2
selected=$(git log --color=always -50 --pretty=format:'%h %Cgreen%al%Cred%d %Creset%s' \
  | fzf --header "Select upstream" --layout=reverse --ansi --preview 'git show --color=always {+1}')

if [[ -z "$selected" ]]; then
  echo "No selection." >&2
  exit 1
fi
# Extract branch name from decorations if present, otherwise use the commit hash
# Decorations look like: (HEAD -> branch, origin/branch, other-branch)
upstream=""
if [[ "$selected" =~ '\(.*\)' ]]; then
  # Pull out local branch names (skip HEAD ->, origin/, tag:)
  decorations="${MATCH}"
  # Try to find a local branch name in the decorations
  upstream=$(echo "$decorations" | tr ',' '\n' | sed 's/[()]//g; s/^ *//; s/ *$//' \
    | grep -v '^HEAD' | grep -v '^origin/' | grep -v '^tag:' | head -1)
fi

if [[ -z "$upstream" ]]; then
  # Fall back to commit hash
  upstream=$(echo "$selected" | awk '{print $1}')
fi

echo "$upstream" >&2

# Step 2: Select the target branch to rebase onto
echo -n "\nSelect the new base: " >&2
previewcmd="git --no-pager log -50 --color=always --pretty=format:'%Cgreen%h%Cred %al%Creset %s' {1}"
onto=$(git --no-pager branch \
  | fzf --header "Select newbase (--onto param)" --layout=reverse --query="'master" --preview="$previewcmd" \
  | sed "s/.* //")

if [[ -z "$onto" ]]; then
  echo "No newbase selected." >&2
  exit 1
fi

echo "$onto" >&2

# Step 3: Output the command
echo "git rebase -i --onto $onto $upstream"
