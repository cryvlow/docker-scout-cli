#!/usr/bin/env bash
set -euo pipefail

echo "Test: manejo de errores"

if ./install.sh --fake-option 2>/dev/null; then
  echo "❌ Falló: no detectó opción inválida"
  exit 1
else
  echo "✅ Manejo de error correcto"
fi