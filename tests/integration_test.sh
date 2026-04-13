#!/usr/bin/env bash
set -euo pipefail

echo "Test: flujo completo (simulado)"

chmod +x ./install.sh

OUTPUT=$(./install.sh --help || true)

if [[ "$OUTPUT" == *"Usage"* ]]; then
  echo "✅ Output esperado"
else
  echo "❌ Output inesperado"
  exit 1
fi