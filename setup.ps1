# setup.ps1 - Instalador do Ambiente Gravidade (Antigravity CLI)
# Executa a vinculação do plugin e configuração dos dotfiles.

$ErrorActionPreference = "Stop"

$RepoDir = $PSScriptRoot
$PluginsDestDir = "$env:USERPROFILE\.gemini\config\plugins"
$PluginTarget = Join-Path $PluginsDestDir "gravidade-plugin"
$PluginSource = Join-Path $RepoDir "plugins\gravidade-plugin"

Write-Host "=== Iniciando Setup do Gravidade (Antigravity CLI) ===" -ForegroundColor Cyan

# 1. Validar estrutura
if (-not (Test-Path $PluginSource)) {
    Write-Error "Pasta fonte do plugin nao encontrada em: $PluginSource"
}

# 2. Criar pasta de plugins global do Antigravity se nao existir
if (-not (Test-Path $PluginsDestDir)) {
    Write-Host "Criando pasta de plugins do Antigravity..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $PluginsDestDir -Force | Out-Null
}

# 3. Remover link ou pasta existente no destino
if (Test-Path $PluginTarget) {
    Write-Host "Removendo link/pasta antiga do plugin..." -ForegroundColor Yellow
    # Se for uma pasta ou link, remove de forma segura
    if ((Get-Item $PluginTarget).Attributes -match "ReparsePoint") {
        [System.IO.Directory]::Delete($PluginTarget)
    } else {
        Remove-Item -Path $PluginTarget -Recurse -Force
    }
}

# 4. Criar junção (Junction Link)
Write-Host "Vinculando plugin no diretorio do Antigravity..." -ForegroundColor Yellow
New-Item -ItemType Junction -Path $PluginTarget -Value $PluginSource | Out-Null
Write-Host "Plugin gravidade-plugin vinculado com sucesso!" -ForegroundColor Green

# 5. Configurar PowerShell Profile
$ProfilePath = $PROFILE
$ProfileDir = Split-Path $ProfilePath -Parent

if (-not (Test-Path $ProfileDir)) {
    Write-Host "Criando diretorio do perfil do PowerShell..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

if (-not (Test-Path $ProfilePath)) {
    Write-Host "Criando novo arquivo de perfil do PowerShell..." -ForegroundColor Yellow
    New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
}

# Ler perfil atual
$ProfileContent = Get-Content -Path $ProfilePath -Raw
if ($null -eq $ProfileContent) { $ProfileContent = "" }

# Bloco de injeção
$InjectStart = "# === BEGIN GRAVIDADE CONFIG ==="
$InjectEnd = "# === END GRAVIDADE CONFIG ==="
$PowerShellProfileSource = Join-Path $RepoDir "dotfiles\powershell\Microsoft.PowerShell_profile.ps1"
$InjectBody = @"
$InjectStart
if (Test-Path "$PowerShellProfileSource") {
    . "$PowerShellProfileSource"
}
$InjectEnd
"@

# Verificar se já existe a injeção e substituir, ou adicionar ao final
if ($ProfileContent -match "(?s)$[regex]::Escape($InjectStart).*?$[regex]::Escape($InjectEnd)") {
    Write-Host "Atualizando configuracoes existentes no PowerShell Profile..." -ForegroundColor Yellow
    $Pattern = "(?s)" + [regex]::Escape($InjectStart) + ".*?" + [regex]::Escape($InjectEnd)
    $ProfileContent = [regex]::Replace($ProfileContent, $Pattern, $InjectBody)
} else {
    Write-Host "Adicionando configuracoes ao PowerShell Profile..." -ForegroundColor Yellow
    if ($ProfileContent -and -not $ProfileContent.EndsWith("`n")) {
        $ProfileContent += "`r`n"
    }
    $ProfileContent += $InjectBody + "`r`n"
}

# Salvar perfil
Set-Content -Path $ProfilePath -Value $ProfileContent -Force
Write-Host "PowerShell Profile atualizado com sucesso!" -ForegroundColor Green

# 6. Copiar Starship config para a pasta padrão se o usuário desejar
$StarshipSource = Join-Path $RepoDir "dotfiles\starship\starship.toml"
$StarshipDestDir = "$env:USERPROFILE\.config"
$StarshipDestFile = Join-Path $StarshipDestDir "starship.toml"

if (-not (Test-Path $StarshipDestDir)) {
    New-Item -ItemType Directory -Path $StarshipDestDir -Force | Out-Null
}

# Copiar se não existir ou se for diferente
if (Test-Path $StarshipSource) {
    Copy-Item -Path $StarshipSource -Destination $StarshipDestFile -Force
    Write-Host "Configuracao do Starship copiada para: $StarshipDestFile" -ForegroundColor Green
}

# 7. Criar atalho do Toggle ClipWatch no Desktop
Write-Host "Criando atalho de Toggle ClipWatch no Desktop..." -ForegroundColor Yellow
try {
    $WshShell = New-Object -ComObject WScript.Shell
    $DesktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
    $Shortcut = $WshShell.CreateShortcut((Join-Path $DesktopPath "Toggle ClipWatch.lnk"))
    $Shortcut.TargetPath = "powershell.exe"
    $ToggleScript = Join-Path $RepoDir "dotfiles\clipwatch\toggle_clipwatch.ps1"
    $Shortcut.Arguments = "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$ToggleScript`""
    $Shortcut.IconLocation = "imageres.dll,80" # Ícone de câmera
    $Shortcut.Save()
    Write-Host "Atalho 'Toggle ClipWatch' criado na Area de Trabalho!" -ForegroundColor Green
} catch {
    Write-Warning "Nao foi possivel criar o atalho no Desktop: $_"
}

Write-Host ""
Write-Host "=== Setup concluido! Reabra o terminal para aplicar as mudancas. ===" -ForegroundColor Green
Write-Host "Para rodar o Antigravity com bypass de permissoes, use o comando:" -ForegroundColor Cyan
Write-Host "  by pass permissions on" -ForegroundColor Green
Write-Host ""
