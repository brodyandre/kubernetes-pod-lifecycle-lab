#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="pod-lifecycle-lab"

echo "=============================================="
echo " Check rapido do laboratorio"
echo "=============================================="
echo

echo "[INFO] Pods:"
kubectl get pods -n "${NAMESPACE}"

echo
echo "[INFO] Deployments:"
kubectl get deploy -n "${NAMESPACE}"

echo
echo "[INFO] Eventos (ordenados por .lastTimestamp):"
kubectl get events -n "${NAMESPACE}" --sort-by=.lastTimestamp

echo
echo "[DICA] Comandos uteis para investigacao:"
echo "  kubectl logs -n ${NAMESPACE} deploy/sigterm-graceful-shutdown -f"
echo "  kubectl logs -n ${NAMESPACE} deploy/lifecycle-hooks-demo -f"
echo "  kubectl describe pod -n ${NAMESPACE} init-success-pod"
echo "  kubectl describe pod -n ${NAMESPACE} init-failure-pod"
