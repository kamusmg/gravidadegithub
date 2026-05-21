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

# Função para iniciar o agy no modo interativo normal
function agy-interactive {
    agy -i @args
}

# Função de bypass de permissões (Bypass Permissions On)
function by-pass-permissions-on {
    Write-Host "Iniciando Antigravity CLI com bypass de permissões habilitado..." -ForegroundColor Cyan
    agy --dangerously-skip-permissions @args
}

function bypass-permissions {
    by-pass-permissions-on @args
}

${function:by pass permissions on} = {
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
