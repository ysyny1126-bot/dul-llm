#!/bin/bash
# 둘 시연: 더블클릭하면 AI 서버 + 핸드폰 공유 링크(QR)를 한 번에 켜요.
# 이 창을 닫거나 Ctrl+C를 누르면 서버와 공유 링크가 모두 꺼져요.
cd "$(dirname "$0")/server" || exit 1
CF="$HOME/.dul-bin/cloudflared"            # Cloudflare 임시 터널 (계정 없이 https 공유 링크)
PY=.venv-mac/bin/python
LOG="${TMPDIR:-/tmp}/dul-demo"; mkdir -p "$LOG"
fail() { echo; echo "⚠️  $1"; echo "아무 키나 누르면 창을 닫아요."; read -r -n 1; exit 1; }
clear; echo "♥ 둘 시연 준비 중이에요. 1분쯤 걸려요..."

# 1. 실행 환경 (처음 한 번만 오래 걸림)
[ -f .env ] || cp .env.example .env
[ -x "$PY" ] || python3 -m venv .venv-mac || fail "Python 실행 환경을 만들지 못했어요."
"$PY" -m pip install -q -r requirements.txt 2>/dev/null || fail "패키지를 설치하지 못했어요. 인터넷 연결을 확인하세요."

# 2. Ollama 켜고 AI 모델을 미리 올려 두기 (첫 질문이 늦지 않게)
if grep -q '^LLM_BACKEND=ollama' .env; then
  if ! curl -s -m 2 localhost:11434/api/tags >/dev/null; then
    echo "· Ollama 켜는 중"; open -a Ollama
    for i in $(seq 1 30); do sleep 1; curl -s -m 1 localhost:11434/api/tags >/dev/null && break; done
  fi
  curl -s -m 2 localhost:11434/api/tags >/dev/null || fail "Ollama가 안 켜져요. 응용 프로그램에서 Ollama를 직접 켠 뒤 다시 실행하세요."
  MODEL=$(grep '^OLLAMA_MODEL=' .env | cut -d= -f2-); MODEL=${MODEL:-qwen2.5:7b}
  echo "· AI 모델($MODEL) 미리 올리는 중"
  curl -s -m 180 localhost:11434/api/generate -d "{\"model\":\"$MODEL\",\"prompt\":\"\",\"keep_alive\":\"2h\"}" >/dev/null
fi

# 3. 시연판 만들고 AI 서버 켜기 (8000번에 켜져 있던 서버는 끄고 새로)
(cd ../src && python3 build_app.py >/dev/null) || fail "시연판을 만들지 못했어요."
OLD=$(lsof -ti tcp:8000 -sTCP:LISTEN); [ -n "$OLD" ] && { kill $OLD; sleep 1; }   # 8000번을 '듣고 있는' 서버만 (브라우저 등 접속한 쪽은 건드리지 않음)
"$PY" -m uvicorn main:app --host 127.0.0.1 --port 8000 > "$LOG/server.log" 2>&1 & SRV=$!
for i in $(seq 1 30); do curl -s -m 1 localhost:8000/api/health >/dev/null && break; sleep 0.5; done
curl -s -m 2 localhost:8000/api/health >/dev/null || fail "AI 서버가 안 켜져요. 기록: $LOG/server.log"

# 4. 시연하는 동안 맥이 잠들지 않게
caffeinate -dimsu & CAF=$!
cleanup() { kill $SRV $TUN $CAF 2>/dev/null; echo; echo "시연을 껐어요."; }
trap cleanup EXIT INT TERM HUP

# 5. 핸드폰 공유 링크
URL=""
if [ -x "$CF" ]; then
  echo "· 공유 링크 만드는 중"
  "$CF" tunnel --no-autoupdate --url http://localhost:8000 > "$LOG/tunnel.log" 2>&1 & TUN=$!
  for i in $(seq 1 60); do URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$LOG/tunnel.log" | head -1); [ -n "$URL" ] && break; sleep 0.5; done
  # 새 주소가 인터넷에 퍼질 때까지 잠깐 기다림
  [ -n "$URL" ] && for i in $(seq 1 30); do curl -s -m 3 "$URL/api/health" | grep -q '"ok"' && break; sleep 1; done
fi

open "http://localhost:8000"
clear
echo "=================================================="
echo "  ♥ 둘 시연 준비 끝!"
echo "=================================================="
echo "  노트북:  http://localhost:8000"
if [ -n "$URL" ]; then
  printf %s "$URL" | pbcopy
  "$PY" share_page.py "$URL" "$LOG/share.html" >/dev/null && open "$LOG/share.html"
  echo "  핸드폰:  $URL"
  echo "           (복사됐어요 · QR 화면도 열었어요)"
else
  echo "  핸드폰 공유 링크는 못 만들었어요 (인터넷 확인)."
  echo "  노트북 화면으로는 그대로 시연할 수 있어요."
fi
echo
echo "  이 창을 닫거나 Ctrl+C를 누르면 시연이 꺼져요."
echo "=================================================="
wait $SRV
