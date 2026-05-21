# PowerShell Profile - Configuração de ferramentas de desenvolvimento (Gravidade)
# Gerado automaticamente e adaptado para Antigravity CLI

# ========================================
# Mise-en-place (gerenciador de versões)
# ========================================
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
}

# ========================================
# Starship (prompt customizado)
# ========================================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# ========================================
# Zoxide (smart cd)
# ========================================
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ========================================
# FZF (fuzzy finder)
# ========================================
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"
}

# ========================================
# Aliases úteis (com tratamento de erro para AllScope)
# ========================================
function Set-SafeAlias {
    param([string]$Name, [string]$Value)
    try {
        Set-Alias -Name $Name -Value $Value -Force -ErrorAction SilentlyContinue
    } catch {}
}

Set-SafeAlias g git
Set-SafeAlias k kubectl
Set-SafeAlias h helm
Set-SafeAlias d docker

# Alias para xh (http client)
if (Get-Command xh -ErrorAction SilentlyContinue) {
    Set-SafeAlias http xh
}

# ========================================
# Funções de Atalho para Antigravity (agy)
# ========================================

# Interceptador para agy (permite usar 'agy bp', 'agy yolo', 'agy by pass permissions on' e comandos normais)
function agy {
    $isBypass = $false
    $skipCount = 0
    
    if ($args.Count -ge 1 -and ($args[0] -eq "bp" -or $args[0] -eq "yolo")) {
        $isBypass = $true
        $skipCount = 1
    } elseif ($args.Count -ge 4 -and $args[0] -eq "by" -and $args[1] -eq "pass" -and ($args[2] -eq "permissions" -or $args[2] -eq "permission") -and $args[3] -eq "on") {
        $isBypass = $true
        $skipCount = 4
    }
    
    if ($isBypass) {
        $remainingArgs = $args[$skipCount..($args.Count - 1)]
        Write-Host "Iniciando Antigravity CLI com bypass de permissões habilitado..." -ForegroundColor Cyan
        
        $realAgy = Get-Command agy.exe -ErrorAction SilentlyContinue | Where-Object { $_.CommandType -eq 'Application' } | Select-Object -First 1 -ExpandProperty Definition
        if (-not $realAgy) { $realAgy = "agy.exe" }
        
        & $realAgy --dangerously-skip-permissions $remainingArgs
    } else {
        $realAgy = Get-Command agy.exe -ErrorAction SilentlyContinue | Where-Object { $_.CommandType -eq 'Application' } | Select-Object -First 1 -ExpandProperty Definition
        if (-not $realAgy) { $realAgy = "agy.exe" }
        
        & $realAgy @args
    }
}

# Função para iniciar o agy no modo interativo normal
function agy-interactive {
    agy -i @args
}

# Função de bypass de permissões (Bypass Permissions On)
function by-pass-permissions-on {
    Write-Host "Iniciando Antigravity CLI com bypass de permissões habilitado..." -ForegroundColor Cyan
    $realAgy = Get-Command agy.exe -ErrorAction SilentlyContinue | Where-Object { $_.CommandType -eq 'Application' } | Select-Object -First 1 -ExpandProperty Definition
    if (-not $realAgy) { $realAgy = "agy.exe" }
    & $realAgy --dangerously-skip-permissions @args
}

function bypass-permissions {
    by-pass-permissions-on @args
}

${function:by pass permissions on} = {
    by-pass-permissions-on @args
}

# Atalhos extremamente curtos e diretos para o terminal
function bp {
    by-pass-permissions-on @args
}

function yolo {
    by-pass-permissions-on @args
}


# Tratamento para digitação sequencial de 'by pass permissions on' no PowerShell
function by {
    param(
        [Parameter(Position=0)]
        [string]$p1,
        [Parameter(Position=1)]
        [string]$p2,
        [Parameter(Position=2)]
        [string]$p3
    )
    if ($p1 -eq "pass" -and ($p2 -eq "permissions" -or $p2 -eq "permission") -and $p3 -eq "on") {
        by-pass-permissions-on @args
    } else {
        # Fallback caso o usuário use 'by' para outra coisa
        if ($p1) {
            Write-Host "Comando desconhecido: 'by $p1 $p2 $p3'. Para iniciar com bypass de permissões, use:" -ForegroundColor Yellow
            Write-Host "  by pass permissions on" -ForegroundColor Green
        } else {
            Write-Host "Para iniciar com bypass de permissões, use:" -ForegroundColor Yellow
            Write-Host "  by pass permissions on" -ForegroundColor Green
        }
    }
}

# ========================================
# Funções úteis gerais
# ========================================

# Listar todos os aliases
function aliases { Get-Alias | Format-Table -AutoSize }

# Git status rápido
function gs { git status }

# Git log bonito
function gl { git log --oneline --graph --decorate -20 }

# Docker ps formatado
function dps { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }

# ========================================
# Atalho Alt+v para colar imagem do Clipboard como Markdown Link
# ========================================
if (Get-Command Set-PSReadLineKeyHandler -ErrorAction SilentlyContinue) {
    Set-PSReadLineKeyHandler -Key "Alt+v" -ScriptBlock {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
        Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
        try {
            if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
                $dir = "C:\Users\samue\Pictures\Agy_Clipboard"
                if (-not (Test-Path $dir)) {
                    New-Item -ItemType Directory -Path $dir -Force | Out-Null
                }
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                $filename = "clip_$timestamp.png"
                $fullPath = Join-Path $dir $filename
                
                $img = [System.Windows.Forms.Clipboard]::GetImage()
                $img.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
                $img.Dispose()
                
                $fileUri = "file:///" + $fullPath.Replace("\", "/")
                $mdLink = "![image]($fileUri)"
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($mdLink)
            }
        } catch {
            # Falhar silenciosamente para não interromper a digitação
        }
    }
}

# ========================================
# Monitor de Clipboard (clipwatch) para usar dentro do agy
# ========================================
function Start-ClipWatch {
    Write-Host "=== Monitor de Clipboard Ativo ===" -ForegroundColor Green
    Write-Host "Copie qualquer imagem (ex: Win+Shift+S) e ela será convertida em link Markdown." -ForegroundColor Cyan
    Write-Host "Em seguida, basta usar Ctrl+V para colar no chat do agy!" -ForegroundColor Cyan
    Write-Host "Pressione Ctrl+C para encerrar este monitor." -ForegroundColor Yellow
    Write-Host "==================================" -ForegroundColor Green
    
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
    
    while ($true) {
        try {
            if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
                $dir = "C:\Users\samue\Pictures\Agy_Clipboard"
                if (-not (Test-Path $dir)) {
                    New-Item -ItemType Directory -Path $dir -Force | Out-Null
                }
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                $filename = "clip_$timestamp.png"
                $fullPath = Join-Path $dir $filename
                
                $img = [System.Windows.Forms.Clipboard]::GetImage()
                $img.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
                $img.Dispose()
                
                $fileUri = "file:///" + $fullPath.Replace("\", "/")
                $mdLink = "![image]($fileUri)"
                
                [System.Windows.Forms.Clipboard]::SetText($mdLink)
                Write-Host "[+] Imagem convertida em link Markdown: $mdLink" -ForegroundColor Green
            }
        } catch {
            # Ignorar erros temporários de acesso ao clipboard
        }
        Start-Sleep -Milliseconds 500
    }
}

Set-SafeAlias clipwatch Start-ClipWatch
Set-SafeAlias start-print Start-ClipWatch
Set-SafeAlias print Start-ClipWatch


