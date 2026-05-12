# Conceitos do Laboratorio

Este documento resume os conceitos mais importantes para entender o ciclo de vida de Pods e Containers no Kubernetes, com foco pratico para quem esta iniciando.

## 1. Introducao ao ciclo de vida do Pod

Um Pod e a menor unidade de execucao do Kubernetes. Desde a criacao ate o encerramento, ele passa por fases que indicam seu estado operacional.

Diagrama simplificado:

```text
kubectl apply
   |
   v
Pod criado -> agendado em um Node -> containers iniciam -> Pod em execucao
   |
   v
encerramento (gracioso ou forcado)
```

## 2. Diferenca entre Pod e Container

- Container: processo isolado com imagem, sistema de arquivos e runtime.
- Pod: "envelope" Kubernetes que agrupa um ou mais containers que compartilham rede (IP/porta) e volumes.

Regra pratica:

- Voce sobe containers.
- O Kubernetes gerencia Pods.

## 3. Principais fases do Pod

- `Pending`: Pod aceito pela API, mas ainda aguardando agendamento, pull de imagem ou init containers.
- `Running`: Pod agendado e com pelo menos um container principal em execucao.
- `Succeeded`: todos os containers terminaram com sucesso (`exit code 0`) e nao serao reiniciados.
- `Failed`: pelo menos um container terminou com erro e nao houve recuperacao conforme politica de restart.
- `Unknown`: o control plane nao conseguiu obter o estado atual do Pod (problema de comunicacao com o node, por exemplo).

Diagrama de fases:

```text
Pending -> Running -> Succeeded
               |
               +-> Failed
               |
               +-> Unknown (falha de comunicacao/estado indisponivel)
```

## 4. Estados de containers

Dentro do Pod, cada container possui estados proprios:

- `Waiting`: aguardando para iniciar (pull de imagem, init, dependencias).
- `Running`: processo principal ativo.
- `Terminated`: processo finalizado, com codigo de saida e motivo.

Diagrama:

```text
Waiting -> Running -> Terminated
```

## 5. O que e SIGTERM

`SIGTERM` e um sinal de finalizacao "educada". Ele avisa ao processo que ele deve encerrar. A aplicacao pode capturar esse sinal para:

- parar de aceitar novas requisicoes;
- finalizar tarefas pendentes;
- liberar conexoes e recursos;
- salvar estado final.

## 6. O que e SIGKILL

`SIGKILL` (`kill -9`) encerra o processo imediatamente. Ele nao pode ser tratado pela aplicacao, nao executa cleanup e nao permite encerramento gracioso.

## 7. Diferenca pratica entre SIGTERM e SIGKILL

- `SIGTERM`: encerramento controlado, recomendado para producao.
- `SIGKILL`: encerramento abrupto, usado quando o processo nao responde.

Resumo:

```text
SIGTERM -> aplicacao pode tratar -> cleanup possivel
SIGKILL -> aplicacao nao trata   -> cleanup impossivel
```

## 8. Como o Kubernetes encerra um Pod

Fluxo padrao de encerramento:

```text
1) Pod entra em termino
2) Hook preStop (se existir)
3) Envio de SIGTERM para o processo PID 1 do container
4) Espera pelo terminationGracePeriodSeconds
5) Se nao encerrar a tempo: SIGKILL
```

Esse fluxo evita perda de dados e reduz erro para usuarios em servicos com trafego.

## 9. O que e terminationGracePeriodSeconds

E o tempo maximo que o Kubernetes espera apos `SIGTERM` antes de forcar `SIGKILL`.

Exemplo pratico:

- `terminationGracePeriodSeconds: 30`
- A app recebe `SIGTERM` e tem ate 30 segundos para encerrar sozinha.

## 10. O que sao hooks lifecycle

Hooks sao comandos executados pelo kubelet em momentos especificos do ciclo de vida do container:

- `postStart`: executa logo apos a criacao/inicio do container.
- `preStop`: executa antes do encerramento do container.

Uso comum:

- `postStart`: criar arquivo de controle, registrar bootstrap.
- `preStop`: drenar conexoes, registrar encerramento, aguardar alguns segundos.

## 11. O que sao Init Containers

Init Containers sao containers especiais que executam antes do container principal. Eles rodam em sequencia e todos precisam terminar com sucesso para o app principal iniciar.

Diagrama:

```text
init-1 (ok) -> init-2 (ok) -> init-3 (ok) -> container principal inicia
                    |
                    +-> se falhar: Pod fica preso em Init/CrashLoopBackOff
```

## 12. Quando usar Init Containers

Use quando a aplicacao depende de uma etapa previa obrigatoria, por exemplo:

- esperar um servico externo ficar pronto;
- gerar configuracao dinamica;
- validar variaveis/segredos;
- preparar estrutura de diretorios/arquivos.

## 13. Exemplos praticos de uso

### 13.1 Esperar banco de dados ficar disponivel

Um init container executa tentativas de conexao ao DB antes de liberar a app.

### 13.2 Preparar arquivos

Um init container cria arquivo de configuracao em volume compartilhado (`emptyDir`) para o container principal consumir.

### 13.3 Validar dependencias

O init confere existencia de endpoint, arquivo, certificado ou credencial obrigatoria. Se algo faltar, ele falha cedo e evita subir app quebrada.

### 13.4 Executar migracoes simples antes da aplicacao principal

Um init roda script de migracao leve (idempotente) e, somente apos sucesso, o container principal e iniciado.

Fluxo desses cenarios:

```text
Init Container prepara/valida/migra -> sucesso -> App principal sobe
Init Container prepara/valida/migra -> falha   -> App principal nao sobe
```
