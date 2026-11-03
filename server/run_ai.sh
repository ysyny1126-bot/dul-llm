#!/usr/bin/env bash
# 둘 AI 서버 + 시연판 실행 (Mac / Linux). 처음 한 번은 .env.example 을 .env 로 복사해서 키를 채우세요.
set -e
cd "$(dirname "$0")"
[ -f .env ] || { cp .env.example .env; echo ".env 파일을 만들었어요. 키를 채운 뒤 다시 실행하세요."; exit 1; }
# Mac 전용 가상환경 .venv-mac (server/.venv는 Windows용이라 같이 못 씀). 처음 한 번만 만들고 패키지 설치
[ -x .venv-mac/bin/python ] || python3 -m venv .venv-mac
PY=.venv-mac/bin/python
"$PY" -m pip install -q --upgrade pip
"$PY" -m pip install -q -r requirements.txt
(cd ../src && python3 build_app.py)
# 무료 로컬 AI(Ollama)를 쓰면 Ollama가 켜져 있는지 확인
if grep -q '^LLM_BACKEND=ollama' .env && ! curl -s -m 2 http://localhost:11434/api/tags >/dev/null; then
  echo "Ollama가 꺼져 있어요. 응용 프로그램에서 Ollama를 켠 뒤 다시 실행하세요."; exit 1
fi
echo "브라우저에서 http://localhost:8000 을 여세요. (가상 회원 user001~user500 / 비밀번호 1234)"
"$PY" -m uvicorn main:app --port 8000
