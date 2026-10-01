#!/usr/bin/env bash
# Execute any Zappa command inside a Linux Docker container using uv.
set -euo pipefail

echo "==> Building Linux ARM64 (Graviton) deployment container with uv..."
docker build --platform linux/arm64 -t django-zappa-deployer .

AWS_DIR="${HOME}/.aws"
CURRENT_DIR="$(pwd)"

echo "==> Executing: zappa $* inside Linux ARM64 container..."
docker run --platform linux/arm64 --rm \
    -v "${AWS_DIR}:/root/.aws:ro" \
    -v "${CURRENT_DIR}:/app" \
    -e AWS_PROFILE="${AWS_PROFILE:-default}" \
    -e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}" \
    django-zappa-deployer "$@"
