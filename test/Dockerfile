FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
  zsh git curl tree ripgrep stow bat tmux

# Install fzf from tarball since apt-get version is very old
ARG FZF_VERSION=0.62.0
RUN curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_arm64.tar.gz" \
    | tar -xz -C /usr/local/bin

# Install neovim from tarball since apt-get version is way too old (no winborder, etc.)
ARG NVIM_VERSION=0.11.6
RUN curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-arm64.tar.gz" \
    | tar -xz -C /opt \
    && ln -s /opt/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim
