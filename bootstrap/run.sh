#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# absolute path to personal-setup repo
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

stow --dir "$REPO_DIR" --target $HOME zsh tmux nvim

