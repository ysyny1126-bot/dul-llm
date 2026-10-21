@echo off
chcp 65001 > nul
rem 둘 끄기: 켜져 있는 AI 서버(8000번 포트)를 멈춰요. 자동 시작 설정과 Ollama는 그대로 둬요.
powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }"
echo AI 서버를 멈췄어요. 다시 쓰려면 '둘 실행'을 누르세요.
ping -n 4 127.0.0.1 > nul
