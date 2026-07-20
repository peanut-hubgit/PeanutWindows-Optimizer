<#
PeanutWindows Optimizer - Microsoft App Debloater

Objetivo:
- Mostrar uma lista de apps Microsoft geralmente dispensáveis.
- Permitir escolher exatamente o que remover.
- Criar backup em JSON antes de remover.
- Permitir restauração pelo próprio script quando possível.

Notas importantes:
- Este script prioriza remoção para o usuário atual, não destruição do sistema.
- Edge e Copilot podem variar conforme versão do Windows.
- Edge é integrado ao Windows; a remoção pode falhar ou ser revertida por atualização.
- Reversibilidade não é magia: se a Microsoft mudar pacote/loja/winget, talvez seja necessário reinstalar manualmente.
#>

$ErrorActionPreference = "SilentlyContinue"

$AppName = "PeanutWindows Optimizer"
$BackupRoot = Join-Path $PSScriptRoot "..\backups"
$BackupFile = Join-Path $BackupRoot "debloat-backup.json"

function Show-Header {
    Clear-Host
    Write-Host "=============================================="
    Write-Host "   PeanutWindows Optimizer - Microsoft Debloat"
    Write-Host "=============================================="
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

function Ensure-BackupFolder {
    if (-not (Test-Path $BackupRoot)) {
        New-Item -Path $BackupRoot -ItemType Directory -Force | Out-Null
    }
}

function Test-Winget {
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    return $null -ne $winget
}

function Get-DebloatCatalog {
    return @(
        [PSCustomObject]@{
            Id = 1
            Name = "Microsoft Copilot"
            Type = "Appx"
            AppxNames = @("Microsoft.Copilot", "Microsoft.Windows.Ai.Copilot.Provider")
            WingetId = "Microsoft.Copilot"
            Risk = "Baixo/Médio"
            Notes = "Assistente de IA da Microsoft. Pode voltar em atualizações do Windows."
        },
        [PSCustomObject]@{
            Id = 2
            Name = "Microsoft Clipchamp"
            Type = "Appx"
            AppxNames = @("Clipchamp.Clipchamp")
            WingetId = "Clipchamp.Clipchamp"
            Risk = "Baixo"
            Notes = "Editor de vídeo. Removível para a maioria dos usuários."
        },
        [PSCustomObject]@{
            Id = 3
            Name = "Microsoft News"
            Type = "Appx"
            AppxNames = @("Microsoft.BingNews")
            WingetId = "9WZDNCRFHVFW"
            Risk = "Baixo"
            Notes = "App de notícias. Geralmente dispensável."
        },
        [PSCustomObject]@{
            Id = 4
            Name = "Microsoft Weather"
            Type = "Appx"
            AppxNames = @("Microsoft.BingWeather")
            WingetId = "9WZDNCRFJ3Q2F"
            Risk = "Baixo"
            Notes = "App de clima. Pode ser reinstalado pela Store."
        },
        [PSCustomObject]@{
            Id = 5
            Name = "Get Help"
            Type = "Appx"
            AppxNames = @("Microsoft.GetHelp")
            WingetId = "9PKDZBMV1H3T"
            Risk = "Baixo"
            Notes = "App de ajuda da Microsoft."
        },
        [PSCustomObject]@{
            Id = 6
            Name = "Tips / Introdução"
            Type = "Appx"
            AppxNames = @("Microsoft.Getstarted")
            WingetId = "9WZDNCRDTBJJ"
            Risk = "Baixo"
            Notes = "Dicas e introdução do Windows."
        },
        [PSCustomObject]@{
            Id = 7
            Name = "Microsoft Solitaire Collection"
            Type = "Appx"
            AppxNames = @("Microsoft.MicrosoftSolitaireCollection")
            WingetId = "9WZDNCRFHWD2"
            Risk = "Baixo"
            Notes = "Joguinho clássico, mas não essencial."
        },
        [PSCustomObject]@{
            Id = 8
            Name = "Microsoft People"
            Type = "Appx"
            AppxNames = @("Microsoft.People")
            WingetId = "9NBLGGH10PG8"
            Risk = "Baixo"
            Notes = "Contatos/Pessoas. Pouca gente usa hoje."
        },
        [PSCustomObject]@{
            Id = 9
            Name = "Movies & TV"
            Type = "Appx"
            AppxNames = @("Microsoft.ZuneVideo")
            WingetId = "9WZDNCRFJ3P2"
            Risk = "Baixo"
            Notes = "App Filmes e TV."
        },
        [PSCustomObject]@{
            Id = 10
            Name = "Media Player / Groove Music"
            Type = "Appx"
            AppxNames = @("Microsoft.ZuneMusic")
            WingetId = "9WZDNCRFJ3PT"
            Risk = "Baixo"
            Notes = "Player de música/vídeo da Microsoft."
        },
        [PSCustomObject]@{
            Id = 11
            Name = "Xbox Apps"
            Type = "Appx"
            AppxNames = @(
                "Microsoft.XboxApp",
                "Microsoft.GamingApp",
                "Microsoft.XboxGamingOverlay",
                "Microsoft.XboxGameOverlay",
                "Microsoft.Xbox.TCUI",
                "Microsoft.XboxIdentityProvider",
                "Microsoft.XboxSpeechToTextOverlay"
            )
            WingetId = "9MV0B5HZVK9Z"
            Risk = "Médio"
            Notes = "Remova só se você não usa Xbox/Game Pass/Game Bar."
        },
        [PSCustomObject]@{
            Id = 12
            Name = "Microsoft Teams Personal"
            Type = "Appx"
            AppxNames = @("MSTeams", "MicrosoftTeams")
            WingetId = "Microsoft.Teams"
            Risk = "Baixo/Médio"
            Notes = "Teams pessoal. Não recomendado remover se você usa Teams."
        },
        [PSCustomObject]@{
            Id = 13
            Name = "Power Automate"
            Type = "Appx"
            AppxNames = @("Microsoft.PowerAutomateDesktop")
            WingetId = "Microsoft.PowerAutomateDesktop"
            Risk = "Baixo"
            Notes = "Automação para Windows. Útil para poucos usuários."
        },
        [PSCustomObject]@{
            Id = 14
            Name = "Microsoft To Do"
            Type = "Appx"
            AppxNames = @("Microsoft.Todos")
            WingetId = "9NBLGGH5R558"
            Risk = "Baixo"
            Notes = "Lista de tarefas da Microsoft."
        },
        [PSCustomObject]@{
            Id = 15
            Name = "Microsoft Edge"
            Type = "Winget"
            AppxNames = @()
            WingetId = "Microsoft.Edge"
            Risk = "Alto"
            Notes = "Integrado ao Windows. A remoção pode falhar, quebrar atalhos/web links ou voltar em updates."
        }
    )
}

function Get-InstalledTargets {
    param([array]$Catalog)

    $installed = @()

    foreach ($item in $Catalog) {
        $packages = @()

        foreach ($appxName in $item.AppxNames) {
            $packages += Get-AppxPackage -Name $appxName -ErrorAction SilentlyContinue
        }

        $wingetInstalled = $false
        if ((Test-Winget) -and $item.WingetId) {
            $wingetOutput = winget list --id $item.WingetId --exact 2>$null
            if ($LASTEXITCODE -eq 0 -and ($wingetOutput -match [regex]::Escape($item.WingetId))) {
                $wingetInstalled = $true
            }
        }

        if ($packages.Count -gt 0 -or $wingetInstalled) {
            $installed += [PSCustomObject]@{
                Id = $item.Id
                Name = $item.Name
                Type = $item.Type
                AppxNames = $item.AppxNames
                WingetId = $item.WingetId
                Risk = $item.Risk
                Notes = $item.Notes
                Packages = $packages | Select-Object Name, PackageFullName, PackageFamilyName, InstallLocation
                WingetDetected = $wingetInstalled
            }
        }
    }

    return $installed
}

function Save-Backup {
    param([array]$Selected)

    Ensure-BackupFolder

    $backup = [PSCustomObject]@{
        CreatedAt = (Get-Date).ToString("s")
        ComputerName = $env:COMPUTERNAME
        UserName = $env:USERNAME
        Script = "debloat-microsoft.ps1"
        SelectedApps = $Selected
    }

    $backup | ConvertTo-Json -Depth 10 | Set-Content -Path $BackupFile -Encoding UTF8
    Write-Host "Backup salvo em: $BackupFile"
}

function Show-InstalledApps {
    Show-Header
    $catalog = Get-DebloatCatalog
    $installed = Get-InstalledTargets -Catalog $catalog

    if ($installed.Count -eq 0) {
        Write-Host "Nenhum app do catálogo foi encontrado instalado para este usuário."
        Pause-Menu
        return
    }

    Write-Host "Apps encontrados:"
    Write-Host ""
    foreach ($app in $installed) {
        Write-Host "[$($app.Id)] $($app.Name) | Risco: $($app.Risk)"
        Write-Host "     $($app.Notes)"
    }

    Pause-Menu
}

function Select-Apps {
    $catalog = Get-DebloatCatalog
    $installed = Get-InstalledTargets -Catalog $catalog

    if ($installed.Count -eq 0) {
        Write-Host "Nenhum app removível do catálogo foi encontrado."
        return @()
    }

    Write-Host "Apps disponíveis para remoção:"
    Write-Host ""
    foreach ($app in $installed) {
        Write-Host "[$($app.Id)] $($app.Name) | Risco: $($app.Risk)"
        Write-Host "     $($app.Notes)"
    }

    Write-Host ""
    Write-Host "Digite os números separados por vírgula. Exemplo: 1,2,7"
    Write-Host "Digite A para selecionar todos de risco Baixo/Baixo-Médio."
    Write-Host "Digite 0 para cancelar."
    Write-Host ""

    $choice = Read-Host "Sua escolha"

    if ($choice -eq "0") { return @() }

    if ($choice -match "^[aA]$") {
        return @($installed | Where-Object { $_.Risk -in @("Baixo", "Baixo/Médio") })
    }

    $ids = $choice -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^\d+$" } | ForEach-Object { [int]$_ }
    return @($installed | Where-Object { $ids -contains $_.Id })
}

function Remove-AppxTarget {
    param($App)

    foreach ($package in $App.Packages) {
        Write-Host "Removendo Appx: $($package.PackageFullName)"
        Remove-AppxPackage -Package $package.PackageFullName -ErrorAction SilentlyContinue
    }
}

function Remove-WingetTarget {
    param($App)

    if (-not (Test-Winget)) {
        Write-Host "winget não encontrado. Não foi possível remover via winget: $($App.Name)"
        return
    }

    if ([string]::IsNullOrWhiteSpace($App.WingetId)) {
        Write-Host "Sem WingetId para: $($App.Name)"
        return
    }

    Write-Host "Tentando remover via winget: $($App.Name) ($($App.WingetId))"
    winget uninstall --id $App.WingetId --exact --silent --accept-source-agreements
}

function Start-Debloat {
    Show-Header

    if (-not (Test-Admin)) {
        Write-Host "Aviso: execute como administrador para melhores resultados."
        Write-Host "Algumas remoções podem falhar sem permissão elevada."
        Write-Host ""
    }

    $selected = Select-Apps

    if ($selected.Count -eq 0) {
        Write-Host "Nenhum app selecionado. Operação cancelada."
        Pause-Menu
        return
    }

    Write-Host ""
    Write-Host "Selecionados para remoção:"
    foreach ($app in $selected) {
        Write-Host "- $($app.Name) | Risco: $($app.Risk)"
    }

    Write-Host ""
    Write-Host "O script criará backup antes de remover."
    $confirm = Read-Host "Confirmar remoção? (S/N)"

    if ($confirm -notmatch "^[sS]") {
        Write-Host "Operação cancelada."
        Pause-Menu
        return
    }

    Save-Backup -Selected $selected

    foreach ($app in $selected) {
        Write-Host ""
        Write-Host "Processando: $($app.Name)"

        if ($app.Packages.Count -gt 0) {
            Remove-AppxTarget -App $app
        }

        if ($app.Type -eq "Winget" -or ($app.WingetDetected -and $app.Packages.Count -eq 0)) {
            Remove-WingetTarget -App $app
        }
    }

    Write-Host ""
    Write-Host "Remoção finalizada. Reinicie o PC se algum app continuar aparecendo."
    Pause-Menu
}

function Restore-AppxPackageFromBackup {
    param($Package)

    if ($Package.InstallLocation -and (Test-Path (Join-Path $Package.InstallLocation "AppxManifest.xml"))) {
        $manifest = Join-Path $Package.InstallLocation "AppxManifest.xml"
        Write-Host "Restaurando Appx via manifesto: $($Package.Name)"
        Add-AppxPackage -DisableDevelopmentMode -Register $manifest -ErrorAction SilentlyContinue
        return $true
    }

    return $false
}

function Restore-WithWinget {
    param($App)

    if (-not (Test-Winget)) {
        Write-Host "winget não encontrado. Não foi possível restaurar via winget: $($App.Name)"
        return
    }

    if ([string]::IsNullOrWhiteSpace($App.WingetId)) {
        Write-Host "Sem WingetId para restaurar: $($App.Name)"
        return
    }

    Write-Host "Tentando restaurar via winget: $($App.Name) ($($App.WingetId))"
    winget install --id $App.WingetId --exact --silent --accept-package-agreements --accept-source-agreements
}

function Start-Restore {
    Show-Header

    if (-not (Test-Path $BackupFile)) {
        Write-Host "Nenhum backup encontrado em: $BackupFile"
        Pause-Menu
        return
    }

    $backup = Get-Content -Path $BackupFile -Raw | ConvertFrom-Json

    Write-Host "Backup encontrado:"
    Write-Host "Data: $($backup.CreatedAt)"
    Write-Host "PC: $($backup.ComputerName)"
    Write-Host "Usuário: $($backup.UserName)"
    Write-Host ""
    Write-Host "Apps no backup:"

    foreach ($app in $backup.SelectedApps) {
        Write-Host "- $($app.Name)"
    }

    Write-Host ""
    $confirm = Read-Host "Deseja tentar restaurar os apps do backup? (S/N)"

    if ($confirm -notmatch "^[sS]") {
        Write-Host "Restauração cancelada."
        Pause-Menu
        return
    }

    foreach ($app in $backup.SelectedApps) {
        Write-Host ""
        Write-Host "Restaurando: $($app.Name)"

        $restoredByManifest = $false

        foreach ($package in $app.Packages) {
            if (Restore-AppxPackageFromBackup -Package $package) {
                $restoredByManifest = $true
            }
        }

        if (-not $restoredByManifest) {
            Restore-WithWinget -App $app
        }
    }

    Write-Host ""
    Write-Host "Restauração finalizada. Alguns apps podem exigir reinício ou instalação manual pela Microsoft Store."
    Pause-Menu
}

function Show-BackupInfo {
    Show-Header

    if (-not (Test-Path $BackupFile)) {
        Write-Host "Nenhum backup encontrado."
        Pause-Menu
        return
    }

    $backup = Get-Content -Path $BackupFile -Raw | ConvertFrom-Json
    Write-Host "Backup: $BackupFile"
    Write-Host "Criado em: $($backup.CreatedAt)"
    Write-Host "Computador: $($backup.ComputerName)"
    Write-Host "Usuário: $($backup.UserName)"
    Write-Host ""
    Write-Host "Apps salvos:"
    foreach ($app in $backup.SelectedApps) {
        Write-Host "- $($app.Name)"
    }

    Pause-Menu
}

function Show-Menu {
    do {
        Show-Header
        Write-Host "1 - Ver apps Microsoft dispensáveis encontrados"
        Write-Host "2 - Escolher apps e desinstalar"
        Write-Host "3 - Restaurar apps usando backup"
        Write-Host "4 - Ver informações do backup"
        Write-Host "0 - Sair"
        Write-Host ""
        $option = Read-Host "Escolha uma opção"

        switch ($option) {
            "1" { Show-InstalledApps }
            "2" { Start-Debloat }
            "3" { Start-Restore }
            "4" { Show-BackupInfo }
            "0" { Write-Host "Saindo..." }
            default {
                Write-Host "Opção inválida."
                Pause-Menu
            }
        }
    } while ($option -ne "0")
}

Show-Menu
