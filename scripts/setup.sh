#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo " Validacao de ambiente - Pod Lifecycle Lab"
echo "=============================================="
echo

required_cmds=(docker kubectl k3d)
missing_cmds=()

echo "[INFO] Verificando dependencias obrigatorias..."
for cmd in "${required_cmds[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[ERRO] '$cmd' nao encontrado."
    missing_cmds+=("$cmd")
  else
    echo "[OK] '$cmd' encontrado em: $(command -v "$cmd")"
  fi
done

if ((${#missing_cmds[@]} > 0)); then
  echo
  echo "[FALHA] Ambiente incompleto."
  echo "[ACAO] Instale manualmente os itens ausentes: ${missing_cmds[*]}"
  exit 1
fi

echo
echo "[INFO] Exibindo versoes instaladas..."
echo "  - $(docker --version)"
KUBECTL_CLIENT_VERSION="$(kubectl version --client -o jsonpath='{.clientVersion.gitVersion}' 2>/dev/null || true)"
if [[ -z "${KUBECTL_CLIENT_VERSION}" ]]; then
  KUBECTL_CLIENT_VERSION="$(kubectl version --client 2>/dev/null | head -n 1 || true)"
fi
echo "  - kubectl client: ${KUBECTL_CLIENT_VERSION}"
echo "  - $(k3d version | head -n 1)"

echo
if docker info >/dev/null 2>&1; then
  echo "[OK] Docker daemon acessivel."
else
  echo "[AVISO] Docker instalado, mas o daemon nao respondeu."
  echo "[AVISO] Inicie o Docker e teste novamente se necessario."
fi

echo
echo "[SUCESSO] Validacao concluida. Nenhuma instalacao foi executada."
