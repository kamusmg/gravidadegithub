@echo off
REM Antigravity Workspace - Windows Terminal
REM Abre 4 paineis prontos para trabalhar com o Antigravity CLI (agy)

echo Abrindo workspace do Antigravity com 4 paineis...

wt.exe ^
    --title "Antigravity 1" pwsh -NoExit -Command "Write-Host 'Painel 1 - Digite: agy' -ForegroundColor Green" ^
    ; split-pane --horizontal --title "Antigravity 3" pwsh -NoExit -Command "Write-Host 'Painel 3 - Digite: agy' -ForegroundColor Green" ^
    ; move-focus up ^
    ; split-pane --vertical --title "Antigravity 2" pwsh -NoExit -Command "Write-Host 'Painel 2 - Digite: agy' -ForegroundColor Green" ^
    ; move-focus down ^
    ; split-pane --vertical --title "Comandos" pwsh -NoExit -Command "Write-Host 'Painel 4 - Para npm, git, testes, etc.' -ForegroundColor Yellow"

echo.
echo Layout:
echo   [Antigravity 1] | [Antigravity 2]
echo   ---------------------------------
echo   [Antigravity 3] | [Comandos]
echo.
echo Use Alt + Setas para navegar entre os paineis.
