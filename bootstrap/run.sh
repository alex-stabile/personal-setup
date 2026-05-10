#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# must do this before zsh
"$SCRIPT_DIR/strap-fzf.sh"
"$SCRIPT_DIR/strap-zsh.sh"
"$SCRIPT_DIR/strap-tmux.sh"
