# Evidências do Laboratório (Checklist de Prints)

Este checklist ajuda a organizar evidências visuais para enriquecer o repositório no GitHub e fortalecer seu portfólio técnico.

Pasta recomendada para salvar os prints:

- `assets/screenshots/`

## Checklist de evidências

### 1) Cluster k3d criado com 3 servers e 3 agents

- O que capturar: saída de `k3d cluster list` mostrando `meucluster` com `3/3` em `SERVERS` e `AGENTS`.
- Nome sugerido:
  - `assets/screenshots/01-k3d-cluster-created.png`

### 2) Saída do comando kubectl get nodes

- O que capturar: nodes `Ready` (control-plane e agents).
- Nome sugerido:
  - `assets/screenshots/02-kubectl-get-nodes.png`

### 3) Build da imagem Docker

- O que capturar: final do `./scripts/build-image.sh` com imagem `brodyandre/pod-lifecycle-app:local` criada.
- Nome sugerido:
  - `assets/screenshots/03-docker-image-build.png`

### 4) Import da imagem para o k3d

- O que capturar: execução do `./scripts/import-image-k3d.sh` com mensagem de sucesso.
- Nome sugerido:
  - `assets/screenshots/04-k3d-image-import.png`

### 5) Pods rodando no namespace pod-lifecycle-lab

- O que capturar: `kubectl get pods -n pod-lifecycle-lab` com status `Running` nos cenários principais.
- Nome sugerido:
  - `assets/screenshots/05-pods-running-namespace.png`

### 6) Logs da aplicação recebendo SIGTERM

- O que capturar: logs do deployment mostrando recebimento de `SIGTERM` e início de shutdown.
- Nome sugerido:
  - `assets/screenshots/06-sigterm-logs.png`

### 7) Evento de encerramento do Pod

- O que capturar: `kubectl get events -n pod-lifecycle-lab --sort-by=.lastTimestamp` com eventos de término/recriação.
- Nome sugerido:
  - `assets/screenshots/07-pod-termination-events.png`

### 8) Execução do postStart

- O que capturar: evidência do hook `postStart` (por exemplo via `kubectl exec ... -- cat /tmp/poststart.log`).
- Nome sugerido:
  - `assets/screenshots/08-poststart-execution.png`

### 9) Execução do preStop

- O que capturar: logs/eventos mostrando `preStop` antes do encerramento do container.
- Nome sugerido:
  - `assets/screenshots/09-prestop-execution.png`

### 10) Init Container executando com sucesso

- O que capturar: status do `init-success-pod` e/ou `describe` confirmando init completo.
- Nome sugerido:
  - `assets/screenshots/10-init-success.png`

### 11) Init Container falhando propositalmente

- O que capturar: `Init:CrashLoopBackOff` e detalhes em `describe` do `init-failure-pod`.
- Nome sugerido:
  - `assets/screenshots/11-init-failure-crashloop.png`

### 12) Correção do Init Container

- O que capturar: pod corrigido (`init-fixed-pod`) em execução após aplicar `06-init-container-fixed.yaml`.
- Nome sugerido:
  - `assets/screenshots/12-init-fixed.png`

### 13) GitHub Actions validando YAML com sucesso

- O que capturar: aba `Actions` com workflow `Validate Kubernetes YAML` em status verde.
- Nome sugerido:
  - `assets/screenshots/13-github-actions-yamllint-success.png`

## Dica de apresentação para portfólio

Ao publicar no README, priorize 4 a 6 evidências com maior valor técnico:

- nodes prontos;
- pods rodando;
- logs de SIGTERM;
- falha de init container;
- correção do init container;
- pipeline de YAML em sucesso.
