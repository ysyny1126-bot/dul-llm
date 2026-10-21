@echo off
chcp 65001 > nul
rem 둘 AI 서버 + 시연판 실행 (Windows). 처음 한 번은 .env.example 을 .env 로 복사해서 키를 채우세요.
cd /d "%~dp0"
if not exist .env (copy .env.example .env > nul & echo .env 파일을 만들었어요. 설정을 확인한 뒤 다시 실행하세요. & notepad .env & exit /b 1)
rem AI 서버 전용 Python 환경 (.venv). PC에 Python이 여러 개 있어도 항상 같은 것을 씀 (3.10~3.13 권장)
if not exist .venv\Scripts\python.exe (python -m venv .venv || (echo Python을 찾지 못했어요. python.org 에서 Python 3.12를 설치하세요. & pause & exit /b 1))
.venv\Scripts\python.exe -m pip install -q -r requirements.txt
pushd ..\src
..\server\.venv\Scripts\python.exe build_app.py
popd
echo.
echo 브라우저에서 http://localhost:8000 을 여세요. (가상 회원 user001~user500 / 비밀번호 1234)
.venv\Scripts\python.exe -m uvicorn main:app --port 8000
