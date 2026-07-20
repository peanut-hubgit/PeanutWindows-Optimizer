# PeanutWindows Optimizer

Um otimizador simples, direto e seguro para Windows, criado para limpar arquivos temporários, ajudar em diagnósticos básicos, remover apps dispensáveis da Microsoft com escolha manual e organizar ajustes úteis sem sair desativando metade do sistema no modo "confia".

> Status: projeto inicial. Ainda em desenvolvimento.

## Objetivo

O **PeanutWindows Optimizer** nasceu para ser uma ferramenta prática para quem quer melhorar o uso do Windows sem cair em scripts agressivos que prometem FPS infinito e entregam dor de cabeça.

A ideia é manter o projeto com três princípios:

- **Seguro primeiro:** nada de remover serviços essenciais sem aviso.
- **Transparente:** o usuário deve saber o que cada opção faz.
- **Reversível quando possível:** ajustes devem ter explicação, backup e caminho de volta.

## Recursos atuais

- Limpeza de arquivos temporários do usuário.
- Limpeza opcional da pasta Temp do Windows.
- Relatório básico do sistema.
- Menu interativo em PowerShell.
- Debloater seletivo de apps Microsoft.
- Backup em JSON antes de remover apps.
- Restauração via manifesto Appx ou `winget`, quando disponível.

## Debloater Microsoft

O script `scripts/debloat-microsoft.ps1` permite escolher quais apps Microsoft remover. Ele não sai apagando tudo igual trator desgovernado.

Apps no catálogo inicial:

- Microsoft Copilot
- Microsoft Clipchamp
- Microsoft News
- Microsoft Weather
- Get Help
- Tips / Introdução
- Microsoft Solitaire Collection
- Microsoft People
- Movies & TV
- Media Player / Groove Music
- Xbox Apps
- Microsoft Teams Personal
- Power Automate
- Microsoft To Do
- Microsoft Edge

### Sobre o Microsoft Edge

O Edge é tratado como item de risco alto porque é integrado ao Windows. Dependendo da versão do sistema, a remoção pode falhar, o Windows pode restaurar depois de uma atualização ou alguns links/atalhos podem continuar chamando componentes dele.

O script tenta manter a remoção e a restauração de forma limpa usando `winget`, sem gambiarra destrutiva no registro.

## Como usar

Abra o PowerShell como administrador e execute o menu principal:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\optimizer.ps1
```

Para rodar direto o debloater Microsoft:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\debloat-microsoft.ps1
```

## Como restaurar apps removidos

O debloater cria um backup em:

```text
backups/debloat-backup.json
```

Para restaurar, execute:

```powershell
.\scripts\debloat-microsoft.ps1
```

Depois escolha:

```text
3 - Restaurar apps usando backup
```

A restauração tenta primeiro registrar novamente apps Appx pelo manifesto local. Se não der, tenta reinstalar via `winget`.

> Reversível não significa mágico: alguns apps da Microsoft podem exigir Microsoft Store, winget funcionando, internet ou reinstalação manual.

## Estrutura

```text
PeanutWindows-Optimizer/
├── README.md
├── LICENSE
├── .gitignore
└── scripts/
    ├── optimizer.ps1
    └── debloat-microsoft.ps1
```

## Aviso importante

Este projeto não é uma ferramenta oficial da Microsoft. Ele é experimental e deve ser usado com cuidado.

Antes de remover qualquer app, leia o que aparece no menu. O script foi feito para evitar burrice automática, mas quem confirma a ação ainda é o usuário.

## Roadmap

- [x] Criar base do repositório
- [x] Adicionar script inicial seguro
- [x] Adicionar debloater Microsoft seletivo
- [x] Adicionar backup e restauração básica
- [ ] Integrar debloater ao menu principal
- [ ] Criar sistema de logs completo
- [ ] Criar modo de restauração mais avançado
- [ ] Criar perfis de otimização
- [ ] Criar interface gráfica futuramente

## Licença

Distribuído sob a licença MIT.
