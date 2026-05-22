# clipwatch_tray.ps1 - Aplicativo de bandeja do sistema para controle do ClipWatch
# Permite ligar/desligar monitoramento de clipboard visualmente e via atalhos.
# Usa Mutex global do sistema para alternância ultrarrápida e instância única.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$logFile = "$env:USERPROFILE\.gemini\clipwatch.log"
$signalFile = "$env:TEMP\clipwatch_toggle.signal"
$PicturesDir = "C:\Users\samue\Pictures\Agy_Clipboard"

# 1. Validar instância única usando System Mutex
$mutexName = "Local\ClipWatchTrayMutex"
$createdNew = $false
$script:mutex = New-Object System.Threading.Mutex($true, $mutexName, [ref]$createdNew)

if (-not $createdNew) {
    # Já existe uma instância rodando. Envia o sinalizador de toggle e sai imediatamente.
    "Another instance detected. Sending toggle signal at $(Get-Date)" | Out-File $logFile -Append
    New-Item -ItemType File -Path $signalFile -Force | Out-Null
    exit
}

# Garantir que a pasta de fotos existe
if (-not (Test-Path $PicturesDir)) {
    New-Item -ItemType Directory -Path $PicturesDir -Force | Out-Null
}

$script:isActive = $true

# Função para desenhar o ícone de status dinamicamente em memória
function Get-StatusIcon ($active) {
    try {
        $bmp = New-Object System.Drawing.Bitmap 16, 16
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        
        # Cor de fundo baseada no status: Verde vibrante vs Vermelho vibrante
        $outerColor = if ($active) { [System.Drawing.Color]::FromArgb(46, 204, 113) } else { [System.Drawing.Color]::FromArgb(231, 76, 60) }
        $outerBrush = New-Object System.Drawing.SolidBrush $outerColor
        $g.FillEllipse($outerBrush, 1, 1, 14, 14)
        
        # Círculo interno branco (corpo da lente)
        $innerBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
        $g.FillEllipse($innerBrush, 4, 4, 8, 8)
        
        # Centro da lente
        $centerColor = if ($active) { [System.Drawing.Color]::FromArgb(39, 174, 96) } else { [System.Drawing.Color]::FromArgb(192, 57, 43) }
        $centerBrush = New-Object System.Drawing.SolidBrush $centerColor
        $g.FillEllipse($centerBrush, 6, 6, 4, 4)
        
        $hIcon = $bmp.GetHicon()
        $icon = [System.Drawing.Icon]::FromHandle($hIcon)
        
        # Descartar recursos unmanaged de forma segura
        $outerBrush.Dispose()
        $innerBrush.Dispose()
        $centerBrush.Dispose()
        $g.Dispose()
        $bmp.Dispose()
        
        return $icon
    } catch {
        # Fallback para ícone padrão do sistema caso ocorra erro gráfico
        return [System.Drawing.SystemIcons]::Information
    }
}

# Inicializar ícones pré-gerados
$script:activeIcon = Get-StatusIcon -active $true
$script:inactiveIcon = Get-StatusIcon -active $false

# Atualização de estado visual e logs
function Update-TrayState {
    try {
        if ($script:isActive) {
            $notifyIcon.Icon = $script:activeIcon
            $notifyIcon.Text = "ClipWatch: ATIVADO (Prints -> Markdown)"
            $menuItemToggle.Text = "Desativar Monitoramento"
            "ClipWatch ativado no tray em $(Get-Date)" | Out-File $logFile -Append
        } else {
            $notifyIcon.Icon = $script:inactiveIcon
            $notifyIcon.Text = "ClipWatch: DESATIVADO (Clipboard normal)"
            $menuItemToggle.Text = "Ativar Monitoramento"
            "ClipWatch desativado no tray em $(Get-Date)" | Out-File $logFile -Append
        }
    } catch {
        "[$(Get-Date)] Error in Update-TrayState: $_" | Out-File $logFile -Append
    }
}

# Toggle de ativação protegido por try/catch
function Toggle-ClipWatchState {
    try {
        $script:isActive = -not $script:isActive
        Update-TrayState
        
        $title = "ClipWatch Status"
        $msg = if ($script:isActive) { "ATIVADO`nPrints copiados serão salvos e convertidos para Markdown!" } else { "DESATIVADO`nÁrea de transferência voltou ao comportamento padrão." }
        $iconType = if ($script:isActive) { [System.Windows.Forms.ToolTipIcon]::Info } else { [System.Windows.Forms.ToolTipIcon]::Warning }
        
        $notifyIcon.ShowBalloonTip(2000, $title, $msg, $iconType)
    } catch {
        "[$(Get-Date)] Error in Toggle-ClipWatchState: $_" | Out-File $logFile -Append
    }
}

# Fechamento limpo do App
function Exit-ClipWatch {
    try {
        $timer.Stop()
        $notifyIcon.Visible = $false
        $notifyIcon.Dispose()
        
        # Limpar ícones carregados
        if ($script:activeIcon) { $script:activeIcon.Dispose() }
        if ($script:inactiveIcon) { $script:inactiveIcon.Dispose() }
        
        # Liberar e fechar Mutex explicitamente
        if ($script:mutex) {
            $script:mutex.ReleaseMutex()
            $script:mutex.Dispose()
        }
    } catch {}
    
    "ClipWatch tray app finalizado em $(Get-Date)" | Out-File $logFile -Append
    [System.Windows.Forms.Application]::Exit()
    exit
}

# Criar o NotifyIcon
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Visible = $true

# Tratar clique com o botão esquerdo do mouse de forma segura
$notifyIcon.add_MouseClick({
    param($sender, $e)
    try {
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
            Toggle-ClipWatchState
        }
    } catch {
        "[$(Get-Date)] Error in MouseClick handler: $_" | Out-File $logFile -Append
    }
})

# Criar Menu de Contexto
$contextMenu = New-Object System.Windows.Forms.ContextMenu
$menuItemToggle = New-Object System.Windows.Forms.MenuItem("Desativar Monitoramento", { Toggle-ClipWatchState })
$menuItemSep = New-Object System.Windows.Forms.MenuItem("-")
$menuItemExit = New-Object System.Windows.Forms.MenuItem("Sair", { Exit-ClipWatch })
$contextMenu.MenuItems.AddRange(@($menuItemToggle, $menuItemSep, $menuItemExit))
$notifyIcon.ContextMenu = $contextMenu

Update-TrayState

# Mensagem inicial informando que iniciou (protegida por try/catch)
try {
    $notifyIcon.ShowBalloonTip(2500, "ClipWatch Iniciado", "Rodando na bandeja do sistema.`n- Clique esquerdo: Liga/Desliga`n- Clique direito: Menu de opções", [System.Windows.Forms.ToolTipIcon]::Info)
} catch {}

# Timer integrado para monitorar tanto os sinais externos quanto o clipboard
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 300
$timer.add_Tick({
    # 1. Checar se o script de toggle disparou um sinal
    if (Test-Path $signalFile) {
        try {
            Remove-Item $signalFile -Force -ErrorAction SilentlyContinue
            Toggle-ClipWatchState
        } catch {
            "[$(Get-Date)] Error resolving toggle signal file: $_" | Out-File $logFile -Append
        }
    }
    
    # 2. Monitorar clipboard se ativo
    if ($script:isActive) {
        try {
            if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                $filename = "clip_$timestamp.png"
                $fullPath = Join-Path $PicturesDir $filename
                
                $img = [System.Windows.Forms.Clipboard]::GetImage()
                if ($img -ne $null) {
                    $img.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
                    $img.Dispose()
                    
                    $fileUri = "file:///" + $fullPath.Replace("\", "/")
                    $mdLink = "![image]($fileUri)"
                    
                    [System.Windows.Forms.Clipboard]::SetText($mdLink)
                    "[$timestamp] Print auto-convertido para: $mdLink" | Out-File $logFile -Append
                }
            }
        } catch {
            # Evitar travar caso o clipboard esteja temporariamente ocupado
        }
    }
})

$timer.Start()

# Iniciar Loop de Mensagens WinForms
[System.Windows.Forms.Application]::Run()
