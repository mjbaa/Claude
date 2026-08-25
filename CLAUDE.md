## 개발 워크플로우

에러 분석 · 요구사항 분석 · 기능 명세 · 설계 · 구현 · 검증 작업은 반드시 스킬로 시작한다.

    /analyze-incident   에러 · 장애
    /analyze-spec       요구사항 · 기획
    /spec               기능 명세 (선택 — 분업·타 파트 계약이 필요할 때)
    /design             설계 확정
    /build              구현 · 검증 (verify.md까지 생성)

두 경로 모두 유효하다:
    analyze → design → build
    analyze → spec → design → build (spec이 있으면 design은 구조 선택을 승계한다)

검증은 /build 에 통합되어 있다 (scope-auditor·verifier 병렬 위임).
별도 /verify 스킬은 없다.

tracer / historian / explorer / critic / side-effect / scope-auditor / verifier / conventions 를 직접 호출하지 않는다.
이들은 스킬이 호출하는 서브에이전트다.
직접 부르면 사용자 승인 게이트와 산출물 생성이 모두 건너뛰어진다.

사용자가 에이전트 이름을 언급해도 해당 스킬로 진입한다.

## 빌드

mvn이 PATH에 없다. IntelliJ 번들 Maven을 사용한다:
"/Applications/IntelliJ IDEA.app/Contents/plugins/maven/lib/maven3/bin/mvn"

## 워크플로우 상태 해제

docs/wf/{ID}/stage/stage.json 이 남아 편집이 막히면 삭제한다.
