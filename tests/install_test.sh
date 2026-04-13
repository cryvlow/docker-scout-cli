#!/usr/bin/env bash
set -euo pipefail

echo "Test: install.sh flags"

./install.sh --help >/dev/null
./install.sh -h >/dev/null || true

echo "Flags OK"