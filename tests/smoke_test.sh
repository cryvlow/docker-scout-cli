#!/usr/bin/env bash
set -euo pipefail

echo "Iniciando prueba de humo..."

if [ ! -f "./install.sh" ]; then
  echo "No se encontró install.sh"
  exit 1
fi

bash -n ./install.sh

echo "Sintaxis de install.sh correcta"

chmod +x ./install.sh

# Prueba básica de ejecución sin instalar realmente
./install.sh --help || true

echo "Prueba de humo completada de forma correcta"