@echo off
chcp 65001 > nul
rem 둘 AI 서버만 실행 (자동 시작용, 설치 단계 없음). 기록은 ai_server.log
cd /d "%~dp0"
if not exist .env (echo .env 파일이 없어요. .env.example 을 복사해서 만드세요. > ai_server.log & exit /b 1)
if not exist .venv\Scripts\python.exe (echo .venv가 없어요. run_ai.bat 을 먼저 한 번 실행하세요. > ai_server.log & exit /b 1)
rem 화면 코드가 바뀌었을 수 있으니 시연판을 다시 만듦
pushd ..\src
..\server\.venv\Scripts\python.exe build_app.py > nul 2>&1
popd
.venv\Scripts\python.exe -m uvicorn main:app --port 8000 > ai_server.log 2>&1
