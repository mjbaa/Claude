#!/bin/bash
ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

FILE=$(cat | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -z "$FILE" ] && exit 0

case "$FILE" in */stage/stage.json) exit 0 ;; esac

# 활성 stage 탐색 — 중첩 티켓 지원 (docs/wf 하위 깊이 무관)
# 편집 파일이 docs/wf 하위면, 그 파일에서 가장 가까운 상위 티켓의 stage 를 우선 사용한다
STAGE=""
ABS="$FILE"; case "$ABS" in /*) ;; *) ABS="$ROOT/$ABS" ;; esac
case "$ABS" in
  "$ROOT"/docs/wf/*)
    DIR=$(dirname "$ABS")
    while [ "$DIR" != "$ROOT/docs/wf" ] && [ "$DIR" != "/" ]; do
      if [ -f "$DIR/stage/stage.json" ]; then STAGE="$DIR/stage/stage.json"; break; fi
      DIR=$(dirname "$DIR")
    done
    ;;
esac
[ -n "$STAGE" ] || STAGE=$(find "$ROOT/docs/wf" -type f -path "*/stage/stage.json" -exec ls -t {} + 2>/dev/null | head -1)
[ -n "$STAGE" ] && [ -f "$STAGE" ] || exit 0

ALLOWED=$(sed -n '/"allow"/,/]/p' "$STAGE" | grep -o '"[^"]*\.[a-zA-Z]*"' | tr -d '"')
[ -z "$ALLOWED" ] && exit 0

if [ -n "$(find "$STAGE" -mmin +240 2>/dev/null)" ]; then
  echo "경고: stage.json이 4시간 이상 오래되어 무시합니다. 필요하면 삭제하십시오: $STAGE" >&2
  exit 0
fi

while IFS= read -r a; do
  [ -z "$a" ] && continue
  case "$FILE" in *"$a") exit 0 ;; esac
done <<< "$ALLOWED"

echo "$(date -Iseconds) BLOCK $FILE" >> "$(dirname "$STAGE")/events.log"

cat >&2 <<MSG
[계약 위반 차단] $FILE

design.md 의 변경 지점에 없는 파일입니다.
build 스킬 3번 이탈 처리를 따르십시오:

1. 이 수정이 왜 필요한지 사용자에게 보고하고 판단을 기다린다
2. 승인되면 design.md 를 먼저 갱신한다
3. stage.json 의 allow 에 경로를 추가한 뒤 재시도한다

사용자 승인 없이 allow 를 수정하는 것은 명백한 실패입니다.

기준 stage: $STAGE
현재 허용:
$ALLOWED
MSG
exit 2