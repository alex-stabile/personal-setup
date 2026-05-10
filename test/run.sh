#!/usr/bin/env bash
set -euo pipefail

IMAGE="dotfiles-ubuntu22"
DOCKERFILE="./test/Dockerfile"

if [[ "${1:-}" == "--build" ]]; then
  echo "Building image: $IMAGE"
  docker buildx -t "$IMAGE" -f "$DOCKERFILE" .
fi

docker run --rm -it \
  -v "$PWD:/personal-setup" \
  -w /personal-setup \
  "$IMAGE" \
  bash -c "/personal-setup/bootstrap/run.sh && exec zsh"
