#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="brodyandre/pod-lifecycle-app:local"
CLUSTER_NAME="meucluster"

echo "=============================================="
echo " Import da imagem para k3d"
echo "=============================================="
echo

if ! command -v k3d >/dev/null 2>&1; then
  echo "[ERRO] k3d nao encontrado."
  exit 1
fi

echo "[INFO] Verificando se o cluster '${CLUSTER_NAME}' existe..."
if ! k3d cluster list "${CLUSTER_NAME}" --no-headers | grep -q "^${CLUSTER_NAME}[[:space:]]"; then
  echo "[ERRO] Cluster '${CLUSTER_NAME}' nao encontrado."
  echo "[ACAO] Crie o cluster antes de importar a imagem."
  exit 1
fi

echo "[OK] Cluster '${CLUSTER_NAME}' encontrado."
echo "[INFO] Importando imagem ${IMAGE_NAME}..."
k3d image import "${IMAGE_NAME}" -c "${CLUSTER_NAME}"

echo
echo "[SUCESSO] Importacao concluida."
