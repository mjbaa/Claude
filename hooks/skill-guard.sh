#!/bin/bash
INPUT=$(cat)

SUB=$(printf '%s' "$INPUT" | sed -n 's/.*"subagent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
case "$SUB" in
  tracer|historian|explorer|critic|side-effect|scope-auditor|verifier) ;;
  *) exit 0 ;;
esac

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
STAGE=$(ls -t "$ROOT"/docs/wf/*/stage/stage.json 2>/dev/null | head -1)
[ -n "$STAGE" ] && exit 0

mkdir -p "$ROOT/docs/wf"
echo "$(date -Iseconds) BYPASS $SUB" >> "$ROOT/docs/wf/events.log"

cat >&2 <<MSG
[스킬 우회 감지] $SUB 를 스킬 없이 호출했습니다.

docs/wf/{ID}/stage/stage.json 이 없습니다. 다음이 건너뛰어진 상태입니다:
- docs/wf/{ID}/ 생성
- 사용자 승인 게이트 (재현 확인, 방식 선택 등)
- 산출물 문서 작성
- 형식 검증

조사 결과는 유효합니다. 아래를 수행하십시오:

1. 사용자에게 작업 ID를 확인한다
2. 해당 스킬의 남은 단계(게이트 + 문서 작성)를 진행한다
3. 서브에이전트를 다시 호출하지 않는다

의도적인 단발 조사였다면 그 사실을 사용자에게 확인하고 넘어간다.
MSG
exit 2