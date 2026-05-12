#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="pod-lifecycle-lab"

echo "=============================================="
echo " Limpeza do laboratorio"
echo "=============================================="
echo

if ! kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
  echo "[INFO] Namespace '${NAMESPACE}' nao existe. Nada para limpar."
  exit 0
fi

echo "[INFO] Removendo recursos do namespace '${NAMESPACE}'..."
kubectl delete all --all -n "${NAMESPACE}" --ignore-not-found=true
kubectl delete configmap --all -n "${NAMESPACE}" --ignore-not-found=true
kubectl delete secret --all -n "${NAMESPACE}" --ignore-not-found=true
kubectl delete pvc --all -n "${NAMESPACE}" --ignore-not-found=true
kubectl delete ingress --all -n "${NAMESPACE}" --ignore-not-found=true
kubectl delete job --all -n "${NAMESPACE}" --ignore-not-found=true
kubectl delete cronjob --all -n "${NAMESPACE}" --ignore-not-found=true

echo "[INFO] Removendo namespace '${NAMESPACE}'..."
kubectl delete namespace "${NAMESPACE}" --ignore-not-found=true

echo
echo "[SUCESSO] Limpeza concluida."
