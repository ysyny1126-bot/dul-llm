@echo off
chcp 65001 > nul
rem 둘 실행: Ollama와 AI 서버를 켜고 브라우저로 앱을 열어요. 이미 켜져 있으면 바로 열어요.
title 둘 실행
cd /d "%~dp0server"

rem 처음 한 번: 설정 파일과 AI 서버 전용 Python 환경 준비
if not exist .env copy .env.example .env > nul
if not exist .venv\Scripts\python.exe (
  echo 처음 실행이라 준비하는 중이에요. 1~2분 걸려요...
  python -m venv .venv || (echo Python을 찾지 못했어요. python.org 에서 Python 3.12를 설치하세요. & pause & exit /b 1)
  .venv\Scripts\python.exe -m pip install -q -r requirements.txt
)

rem Ollama (로컬 LLM)가 꺼져 있으면 켜기
curl.exe -s -m 2 http://localhost:11434/api/version > nul 2>&1
if errorlevel 1 if exist "%LOCALAPPDATA%\Programs\Ollama\ollama app.exe" start "" "%LOCALAPPDATA%\Programs\Ollama\ollama app.exe"

rem AI 서버가 꺼져 있으면 창 없이 켜기
curl.exe -s -m 2 http://localhost:8000/api/health > nul 2>&1
if errorlevel 1 wscript.exe "%~dp0server\start_ai_hidden.vbs"

echo 둘을 여는 중이에요...
for /l %%i in (1,1,40) do (
  curl.exe -s -m 2 http://localhost:8000/api/health > nul 2>&1 && goto ready
  ping -n 2 127.0.0.1 > nul
)
echo AI 서버가 켜지지 않았어요. server\ai_server.log 를 확인해주세요.
pause
exit /b 1

:ready
if /i "%~1"=="--check" (echo 준비 완료 & exit /b 0)
start "" http://localhost:8000
