# PeanutWindows Optimizer

Um otimizador simples, direto e seguro para Windows, criado para limpar arquivos temporários, ajudar em diagnósticos básicos e organizar ajustes úteis sem sair desativando metade do sistema no modo "confia".

> Status: projeto inicial. Ainda em desenvolvimento.

## Objetivo

O **PeanutWindows Optimizer** nasceu para ser uma ferramenta prática para quem quer melhorar o uso do Windows sem cair em scripts agressivos que prometem FPS infinito e entregam dor de cabeça.

A ideia é manter o projeto com três princípios:

- **Seguro primeiro:** nada de remover serviços essenciais sem aviso.
- **Transparente:** o usuário deve saber o que cada opção faz.
- **Reversível quando possível:** ajustes devem ter explicação e caminho de volta.

## Recursos planejados

- Limpeza de arquivos temporários do usuário.
- Limpeza opcional da pasta Temp do Windows.
- Relatório básico do sistema.
- Menu interativo em PowerShell.
- Modo seguro, com confirmações antes de alterações.
- Futuramente: interface simples, logs e perfis de otimização.

## Como usar

Abra o PowerShell como administrador e execute:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\optimizer.ps1
```

> Use por sua conta e risco. Leia o código antes de executar qualquer script no seu PC.

## Estrutura

```text
PeanutWindows-Optimizer/
├── README.md
├── LICENSE
├── .gitignore
└── scripts/
    └── optimizer.ps1
```

## Aviso importante

Este projeto não é uma ferramenta oficial da Microsoft. Ele é experimental e deve ser usado com cuidado.

## Roadmap

- [x] Criar base do repositório
- [x] Adicionar script inicial seguro
- [ ] Criar sistema de logs
- [ ] Criar menu com mais opções
- [ ] Criar modo de restauração
- [ ] Criar interface gráfica futuramente

## Licença

Distribuído sob a licença MIT.
