Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$dir = "C:\Users\samue\Pictures\Agy_Clipboard"
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$logFile = "$env:USERPROFILE\.gemini\clipwatch.log"
"Clipwatch daemon started at $(Get-Date)" | Out-File $logFile

while ($true) {
    try {
        if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $filename = "clip_$timestamp.png"
            $fullPath = Join-Path $dir $filename
            
            $img = [System.Windows.Forms.Clipboard]::GetImage()
            $img.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
            $img.Dispose()
            
            $fileUri = "file:///" + $fullPath.Replace("\", "/")
            $mdLink = "![image]($fileUri)"
            
            # Set clipboard text
            [System.Windows.Forms.Clipboard]::SetText($mdLink)
            "[$timestamp] Saved image and set clipboard to $mdLink" | Out-File $logFile -Append
        }
    } catch {
        "[$($timestamp)] Error: $_" | Out-File $logFile -Append
    }
    Start-Sleep -Milliseconds 500
}
