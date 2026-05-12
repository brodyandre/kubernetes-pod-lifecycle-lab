#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="brodyandre/pod-lifecycle-app:local"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${SCRIPT_DIR}/../app"

echo "=============================================="
echo " Build da imagem da aplicacao"
echo "=============================================="
echo

if [[ ! -d "${APP_DIR}" ]]; then
  echo "[ERRO] Pasta da aplicacao nao encontrada: ${APP_DIR}"
  exit 1
fi

echo "[INFO] Entrando na pasta app..."
cd "${APP_DIR}"

echo "[INFO] Executando build da imagem ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" .

echo
echo "[SUCESSO] Build finalizado."
echo "[INFO] Imagem criada:"
docker image ls "${IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
