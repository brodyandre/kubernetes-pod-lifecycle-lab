# Comandos do Laboratorio

Guia rapido para executar o laboratorio no WSL2 Ubuntu ou Linux.

## 1. Verificar ambiente

Valida se Docker, kubectl e k3d estao disponiveis.

```bash
docker version
kubectl version --client
k3d version
```

## 2. Criar cluster k3d (meucluster)

Cria um cluster com 3 servidores de controle e 3 agentes.

```bash
k3d cluster create meucluster --servers 3 --agents 3
```

## 3. Verificar cluster

Confere se o cluster foi criado e se os nodes estao prontos.

```bash
k3d cluster list
kubectl get nodes
```

## 4. Rodar setup

Concede permissao de execucao aos scripts e valida o ambiente.

```bash
chmod +x scripts/*.sh
./scripts/setup.sh
```

## 5. Buildar imagem

Build da imagem local da aplicacao.

```bash
./scripts/build-image.sh
```

## 6. Importar imagem no k3d

Importa a imagem local para o cluster `meucluster`.

```bash
./scripts/import-image-k3d.sh
```

## 7. Aplicar manifests

Aplica os manifests principais do laboratorio.

```bash
./scripts/apply-all.sh
```

## 8. Verificar Pods

Lista o status dos Pods no namespace do laboratorio.

```bash
kubectl get pods -n pod-lifecycle-lab
```

## 9. Ver logs

Mostra logs dos Pods da aplicacao Python.

```bash
kubectl logs -n pod-lifecycle-lab -l app=pod-lifecycle-app
```

## 10. Testar encerramento gracioso

Remove Pods da app para observar `SIGTERM` e recriacao pelo Deployment.

```bash
kubectl delete pod -n pod-lifecycle-lab -l app=pod-lifecycle-app
```

## 11. Ver eventos

Exibe eventos ordenados por tempo para troubleshooting.

```bash
kubectl get events -n pod-lifecycle-lab --sort-by=.lastTimestamp
```

## 12. Testar initContainer com falha

Aplica o manifesto de falha e analisa o Pod.

```bash
kubectl apply -f manifests/05-init-container-failure.yaml
kubectl get pods -n pod-lifecycle-lab
kubectl describe pod -n pod-lifecycle-lab init-failure-pod
```

## 13. Corrigir usando o manifesto ajustado

Aplica a versao corrigida do cenario de init container.

```bash
kubectl apply -f manifests/06-init-container-fixed.yaml
```

## 14. Limpeza

Remove os recursos do laboratorio e exclui o namespace.

```bash
./scripts/cleanup.sh
```
