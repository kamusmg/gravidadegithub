$DaemonScript = "D:\projetos D\Gravidade Github\dotfiles\clipwatch\clipwatch_daemon.ps1"
$logFile = "$env:USERPROFILE\.gemini\clipwatch.log"

# Search for the running process
$proc = Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" | Where-Object { $_.CommandLine -like "*clipwatch_daemon.ps1*" }

$wshell = New-Object -ComObject Wscript.Shell

if ($proc) {
    # It is running, kill it
    $proc | ForEach-Object {
        try {
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        } catch {}
    }
    "Clipwatch daemon stopped at $(Get-Date)" | Out-File $logFile -Append
    $wshell.Popup("ClipWatch DESATIVADO!`n(Seu clipboard voltou ao normal)", 2, "ClipWatch Status", 48) | Out-Null
} else {
    # It is not running, start it
    if (-not (Test-Path $DaemonScript)) {
        $wshell.Popup("Erro: clipwatch_daemon.ps1 nao encontrado!", 5, "ClipWatch Erro", 16) | Out-Null
        exit
    }
    Start-Process powershell -ArgumentList "-WindowStyle", "Hidden", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $DaemonScript -WindowStyle Hidden
    "Clipwatch daemon triggered toggle start at $(Get-Date)" | Out-File $logFile -Append
    $wshell.Popup("ClipWatch ATIVADO!`n(Prints serao convertidos para Markdown)", 2, "ClipWatch Status", 64) | Out-Null
}
