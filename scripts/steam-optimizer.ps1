<#
PeanutWindows Optimizer - Steam Optimizer

O que faz:
- Detecta Steam aberta.
- Limpa caches seguros da Steam com confirmação.
- Reduz prioridade do steamwebhelper durante jogo.
- Mantém o processo principal da Steam funcional.
- Não apaga biblioteca, saves, screenshots nem jogos instalados.

Recomendação:
- Feche a Steam antes de limpar cache.
#>

$ErrorActionPreference = "SilentlyContinue"

function Show-Header {
    Clear-Host
    Write-Host "====================================="
    Write-Host "   PeanutWindows Steam Optimizer"
    Write-Host "====================================="
    Write-Host ""
}

function Pause-Menu {
    Write-Host ""
    Read-Host "Pressione Enter para continuar"
}

function Get-SteamPath {
    $possiblePaths = @(
        "$env:ProgramFiles(x86)\Steam",
        "$env:ProgramFiles\Steam",
        "$env:LOCALAPPDATA\Steam"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path (Join-Path $path "steam.exe")) {
            return $path
        }
    }

    $regPath = "HKCU:\Software\Valve\Steam"
    if (Test-Path $regPath) {
        $steamPath = (Get-ItemProperty -Path $regPath).SteamPath
        if ($steamPath -and (Test-Path $steamPath)) {
            return $steamPath
        }
    }

    return $null
}

function Show-SteamStatus {
    Show-Header
    $steamPath = Get-SteamPath
    $steam = Get-Process -Name "steam" -ErrorAction SilentlyContinue
    $webhelpers = Get-Process -Name "steamwebhelper" -ErrorAction SilentlyContinue

    if ($steamPath) {
        Write-Host "Steam encontrada em: $steamPath"
    } else {
        Write-Host "Steam não encontrada nos caminhos padrão."
    }

    if ($steam) {
        Write-Host "Steam está aberta."
    } else {
        Write-Host "Steam está fechada."
    }

    Write-Host "steamwebhelper abertos: $($webhelpers.Count)"
    Pause-Menu
}

function Stop-SteamSafely {
    $steam = Get-Process -Name "steam" -ErrorAction SilentlyContinue

    if (-not $steam) {
        Write-Host "Steam já está fechada."
        return
    }

    $confirm = Read-Host "Fechar Steam agora para limpar cache com segurança? (S/N)"
    if ($confirm -match "^[sS]") {
        Get-Process -Name "steamwebhelper" -ErrorAction SilentlyContinue | Stop-Process -Force
        Get-Process -Name "steam" -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep -Seconds 3
        Write-Host "Steam fechada."
    } else {
        Write-Host "Steam mantida aberta. Algumas limpezas podem falhar."
    }
}

function Clear-FolderSafe {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return
    }

    Write-Host "Limpando: $Path"
    Get-ChildItem -Path $Path -Force | Remove-Item -Recurse -Force
}

function Clear-SteamCache {
    Show-Header
    $steamPath = Get-SteamPath

    if (-not $steamPath) {
        Write-Host "Steam não encontrada."
        Pause-Menu
        return
    }

    Write-Host "Esta limpeza NÃO remove jogos, saves ou screenshots."
    Write-Host "Ela mira caches seguros e temporários."
    Write-Host ""
    $confirm = Read-Host "Continuar? (S/N)"

    if ($confirm -notmatch "^[sS]") {
        Write-Host "Operação cancelada."
        Pause-Menu
        return
    }

    Stop-SteamSafely

    $targets = @(
        Join-Path $steamPath "appcache",
        Join-Path $steamPath "config\htmlcache",
        Join-Path $steamPath "dumps",
        Join-Path $steamPath "logs",
        Join-Path $steamPath "steamui\cache"
    )

    foreach ($target in $targets) {
        Clear-FolderSafe -Path $target
    }

    Write-Host ""
    Write-Host "Cache da Steam limpo. Abra a Steam novamente depois."
    Pause-Menu
}

function Optimize-SteamDuringGame {
    Show-Header
    Write-Host "Aplicando otimização leve para Steam durante jogo..."

    Get-Process -Name "steamwebhelper" -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $_.PriorityClass = "BelowNormal"
            Write-Host "Prioridade reduzida: steamwebhelper PID $($_.Id)"
        } catch {}
    }

    Get-Process -Name "steam" -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $_.PriorityClass = "BelowNormal"
            Write-Host "Prioridade reduzida: steam PID $($_.Id)"
        } catch {}
    }

    Write-Host ""
    Write-Host "Não fechei a Steam. Só reduzi prioridade para sobrar mais fôlego para o jogo."
    Pause-Menu
}

function Restart-SteamClean {
    Show-Header
    $steamPath = Get-SteamPath

    if (-not $steamPath) {
        Write-Host "Steam não encontrada."
        Pause-Menu
        return
    }

    Stop-SteamSafely
    Start-Sleep -Seconds 2

    $steamExe = Join-Path $steamPath "steam.exe"
    Start-Process -FilePath $steamExe
    Write-Host "Steam reiniciada."
    Pause-Menu
}

function Show-Menu {
    do {
        Show-Header
        Write-Host "1 - Ver status da Steam"
        Write-Host "2 - Limpar cache seguro da Steam"
        Write-Host "3 - Otimizar Steam durante jogo"
        Write-Host "4 - Reiniciar Steam limpa"
        Write-Host "0 - Sair"
        Write-Host ""
        $option = Read-Host "Escolha uma opção"

        switch ($option) {
            "1" { Show-SteamStatus }
            "2" { Clear-SteamCache }
            "3" { Optimize-SteamDuringGame }
            "4" { Restart-SteamClean }
            "0" { Write-Host "Saindo..." }
            default {
                Write-Host "Opção inválida."
                Pause-Menu
            }
        }
    } while ($option -ne "0")
}

Show-Menu
