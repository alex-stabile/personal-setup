#!/usr/bin/env bash
set -euo pipefail

FZF_VERSION="0.62.0"
PREFIX="${PREFIX:-/usr/local/bin}"

if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "skipping fzf install on macOS"
  exit 0
fi

if command -v fzf >/dev/null && [[ "$(fzf --version | awk '{print $1}')" == "$FZF_VERSION" ]]; then
  echo "fzf $FZF_VERSION already installed"
  exit 0
fi

url="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading fzf from: $url"
curl -fsSL "$url" | tar -xz -C "$tmp"
install -m 0755 "$tmp/fzf" "$PREFIX/fzf"

echo "Installed fzf $FZF_VERSION to $PREFIX/fzf"
