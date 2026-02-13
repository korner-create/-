# YouTube Planner Agent System

유튜브 영상 기획을 도와주는 멀티 에이전트 시스템입니다.

## 프로젝트 구조

```
.claude/
  agents/
    style-analyzer.md     # 스타일 분석
    content-planner.md    # 기획안 작성
    content-reviewer.md   # 기획안 검토
    style-learner.md      # 피드백 학습
  skills/
    youtube-planner/
      SKILL.md            # 스킬 정의
      data/
        style-guide.md    # 스타일 가이드 (자동 업데이트)
        feedback-log.md   # 피드백 로그 (자동 업데이트)
        samples/          # 기존 콘텐츠 샘플
        approved-plans/   # 승인된 기획안
        style-history/    # 스타일 가이드 변경 이력
```

## 사용법

### 기획안 작성
```
유튜브 기획 써줘: [주제]
```

### 스타일 분석 (초기 설정 또는 재분석)
```
스타일 분석해줘
```

### 피드백
기획안을 받은 후 자유롭게 피드백하면 됩니다:
- "이 제목이 더 좋아"
- "도입부가 너무 길어"
- "이건 내 스타일 아니야"
- "승인" (최종 확정)

## 에이전트 워크플로우

1. Content Planner가 스타일 가이드를 참조하여 기획안 작성
2. Content Reviewer가 기획안 검토 (80점 미만 시 수정 요청, 최대 3회)
3. 사용자에게 기획안 전달
4. 사용자 피드백 → Style Learner가 스타일 가이드 업데이트
5. 승인 시 → approved-plans에 저장, Style Analyzer가 스타일 가이드 재분석

피드백이 쌓일수록 기획 품질이 올라갑니다.
