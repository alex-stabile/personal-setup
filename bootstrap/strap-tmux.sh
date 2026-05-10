#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v stow >/dev/null; then
  echo "stow not found, exiting" >&2
  exit 1
fi

# Move any pre-existing ~/.tmux.conf out of the way
if [[ -e "$HOME/.tmux.conf" && ! -L "$HOME/.tmux.conf" ]]; then
  echo "moving existing .tmux.conf"
  mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.pre-stow.$(date +%s)"
fi

stow -d "$REPO_DIR" -t "$HOME" --no-folding --restow tmux
