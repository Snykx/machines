@echo off
cd /d %~dp0

REM Crear carpetas si no existen
mkdir "HTB\Very Easy"

REM Mover archivos .md
move *.md "HTB\Very Easy\"

REM Mover carpeta de imágenes
move img "HTB\Very Easy\"

REM Reemplazar rutas en los .md (usa PowerShell para reemplazos)
for %%f in ("HTB\Very Easy\*.md") do (
    powershell -Command "(Get-Content \"%%f\") -replace '!\\[\\[', '![](./img/' | Set-Content \"%%f\""
    powershell -Command "(Get-Content \"%%f\") -replace '!\\[]\\(../img/', '![](./img/' | Set-Content \"%%f\""
)

REM Git add, commit y push
git add .
git commit -m "Reorganización automática desde script Windows"
git push origin main

pause