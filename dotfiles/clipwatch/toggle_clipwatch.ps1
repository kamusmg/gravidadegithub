# toggle_clipwatch.ps1 - Script para alternar o estado do ClipWatch
# Detecta se a bandeja já está rodando para enviar sinal, ou a inicia se inativa.

$TrayScript = "D:\projetos D\Gravidade Github\dotfiles\clipwatch\clipwatch_tray.ps1"
$signalFile = "$env:TEMP\clipwatch_toggle.signal"
$logFile = "$env:USERPROFILE\.gemini\clipwatch.log"

# Buscar se o processo do clipwatch_tray já está ativo
$proc = Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" | Where-Object { $_.CommandLine -like "*clipwatch_tray.ps1*" }

if ($proc) {
    # Se já está rodando, cria o arquivo sinalizador para a bandeja alternar
    "Toggle signal triggered by shortcut at $(Get-Date)" | Out-File $logFile -Append
    New-Item -ItemType File -Path $signalFile -Force | Out-Null
} else {
    # Se não está rodando, inicia a bandeja em segundo plano (Hidden)
    if (-not (Test-Path $TrayScript)) {
        $wshell = New-Object -ComObject WScript.Shell
        $wshell.Popup("Erro: clipwatch_tray.ps1 nao encontrado!`nCaminho: $TrayScript", 5, "ClipWatch Erro", 16) | Out-Null
        exit
    }
    
    "Starting ClipWatch Tray App from toggle script at $(Get-Date)" | Out-File $logFile -Append
    Start-Process powershell -ArgumentList "-WindowStyle", "Hidden", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$TrayScript`"" -WindowStyle Hidden
}
