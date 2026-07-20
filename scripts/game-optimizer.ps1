<#
PeanutWindows Optimizer - Game Optimizer

O que faz:
- Organiza jogos por categoria.
- Detecta processos de jogos conhecidos.
- Permite aplicar otimização leve durante a sessão de jogo.
- Define plano de energia Alto Desempenho/Desempenho Máximo quando disponível.
- Sobe prioridade do jogo para High.
- Reduz prioridade de launchers/overlays comuns, sem matar processos.
- Faz limpeza leve de memória usando EmptyWorkingSet em processos não críticos.

O que NÃO faz:
- Não altera arquivos dos jogos.
- Não mexe em anti-cheat.
- Não faz overclock.
- Não desativa serviço essencial do Windows.
#>

$ErrorActionPreference = "SilentlyContinue"

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class MemoryTools {
    [DllImport("psapi.dll")]
    public static extern bool EmptyWorkingSet(IntPtr hProcess);
}
"@

function Show-Header {
    Clear-Host
    Write-Host "====================================="
    Write-Host "   PeanutWindows Game Optimizer"
    Write-Host "====================================="
    Write-Host ""
}

function Pause-Menu {
    Write-Host ""
    Read-Host "Pressione Enter para continuar"
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-GameCatalog {
    return @(
        [PSCustomObject]@{
            Category = "Futebol"
            Games = @(
                @{ Name = "FIFA 21"; Processes = @("FIFA21") },
                @{ Name = "FIFA 22"; Processes = @("FIFA22") },
                @{ Name = "FIFA 23"; Processes = @("FIFA23") },
                @{ Name = "EA SPORTS FC 24"; Processes = @("FC24") },
                @{ Name = "EA SPORTS FC 25"; Processes = @("FC25") },
                @{ Name = "PES 2021 / eFootball PES 2021"; Processes = @("PES2021", "eFootball PES 2021") },
                @{ Name = "eFootball"; Processes = @("eFootball") },
                @{ Name = "Football Life"; Processes = @("FL_2024", "FL_2025", "PES2021") }
            )
        },
        [PSCustomObject]@{
            Category = "Tiro / FPS"
            Games = @(
                @{ Name = "Counter-Strike 2"; Processes = @("cs2") },
                @{ Name = "Valorant"; Processes = @("VALORANT-Win64-Shipping") },
                @{ Name = "Call of Duty / Warzone"; Processes = @("cod", "cod22", "ModernWarfare", "bootstrapper") },
                @{ Name = "Rainbow Six Siege"; Processes = @("RainbowSix", "RainbowSix_Vulkan") },
                @{ Name = "Overwatch 2"; Processes = @("Overwatch") },
                @{ Name = "Apex Legends"; Processes = @("r5apex") },
                @{ Name = "The Finals"; Processes = @("Discovery") },
                @{ Name = "Destiny 2"; Processes = @("destiny2") }
            )
        },
        [PSCustomObject]@{
            Category = "Battle Royale"
            Games = @(
                @{ Name = "Fortnite"; Processes = @("FortniteClient-Win64-Shipping") },
                @{ Name = "Fall Guys"; Processes = @("FallGuys_client_game") },
                @{ Name = "PUBG: Battlegrounds"; Processes = @("TslGame") },
                @{ Name = "Apex Legends"; Processes = @("r5apex") },
                @{ Name = "Call of Duty Warzone"; Processes = @("cod", "ModernWarfare") },
                @{ Name = "NARAKA: BLADEPOINT"; Processes = @("NarakaBladepoint") },
                @{ Name = "Super People"; Processes = @("BravoHotelClient") }
            )
        },
        [PSCustomObject]@{
            Category = "Populares / Sandbox"
            Games = @(
                @{ Name = "Roblox"; Processes = @("RobloxPlayerBeta", "RobloxPlayerLauncher") },
                @{ Name = "Minecraft Java"; Processes = @("javaw", "MinecraftLauncher") },
                @{ Name = "Minecraft Bedrock"; Processes = @("Minecraft.Windows") },
                @{ Name = "GTA V"; Processes = @("GTA5") },
                @{ Name = "Red Dead Redemption 2"; Processes = @("RDR2") },
                @{ Name = "Genshin Impact"; Processes = @("GenshinImpact") },
                @{ Name = "Honkai Star Rail"; Processes = @("StarRail") },
                @{ Name = "League of Legends"; Processes = @("League of Legends", "LeagueClient") },
                @{ Name = "Rocket League"; Processes = @("RocketLeague") },
                @{ Name = "Palworld"; Processes = @("Palworld-Win64-Shipping") }
            )
        }
    )
}

$BackgroundProcesses = @(
    "OneDrive",
    "Teams",
    "msedge",
    "chrome",
    "firefox",
    "Widgets",
    "WidgetService",
    "YourPhone",
    "PhoneExperienceHost",
    "SearchHost",
    "StartMenuExperienceHost",
    "GameBar",
    "GameBarFTServer",
    "XboxGameBar",
    "Discord",
    "EpicGamesLauncher",
    "EADesktop",
    "EALauncher",
    "steamwebhelper"
)

$ProtectedProcesses = @(
    "System",
    "Idle",
    "Registry",
    "smss",
    "csrss",
    "wininit",
    "services",
    "lsass",
    "svchost",
    "winlogon",
    "dwm",
    "explorer",
    "fontdrvhost",
    "spoolsv",
    "audiodg"
)

function Set-GamingPowerPlan {
    Write-Host "Tentando ativar plano de energia para desempenho..."

    $ultimate = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    $high = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

    powercfg -duplicatescheme $ultimate | Out-Null
    powercfg -setactive $ultimate

    if ($LASTEXITCODE -ne 0) {
        powercfg -setactive $high
    }
}

function Trim-ProcessMemory {
    param([System.Diagnostics.Process]$Process)

    try {
        [MemoryTools]::EmptyWorkingSet($Process.Handle) | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Invoke-LightMemoryCleanup {
    param([string[]]$ExcludeProcessNames = @())

    Write-Host "Fazendo limpeza leve de memória em processos seguros..."

    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    $count = 0
    Get-Process | ForEach-Object {
        $name = $_.ProcessName
        if ($ProtectedProcesses -contains $name) { return }
        if ($ExcludeProcessNames -contains $name) { return }
        if ($_.Id -eq $PID) { return }

        if ($_.WorkingSet64 -gt 100MB) {
            if (Trim-ProcessMemory -Process $_) {
                $count++
            }
        }
    }

    Write-Host "Processos otimizados na memória: $count"
}

function Set-GamePriority {
    param([string[]]$ProcessNames)

    foreach ($processName in $ProcessNames) {
        Get-Process -Name $processName -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $_.PriorityClass = "High"
                Write-Host "Prioridade alta aplicada em: $($_.ProcessName)"
            } catch {
                Write-Host "Não foi possível alterar prioridade de: $($_.ProcessName)"
            }
        }
    }
}

function Reduce-BackgroundPriority {
    Write-Host "Reduzindo prioridade de launchers/overlays comuns..."

    foreach ($processName in $BackgroundProcesses) {
        Get-Process -Name $processName -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $_.PriorityClass = "BelowNormal"
                Write-Host "Prioridade reduzida: $($_.ProcessName)"
            } catch {}
        }
    }
}

function Get-DetectedGames {
    $catalog = Get-GameCatalog
    $detected = @()

    foreach ($category in $catalog) {
        foreach ($game in $category.Games) {
            $foundProcesses = @()
            foreach ($processName in $game.Processes) {
                $foundProcesses += Get-Process -Name $processName -ErrorAction SilentlyContinue
            }

            if ($foundProcesses.Count -gt 0) {
                $detected += [PSCustomObject]@{
                    Category = $category.Category
                    Name = $game.Name
                    Processes = $game.Processes
                    Found = $foundProcesses | Select-Object ProcessName, Id
                }
            }
        }
    }

    return $detected
}

function Show-GameCatalog {
    Show-Header
    $catalog = Get-GameCatalog

    foreach ($category in $catalog) {
        Write-Host "[$($category.Category)]"
        foreach ($game in $category.Games) {
            Write-Host "- $($game.Name)"
        }
        Write-Host ""
    }

    Pause-Menu
}

function Show-DetectedGames {
    Show-Header
    $detected = Get-DetectedGames

    if ($detected.Count -eq 0) {
        Write-Host "Nenhum jogo do catálogo foi detectado aberto agora."
        Write-Host "Abra o jogo primeiro e rode novamente."
        Pause-Menu
        return
    }

    Write-Host "Jogos detectados:"
    foreach ($game in $detected) {
        Write-Host "- $($game.Name) [$($game.Category)]"
        foreach ($proc in $game.Found) {
            Write-Host "  Processo: $($proc.ProcessName) | PID: $($proc.Id)"
        }
    }

    Pause-Menu
}

function Optimize-DetectedGames {
    Show-Header

    if (-not (Test-Admin)) {
        Write-Host "Aviso: administrador recomendado para aplicar todas as otimizações."
        Write-Host ""
    }

    $detected = Get-DetectedGames

    if ($detected.Count -eq 0) {
        Write-Host "Nenhum jogo detectado. Abra o jogo e tente novamente."
        Pause-Menu
        return
    }

    Write-Host "Jogos detectados para otimização:"
    foreach ($game in $detected) {
        Write-Host "- $($game.Name)"
    }

    Write-Host ""
    $confirm = Read-Host "Aplicar otimizações leves agora? (S/N)"
    if ($confirm -notmatch "^[sS]") {
        Write-Host "Operação cancelada."
        Pause-Menu
        return
    }

    $gameProcessNames = @()
    foreach ($game in $detected) {
        $gameProcessNames += $game.Processes
    }
    $gameProcessNames = $gameProcessNames | Select-Object -Unique

    Set-GamingPowerPlan
    Reduce-BackgroundPriority
    Invoke-LightMemoryCleanup -ExcludeProcessNames $gameProcessNames
    Set-GamePriority -ProcessNames $gameProcessNames

    Write-Host ""
    Write-Host "Otimização aplicada. Não espere milagre: isso ajuda mais em PC fraco/médio e quando tem muito processo aberto."
    Pause-Menu
}

function Start-WatchMode {
    Show-Header
    Write-Host "Modo watcher iniciado."
    Write-Host "Quando um jogo conhecido abrir, o script aplica otimização leve uma vez."
    Write-Host "Pressione Ctrl+C para parar."
    Write-Host ""

    $optimized = @{}

    while ($true) {
        $detected = Get-DetectedGames

        foreach ($game in $detected) {
            $key = $game.Name
            if (-not $optimized.ContainsKey($key)) {
                Write-Host "Jogo detectado: $($game.Name). Aplicando otimização..."
                $gameProcessNames = $game.Processes | Select-Object -Unique
                Set-GamingPowerPlan
                Reduce-BackgroundPriority
                Invoke-LightMemoryCleanup -ExcludeProcessNames $gameProcessNames
                Set-GamePriority -ProcessNames $gameProcessNames
                $optimized[$key] = $true
                Write-Host "Otimização feita para: $($game.Name)"
                Write-Host ""
            }
        }

        Start-Sleep -Seconds 5
    }
}

function Show-Menu {
    do {
        Show-Header
        Write-Host "1 - Ver catálogo de jogos"
        Write-Host "2 - Detectar jogos abertos"
        Write-Host "3 - Otimizar jogos detectados agora"
        Write-Host "4 - Iniciar watcher automático para jogos"
        Write-Host "0 - Sair"
        Write-Host ""
        $option = Read-Host "Escolha uma opção"

        switch ($option) {
            "1" { Show-GameCatalog }
            "2" { Show-DetectedGames }
            "3" { Optimize-DetectedGames }
            "4" { Start-WatchMode }
            "0" { Write-Host "Saindo..." }
            default {
                Write-Host "Opção inválida."
                Pause-Menu
            }
        }
    } while ($option -ne "0")
}

Show-Menu
