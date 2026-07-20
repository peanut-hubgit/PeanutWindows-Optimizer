<#
PeanutWindows Optimizer
Menu principal seguro para limpeza simples, debloat e otimização de jogos.

Importante:
- Não desativa serviços essenciais.
- Não mexe no registro do Windows sem necessidade.
- Pede confirmação antes de ações sensíveis.
#>

$ErrorActionPreference = "SilentlyContinue"

function Show-Header {
    Clear-Host
    Write-Host "====================================="
    Write-Host "      PeanutWindows Optimizer"
    Write-Host "====================================="
    Write-Host ""
}

function Pause-Menu {
    Write-Host ""
    Read-Host "Pressione Enter para continuar"
}

function Start-ToolScript {
    param([string]$ScriptName)

    $scriptPath = Join-Path $PSScriptRoot $ScriptName

    if (-not (Test-Path $scriptPath)) {
        Write-Host "Script não encontrado: $scriptPath"
        Pause-Menu
        return
    }

    & $scriptPath
}

function Show-SystemReport {
    Show-Header
    Write-Host "Relatório básico do sistema"
    Write-Host "---------------------------"
    Write-Host "Computador: $env:COMPUTERNAME"
    Write-Host "Usuário: $env:USERNAME"
    Write-Host "Windows: $((Get-CimInstance Win32_OperatingSystem).Caption)"
    Write-Host "Versão: $((Get-CimInstance Win32_OperatingSystem).Version)"
    Write-Host "Arquitetura: $((Get-CimInstance Win32_OperatingSystem).OSArchitecture)"
    Write-Host "Memória RAM total: $([math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)) GB"
    Pause-Menu
}

function Clear-UserTemp {
    Show-Header
    $tempPath = $env:TEMP
    Write-Host "Pasta temporária do usuário: $tempPath"
    $confirm = Read-Host "Deseja limpar arquivos temporários do usuário? (S/N)"

    if ($confirm -match "^[sS]") {
        Get-ChildItem -Path $tempPath -Recurse -Force | Remove-Item -Recurse -Force
        Write-Host "Limpeza concluída. Alguns arquivos em uso podem ter sido ignorados."
    } else {
        Write-Host "Operação cancelada."
    }

    Pause-Menu
}

function Clear-WindowsTemp {
    Show-Header
    $windowsTemp = "C:\Windows\Temp"
    Write-Host "Pasta temporária do Windows: $windowsTemp"
    Write-Host "Recomendado executar o PowerShell como administrador."
    $confirm = Read-Host "Deseja tentar limpar essa pasta? (S/N)"

    if ($confirm -match "^[sS]") {
        Get-ChildItem -Path $windowsTemp -Recurse -Force | Remove-Item -Recurse -Force
        Write-Host "Limpeza concluída. Alguns arquivos protegidos ou em uso podem ter sido ignorados."
    } else {
        Write-Host "Operação cancelada."
    }

    Pause-Menu
}

function Show-Menu {
    do {
        Show-Header
        Write-Host "1 - Ver relatório básico do sistema"
        Write-Host "2 - Limpar Temp do usuário"
        Write-Host "3 - Limpar Temp do Windows"
        Write-Host "4 - Debloater Microsoft"
        Write-Host "5 - Otimizador de jogos por categoria"
        Write-Host "6 - Otimizador exclusivo da Steam"
        Write-Host "7 - Watcher automático de memória para jogos"
        Write-Host "0 - Sair"
        Write-Host ""
        $option = Read-Host "Escolha uma opção"

        switch ($option) {
            "1" { Show-SystemReport }
            "2" { Clear-UserTemp }
            "3" { Clear-WindowsTemp }
            "4" { Start-ToolScript -ScriptName "debloat-microsoft.ps1" }
            "5" { Start-ToolScript -ScriptName "game-optimizer.ps1" }
            "6" { Start-ToolScript -ScriptName "steam-optimizer.ps1" }
            "7" { Start-ToolScript -ScriptName "game-memory-watch.ps1" }
            "0" { Write-Host "Saindo..." }
            default {
                Write-Host "Opção inválida."
                Pause-Menu
            }
        }
    } while ($option -ne "0")
}

Show-Menu
