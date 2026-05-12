#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS_DIR="${SCRIPT_DIR}/../manifests"
NAMESPACE="pod-lifecycle-lab"

echo "=============================================="
echo " Aplicacao dos manifests principais"
echo "=============================================="
echo

ordered_manifests=(
  "00-namespace.yaml"
  "01-basic-pod-lifecycle.yaml"
  "02-sigterm-graceful-shutdown.yaml"
  "03-poststart-prestop-hooks.yaml"
  "04-init-container-success.yaml"
)

for manifest in "${ordered_manifests[@]}"; do
  file_path="${MANIFESTS_DIR}/${manifest}"
  if [[ ! -f "${file_path}" ]]; then
    echo "[ERRO] Manifest nao encontrado: ${file_path}"
    exit 1
  fi

  echo "[INFO] kubectl apply -f manifests/${manifest}"
  kubectl apply -f "${file_path}"
done

echo
echo "[INFO] O arquivo '05-init-container-failure.yaml' NAO foi aplicado automaticamente."
echo "[INFO] Esse arquivo e propositalmente usado para troubleshooting (Init:CrashLoopBackOff)."
echo "[INFO] Para aplicar manualmente quando quiser:"
echo "       kubectl apply -f manifests/05-init-container-failure.yaml"

echo
echo "[SUCESSO] Manifests principais aplicados."
echo "[INFO] Estado atual no namespace ${NAMESPACE}:"
kubectl get pods -n "${NAMESPACE}"
kubectl get deploy -n "${NAMESPACE}"
