@echo off
chcp 65001 > nul
rem 자동 시작 등록을 지우고, 켜져 있는 AI 서버(8000번 포트)를 끔
powershell -NoProfile -Command "Remove-Item ([Environment]::GetFolderPath('Startup') + '\dul-ai-server.lnk') -ErrorAction SilentlyContinue; Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }"
echo 자동 시작을 끄고 AI 서버를 멈췄어요. (Ollama는 그대로 켜져 있어요)
pause
