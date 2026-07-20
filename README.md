# PeanutWindows Optimizer

Um otimizador simples, direto e seguro para Windows, criado para limpar arquivos temporários, ajudar em diagnósticos básicos, remover apps dispensáveis da Microsoft com escolha manual, otimizar sessões de jogos e organizar ajustes úteis sem sair desativando metade do sistema no modo "confia".

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
- Otimizador de jogos por categoria.
- Otimizador exclusivo da Steam.
- Watcher automático de memória para jogos.

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

## Otimização de jogos

O projeto agora possui três scripts focados em jogos.

### 1. Otimizador por categoria

Arquivo:

```text
scripts/game-optimizer.ps1
```

Categorias iniciais:

- Futebol: FIFA 21, FIFA 22, FIFA 23, EA SPORTS FC 24, EA SPORTS FC 25, PES 2021, eFootball e Football Life.
- Tiro/FPS: Counter-Strike 2, Valorant, Call of Duty, Rainbow Six Siege, Overwatch 2, Apex Legends, The Finals e Destiny 2.
- Battle Royale: Fortnite, Fall Guys, PUBG, Apex Legends, Warzone, Naraka e outros.
- Populares/Sandbox: Roblox, Minecraft, GTA V, Red Dead Redemption 2, Genshin Impact, Honkai Star Rail, League of Legends, Rocket League e Palworld.

O script detecta jogos abertos e aplica otimizações leves:

- ativa plano de energia de alto desempenho quando disponível;
- aumenta prioridade do processo do jogo;
- reduz prioridade de launchers/overlays comuns;
- faz limpeza leve de memória em processos não críticos.

### 2. Otimizador exclusivo da Steam

Arquivo:

```text
scripts/steam-optimizer.ps1
```

Recursos:

- detecta instalação da Steam;
- mostra status da Steam;
- limpa caches seguros;
- reduz prioridade da Steam e do `steamwebhelper` durante jogo;
- reinicia a Steam de forma limpa.

Ele não apaga biblioteca, jogos, saves ou screenshots.

### 3. Watcher automático de memória para jogos

Arquivo:

```text
scripts/game-memory-watch.ps1
```

Esse script fica monitorando processos. Quando detecta um jogo conhecido abrindo, ele faz uma limpeza leve de RAM e tenta colocar o jogo em prioridade alta.

Modos:

- recomendado: só jogos conhecidos;
- agressivo: qualquer app novo, não recomendado para uso diário.

> Limpar RAM não cria RAM do nada. Ele só pede ao Windows para reduzir o working set de processos ociosos. Em alguns PCs ajuda; em outros o ganho é pequeno. Milagre quem promete é vendedor de curso ruim.

## Como usar

Abra o PowerShell como administrador e execute o menu principal:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\optimizer.ps1
```

Pelo menu principal você pode abrir:

```text
4 - Debloater Microsoft
5 - Otimizador de jogos por categoria
6 - Otimizador exclusivo da Steam
7 - Watcher automático de memória para jogos
```

Para rodar direto o debloater Microsoft:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\debloat-microsoft.ps1
```

Para rodar direto o otimizador de jogos:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\game-optimizer.ps1
```

Para rodar direto o otimizador da Steam:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\steam-optimizer.ps1
```

Para rodar direto o watcher de memória:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\game-memory-watch.ps1
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
    ├── debloat-microsoft.ps1
    ├── game-optimizer.ps1
    ├── steam-optimizer.ps1
    └── game-memory-watch.ps1
```

## Aviso importante

Este projeto não é uma ferramenta oficial da Microsoft. Ele é experimental e deve ser usado com cuidado.

Antes de remover apps ou aplicar otimizações, leia o que aparece no menu. O script foi feito para evitar burrice automática, mas quem confirma a ação ainda é o usuário.

## Roadmap

- [x] Criar base do repositório
- [x] Adicionar script inicial seguro
- [x] Adicionar debloater Microsoft seletivo
- [x] Adicionar backup e restauração básica
- [x] Integrar debloater ao menu principal
- [x] Criar otimizador de jogos por categoria
- [x] Criar otimizador exclusivo da Steam
- [x] Criar watcher automático de memória para jogos
- [ ] Criar sistema de logs completo
- [ ] Criar modo de restauração mais avançado
- [ ] Criar perfis de otimização
- [ ] Criar interface gráfica futuramente

## Licença

Distribuído sob a licença MIT.
