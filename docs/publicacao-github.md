# Publicação no GitHub via Terminal

Este guia mostra como publicar o projeto no GitHub usando terminal, considerando:

- Conta: `https://github.com/brodyandre`
- Repositório: `kubernetes-pod-lifecycle-lab`

## 1) Inicializar o Git

Inicializa o repositório local na pasta atual.

```bash
git init
```

## 2) Adicionar arquivos

Adiciona todos os arquivos do projeto para o stage.

```bash
git add .
```

## 3) Criar primeiro commit

Cria o commit inicial com mensagem descritiva.

```bash
git commit -m "docs: add kubernetes pod lifecycle lab"
```

## 4) Criar branch main

Define `main` como branch principal.

```bash
git branch -M main
```

## 5) Criar repositório com GitHub CLI (gh)

Cria o repositório público na conta `brodyandre`, conecta o remoto `origin` e faz o push inicial.

```bash
gh repo create brodyandre/kubernetes-pod-lifecycle-lab --public --source=. --remote=origin --push
```

## 6) Alternativa: repositório já criado manualmente

Se o repositório já existir no GitHub, conecte o remoto e faça push da branch `main`.

```bash
git remote add origin https://github.com/brodyandre/kubernetes-pod-lifecycle-lab.git
git push -u origin main
```

## 7) Verificar status final

Confirma se o working tree está limpo e se o remoto `origin` está configurado corretamente.

```bash
git status
git remote -v
```

## Observação útil

Se o comando `gh repo create` falhar por autenticação, execute antes:

```bash
gh auth login
```
