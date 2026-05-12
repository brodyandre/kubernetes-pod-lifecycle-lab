# Troubleshooting: Pods e Init Containers

Guia pratico para diagnosticar problemas comuns no laboratorio `pod-lifecycle-lab`.

Comandos base (use em quase todos os cenarios):

```bash
kubectl get pods -n pod-lifecycle-lab
kubectl describe pod <nome-do-pod> -n pod-lifecycle-lab
kubectl logs <nome-do-pod> -n pod-lifecycle-lab
kubectl logs <nome-do-pod> -c <nome-do-init-container> -n pod-lifecycle-lab
kubectl get events -n pod-lifecycle-lab --sort-by=.lastTimestamp
```

## Cenario 1: Pod preso em Pending

### Sintoma

Pod aparece em `Pending` por muito tempo e nao avanca para `Running`.

### Causa provavel

- falta de recursos no node (CPU/memoria);
- problema de agendamento;
- PVC/volume nao disponivel;
- imagem ainda nao foi baixada.

### Como investigar

Veja eventos do pod e mensagens do scheduler. Em geral o motivo aparece em `Events` no `describe`.

### Comandos uteis

```bash
kubectl get pods -n pod-lifecycle-lab
kubectl describe pod <nome-do-pod> -n pod-lifecycle-lab
kubectl get events -n pod-lifecycle-lab --sort-by=.lastTimestamp
kubectl get nodes
```

### Possivel solucao

- liberar recursos no cluster;
- corrigir `nodeSelector`, `taints/tolerations` ou afinidade, se existir;
- verificar status de volumes;
- aguardar pull da imagem quando for primeira execucao.

## Cenario 2: Pod em CrashLoopBackOff

### Sintoma

Pod alterna entre iniciar e falhar continuamente (`CrashLoopBackOff`).

### Causa provavel

- erro na aplicacao principal (excecao ao subir);
- comando/entrypoint incorreto;
- variavel de ambiente obrigatoria ausente;
- probe mal configurada derrubando o container.

### Como investigar

Analise logs do container principal e o ultimo estado encerrado (`Last State`) no `describe`.

### Comandos uteis

```bash
kubectl get pods -n pod-lifecycle-lab
kubectl describe pod <nome-do-pod> -n pod-lifecycle-lab
kubectl logs <nome-do-pod> -n pod-lifecycle-lab
kubectl logs <nome-do-pod> -n pod-lifecycle-lab --previous
kubectl get events -n pod-lifecycle-lab --sort-by=.lastTimestamp
```

### Possivel solucao

- corrigir erro da app e rebuild da imagem;
- revisar `command`, `args` e variaveis;
- ajustar `readinessProbe/livenessProbe` (path, porta, delay, timeout).

## Cenario 3: Pod em Init:CrashLoopBackOff

### Sintoma

Pod fica em `Init:CrashLoopBackOff` e o container principal nao inicia.

### Causa provavel

Algum init container falha e entra em loop de reinicio.

### Como investigar

Descubra qual init container falhou e leia os logs dele. O `describe` mostra nome, exit code e motivo.

### Comandos uteis

```bash
kubectl get pods -n pod-lifecycle-lab
kubectl describe pod <nome-do-pod> -n pod-lifecycle-lab
kubectl logs <nome-do-pod> -c <nome-do-init-container> -n pod-lifecycle-lab
kubectl get events -n pod-lifecycle-lab --sort-by=.lastTimestamp
```

### Possivel solucao

- corrigir script/comando do init container;
- validar dependencia externa (DB, API, arquivo, DNS);
- aplicar manifesto corrigido (`06-init-container-fixed.yaml`).

## Cenario 4: Init Container falhando

### Sintoma

Init container termina com `Exit Code != 0` e o Pod nao inicializa.

### Causa provavel

- comando propositalmente com erro (como no cenario de laboratorio);
- arquivo esperado nao existe;
- erro de permissao;
- timeout ao acessar dependencia.

### Como investigar

Priorize logs do init container, nao do principal, porque o principal pode nem ter iniciado.

### Comandos uteis

```bash
kubectl describe pod <nome-do-pod> -n pod-lifecycle-lab
kubectl logs <nome-do-pod> -c <nome-do-init-container> -n pod-lifecycle-lab
kubectl get events -n pod-lifecycle-lab --sort-by=.lastTimestamp
```

Exemplo direto no laboratorio:

```bash
kubectl describe pod init-failure-pod -n pod-lifecycle-lab
kubectl logs init-failure-pod -c init-failing-step -n pod-lifecycle-lab
```

### Possivel solucao

- ajustar o comando do init container para retornar sucesso;
- garantir que a dependencia exista antes do teste;
- separar validacoes em mais de um init container para facilitar debug.

## Cenario 5: Imagem nao encontrada ou ImagePullBackOff

### Sintoma

Pod em `ImagePullBackOff` ou `ErrImagePull`.

### Causa provavel

- nome/tag da imagem incorreto;
- imagem local nao importada no k3d;
- falta de permissao para registry privado.

### Como investigar

Leia a secao `Events` no `describe` para ver erro exato de pull.

### Comandos uteis

```bash
kubectl get pods -n pod-lifecycle-lab
kubectl describe pod <nome-do-pod> -n pod-lifecycle-lab
kubectl get events -n pod-lifecycle-lab --sort-by=.lastTimestamp
docker image ls | grep pod-lifecycle-app
```

### Possivel solucao

- rebuild da imagem local;
- importar novamente no k3d;
- confirmar `image` e `imagePullPolicy` no manifesto.

Exemplo:

```bash
./scripts/build-image.sh
./scripts/import-image-k3d.sh
```

## Cenario 6: Aplicacao nao encerra corretamente

### Sintoma

Ao deletar o Pod, a aplicacao nao finaliza de forma graciosa ou perde requisicoes.

### Causa provavel

- app nao trata `SIGTERM`;
- tempo de encerramento maior que a janela configurada;
- hook `preStop` ausente ou ineficaz.

### Como investigar

Observe logs durante `kubectl delete pod` e confira se aparecem mensagens de `SIGTERM` e shutdown.

### Comandos uteis

```bash
kubectl logs -n pod-lifecycle-lab -l app=pod-lifecycle-app -f
kubectl delete pod -n pod-lifecycle-lab -l app=pod-lifecycle-app
kubectl describe pod <nome-do-pod> -n pod-lifecycle-lab
kubectl get events -n pod-lifecycle-lab --sort-by=.lastTimestamp
```

### Possivel solucao

- implementar handler de `SIGTERM` na app;
- aumentar `terminationGracePeriodSeconds`;
- incluir log claro de inicio/fim do shutdown.

## Cenario 7: preStop demora mais que terminationGracePeriodSeconds

### Sintoma

Pod recebe termino, mas e finalizado a forca antes do fim da rotina de `preStop`.

### Causa provavel

Tempo total do `preStop` + encerramento da app excede `terminationGracePeriodSeconds`.

### Como investigar

Compare o tempo do `sleep`/rotina no `preStop` com o valor definido no manifesto.

### Comandos uteis

```bash
kubectl describe pod <nome-do-pod> -n pod-lifecycle-lab
kubectl get pod <nome-do-pod> -n pod-lifecycle-lab -o yaml | grep -n "terminationGracePeriodSeconds"
kubectl logs <nome-do-pod> -n pod-lifecycle-lab
kubectl get events -n pod-lifecycle-lab --sort-by=.lastTimestamp
```

### Possivel solucao

- reduzir duracao do `preStop`;
- aumentar `terminationGracePeriodSeconds`;
- mover tarefas pesadas de encerramento para outro mecanismo (fila/job), evitando bloquear termino.

## Cenario 8: Diferenca entre erro no container principal e erro no initContainer

### Sintoma

Pod nao fica pronto, mas o comportamento muda conforme o tipo de erro.

### Causa provavel

- erro no init container: bloqueia o inicio do principal;
- erro no container principal: principal inicia e falha em loop.

### Como investigar

Use `describe` para identificar em qual secao esta a falha (`Init Containers` vs `Containers`) e depois leia logs corretos.

### Comandos uteis

```bash
kubectl describe pod <nome-do-pod> -n pod-lifecycle-lab
kubectl logs <nome-do-pod> -c <nome-do-init-container> -n pod-lifecycle-lab
kubectl logs <nome-do-pod> -n pod-lifecycle-lab
kubectl get events -n pod-lifecycle-lab --sort-by=.lastTimestamp
```

### Possivel solucao

- se falha no init: corrigir preparacao/validacao anterior ao start;
- se falha no principal: corrigir app, comando de execucao, probes ou configuracao runtime.

Resumo pratico:

- erro no init container -> Pod fica preso em `Init:*`, app principal nao sobe;
- erro no container principal -> Pod pode iniciar e cair em `CrashLoopBackOff`.
