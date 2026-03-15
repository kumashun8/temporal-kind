#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_DIR"

echo "=== deploy-apps ==="
make deploy-apps

echo "=== port-forward (background) ==="
make port-forward-temporal &
make port-forward-ui &
make port-forward-argocd &

sleep 2

echo "=== run-worker (background) ==="
make run-worker &
WORKER_PID=$!

sleep 5

if ! kill -0 "$WORKER_PID" 2>/dev/null; then
  echo "ERROR: Worker failed to start" >&2
  exit 1
fi

echo "=== run-starter ==="
make run-starter
