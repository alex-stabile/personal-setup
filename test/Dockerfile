FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
  zsh git curl tree ripgrep neovim stow bat

# Install fzf from tarball since apt-get version is very old
ARG FZF_VERSION=0.62.0
RUN curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin
