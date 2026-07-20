<#
PeanutWindows Optimizer - Game Memory Watcher

O que faz:
- Fica monitorando abertura de processos.
- Quando detecta um jogo conhecido, faz limpeza leve de RAM.
- Por padrão, só age em jogos do catálogo.
- Modo opcional para agir em qualquer app novo, mas NÃO recomendado.

A limpeza usa EmptyWorkingSet em processos não críticos.
Isso não aumenta RAM física; apenas pede ao Windows para reduzir working set de processos ociosos.
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

$GameProcesses = @(
    "FIFA21", "FIFA22", "FIFA23", "FC24", "FC25", "PES2021", "eFootball",
    "cs2", "VALORANT-Win64-Shipping", "cod", "cod22", "ModernWarfare", "RainbowSix", "RainbowSix_Vulkan", "Overwatch", "r5apex", "Discovery", "destiny2",
    "FortniteClient-Win64-Shipping", "FallGuys_client_game", "TslGame", "NarakaBladepoint", "BravoHotelClient",
    "RobloxPlayerBeta", "RobloxPlayerLauncher", "javaw", "MinecraftLauncher", "Minecraft.Windows", "GTA5", "RDR2", "GenshinImpact", "StarRail", "League of Legends", "LeagueClient", "RocketLeague", "Palworld-Win64-Shipping"
)

$ProtectedProcesses = @(
    "System", "Idle", "Registry", "smss", "csrss", "wininit", "services", "lsass", "svchost", "winlogon", "dwm", "explorer", "fontdrvhost", "spoolsv", "audiodg"
)

function Show-Header {
    Clear-Host
    Write-Host "====================================="
    Write-Host "  PeanutWindows Game Memory Watcher"
    Write-Host "====================================="
    Write-Host ""
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

function Invoke-MemoryClean {
    param([string]$TriggeredBy)

    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Limpando memória por detecção de: $TriggeredBy"

    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    $cleaned = 0

    Get-Process | ForEach-Object {
        if ($ProtectedProcesses -contains $_.ProcessName) { return }
        if ($_.ProcessName -eq $TriggeredBy) { return }
        if ($_.Id -eq $PID) { return }

        if ($_.WorkingSet64 -gt 100MB) {
            if (Trim-ProcessMemory -Process $_) {
                $cleaned++
            }
        }
    }

    $game = Get-Process -Name $TriggeredBy -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($game) {
        try {
            $game.PriorityClass = "High"
            Write-Host "Prioridade alta aplicada ao jogo: $TriggeredBy"
        } catch {}
    }

    Write-Host "Processos ajustados na RAM: $cleaned"
    Write-Host ""
}

function Start-GameOnlyWatch {
    Show-Header
    Write-Host "Modo recomendado: limpar RAM somente quando jogo conhecido abrir."
    Write-Host "Pressione Ctrl+C para parar."
    Write-Host ""

    $alreadyHandled = @{}

    while ($true) {
        foreach ($gameName in $GameProcesses) {
            $process = Get-Process -Name $gameName -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($process -and -not $alreadyHandled.ContainsKey($gameName)) {
                Invoke-MemoryClean -TriggeredBy $gameName
                $alreadyHandled[$gameName] = $true
            }

            if (-not $process -and $alreadyHandled.ContainsKey($gameName)) {
                $alreadyHandled.Remove($gameName)
            }
        }

        Start-Sleep -Seconds 4
    }
}

function Start-AnyAppWatch {
    Show-Header
    Write-Host "Modo agressivo: limpar RAM quando qualquer app novo abrir."
    Write-Host "Não recomendado para uso diário. Pode causar microtravadas."
    Write-Host "Pressione Ctrl+C para parar."
    Write-Host ""

    $knownPids = @{}
    Get-Process | ForEach-Object { $knownPids[$_.Id] = $_.ProcessName }

    while ($true) {
        Get-Process | ForEach-Object {
            if (-not $knownPids.ContainsKey($_.Id)) {
                $name = $_.ProcessName
                $knownPids[$_.Id] = $name

                if ($ProtectedProcesses -contains $name) { return }
                Invoke-MemoryClean -TriggeredBy $name
            }
        }

        Start-Sleep -Seconds 5
    }
}

function Show-Menu {
    do {
        Show-Header
        Write-Host "1 - Watcher recomendado: só jogos conhecidos"
        Write-Host "2 - Watcher agressivo: qualquer app novo"
        Write-Host "0 - Sair"
        Write-Host ""
        $option = Read-Host "Escolha uma opção"

        switch ($option) {
            "1" { Start-GameOnlyWatch }
            "2" {
                $confirm = Read-Host "Tem certeza? Esse modo pode causar travadinhas. (S/N)"
                if ($confirm -match "^[sS]") { Start-AnyAppWatch }
            }
            "0" { Write-Host "Saindo..." }
            default { Write-Host "Opção inválida."; Read-Host "Enter para continuar" }
        }
    } while ($option -ne "0")
}

Show-Menu
