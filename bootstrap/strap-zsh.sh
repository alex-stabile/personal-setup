#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v stow >/dev/null; then
  echo "stow not found, exiting" >&2
  exit 1
fi

# Move any pre-existing ~/.zshrc out of the way
if [[ -e "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  echo "moving existing .zshrc"
  mv "$HOME/.zshrc" "$HOME/.zshrc.pre-stow.$(date +%s)"
fi

stow -d "$REPO_DIR" -t "$HOME" --no-folding --restow zsh
