# clipwatch_tray.ps1 - Aplicativo de bandeja do sistema para controle do ClipWatch
# Permite ligar/desligar monitoramento de clipboard visualmente e via atalhos.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$logFile = "$env:USERPROFILE\.gemini\clipwatch.log"
$signalFile = "$env:TEMP\clipwatch_toggle.signal"
$PicturesDir = "C:\Users\samue\Pictures\Agy_Clipboard"

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

# Inicializar ícones pré-gerados para evitar vazamento de recursos e redraws custosos
$script:activeIcon = Get-StatusIcon -active $true
$script:inactiveIcon = Get-StatusIcon -active $false

# Atualização de estado visual e logs
function Update-TrayState {
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
}

# Toggle de ativação
function Toggle-ClipWatchState {
    $script:isActive = -not $script:isActive
    Update-TrayState
    
    $title = "ClipWatch Status"
    $msg = if ($script:isActive) { "ATIVADO`nPrints copiados serão salvos e convertidos para Markdown!" } else { "DESATIVADO`nÁrea de transferência voltou ao comportamento padrão." }
    $iconType = if ($script:isActive) { [System.Windows.Forms.ToolTipIcon]::Info } else { [System.Windows.Forms.ToolTipIcon]::Warning }
    
    $notifyIcon.ShowBalloonTip(2000, $title, $msg, $iconType)
}

# Fechamento limpo do App
function Exit-ClipWatch {
    $timer.Stop()
    $notifyIcon.Visible = $false
    $notifyIcon.Dispose()
    
    # Limpar ícones carregados
    if ($script:activeIcon) { $script:activeIcon.Dispose() }
    if ($script:inactiveIcon) { $script:inactiveIcon.Dispose() }
    
    "ClipWatch tray app finalizado em $(Get-Date)" | Out-File $logFile -Append
    [System.Windows.Forms.Application]::Exit()
    exit
}

# Criar o NotifyIcon
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Visible = $true

# Tratar clique com o botão esquerdo para fazer toggle rápido
$notifyIcon.add_MouseClick({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        Toggle-ClipWatchState
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

# Mensagem inicial informando que iniciou
$notifyIcon.ShowBalloonTip(2500, "ClipWatch Iniciado", "Rodando na bandeja do sistema.`n- Clique esquerdo: Liga/Desliga`n- Clique direito: Menu de opções", [System.Windows.Forms.ToolTipIcon]::Info)

# Timer integrado para monitorar tanto os sinais externos quanto o clipboard
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 300
$timer.add_Tick({
    # 1. Checar se o script de toggle disparou um sinal
    if (Test-Path $signalFile) {
        try {
            Remove-Item $signalFile -Force -ErrorAction SilentlyContinue
            Toggle-ClipWatchState
        } catch {}
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
            # Evitar travar caso o clipboard esteja ocupado
        }
    }
})

$timer.Start()

# Iniciar Loop de Mensagens WinForms
[System.Windows.Forms.Application]::Run()
