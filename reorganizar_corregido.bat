@echo off
cd /d %~dp0

REM Crear carpetas si no existen
mkdir "HTB\Very Easy"

REM Mover archivos .md
move *.md "HTB\Very Easy\" >nul

REM Mover carpeta de imágenes si existe
IF EXIST img (
    move img "HTB\Very Easy\" >nul
)

REM Reemplazar rutas en los .md usando PowerShell con expresiones válidas
for %%f in ("HTB\Very Easy\*.md") do (
    powershell -Command "$c = Get-Content '%%f'; $c = $c -replace '\!\[\[', '![]\(./img/'; $c = $c -replace '\!\[\]\(\.\./img/', '![]\(./img/'; $c | Set-Content '%%f'"
)

REM Preguntar por el mensaje del commit
set /p commitMsg="Escribe el mensaje del commit: "

REM Git add, commit y push
git add .
git commit -m "%commitMsg%"
git push origin main

pause
