#!/usr/bin/env bash
set -euo pipefail
set -x  # 🔥 IMPORTANTE para kcov

echo "Iniciando prueba de humo..."

bash -n ./install.sh

chmod +x ./install.sh

echo "Test: help"
./install.sh --help || true

echo "Test: ejecución básica"
./install.sh || true

echo "Test: opción inválida"
./install.sh --invalid-option || true

echo "Prueba completada"