#!/usr/bin/env bash
set -euo pipefail

echo "Test: manejo de errores (flags inválidos)"

OUTPUT=$(./install.sh --fake-option 2>&1 || true)

if [[ "$OUTPUT" == *"Usage"* ]]; then
  echo "✅ Manejo correcto (muestra ayuda)"
else
  echo "❌ No manejó correctamente la opción inválida"
  exit 1
fi