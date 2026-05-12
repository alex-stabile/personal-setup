#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# absolute path to personal-setup repo
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Running stow..."
# stow zsh separately since it's ok if this fails
if ! stow --dir "$REPO_DIR" --target "$HOME" zsh; then
  echo "stow zsh failed, continuing anyway"
fi
stow --dir "$REPO_DIR" --target "$HOME" tmux vim nvim

echo "Installing neovim plugins..."
nvim --headless -u "$REPO_DIR/nvim/.config/nvim/lua/plugins.lua" +PlugInstall +qall
