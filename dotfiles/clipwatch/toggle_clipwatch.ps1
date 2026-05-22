# toggle_clipwatch.ps1 - Script para alternar o estado do ClipWatch
# Invoca a bandeja silenciosamente. O controle de ativação/desativação e
# instância única é tratado internamente pelo Mutex do clipwatch_tray.ps1.

$TrayScript = "D:\projetos D\Gravidade Github\dotfiles\clipwatch\clipwatch_tray.ps1"
$logFile = "$env:USERPROFILE\.gemini\clipwatch.log"

if (-not (Test-Path $TrayScript)) {
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.Popup("Erro: clipwatch_tray.ps1 nao encontrado!`nCaminho: $TrayScript", 5, "ClipWatch Erro", 16) | Out-Null
    exit
}

# Inicia o app da bandeja (se já estiver rodando, a nova instância enviará o sinal de toggle e fechará de forma síncrona)
"Triggering ClipWatch execution at $(Get-Date)" | Out-File $logFile -Append
Start-Process powershell -ArgumentList "-WindowStyle", "Hidden", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$TrayScript`"" -WindowStyle Hidden
