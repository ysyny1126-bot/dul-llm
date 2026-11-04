#!/bin/bash
# 둘 배포: GitHub main에 올리고, 두 사이트의 gh-pages에 public/을 그대로 올려요.
#   https://ysyny1126-bot.github.io/dul-llm/   https://ysyny1126-bot.github.io/dul/
# 실행: ./publish.sh   (public/은 먼저 만들어 두세요: cd src && python3 build_deploy.py ..)
set -e
ROOT=$(git rev-parse --show-toplevel); cd "$ROOT"
MSG=$(git log -1 --format='%h %s')
git push -q origin HEAD:main
# 바탕화면 원래 폴더(시연 시작 .command가 쓰는 곳)도 같은 버전으로
SHA=$(git rev-parse HEAD); MAIN=$(git worktree list --porcelain | awk '/^worktree /{print substr($0,10); exit}')
if [ "$MAIN" != "$ROOT" ] && [ "$(git -C "$MAIN" rev-parse --abbrev-ref HEAD)" = main ]; then git -C "$MAIN" merge -q --ff-only "$SHA" && echo "원래 폴더: 최신으로 맞췄어요"; fi
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
for REPO in ysyny1126-bot/dul-llm ysyny1126-bot/dul; do
  DIR="$TMP/${REPO#*/}"
  git clone -q --depth 1 -b gh-pages "https://github.com/$REPO.git" "$DIR"
  cp -R public/. "$DIR"/
  git -C "$DIR" add -A
  if git -C "$DIR" diff --cached --quiet; then echo "$REPO: 바뀐 것 없음"; continue; fi
  git -C "$DIR" commit -q -m "배포: $MSG"
  git -C "$DIR" push -q origin gh-pages
  echo "$REPO: 배포했어요"
done
