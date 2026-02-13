# YouTube Planner

유튜브 영상 기획안을 작성하는 스킬입니다. 4개의 에이전트가 협업하여 기획안을 만들고, 피드백을 학습합니다.

## 에이전트 구성

1. **Style Analyzer** (`agents/style-analyzer.md`): 스타일 가이드 생성 및 업데이트
2. **Content Planner** (`agents/content-planner.md`): 기획안 작성
3. **Content Reviewer** (`agents/content-reviewer.md`): 기획안 검토 및 채점
4. **Style Learner** (`agents/style-learner.md`): 피드백 학습 및 시스템 업데이트

## 데이터 경로

- 스타일 가이드: `skills/youtube-planner/data/style-guide.md`
- 피드백 로그: `skills/youtube-planner/data/feedback-log.md`
- 샘플 콘텐츠: `skills/youtube-planner/data/samples/`
- 승인된 기획안: `skills/youtube-planner/data/approved-plans/`
- 스타일 변경 이력: `skills/youtube-planner/data/style-history/`

## 워크플로우

### 초기 설정 (최초 1회)
1. 사용자가 기존 유튜브 콘텐츠(기획안, 스크립트, 영상 정보 등)를 `data/samples/`에 넣습니다.
2. **Style Analyzer**가 샘플을 분석하여 `data/style-guide.md`를 생성합니다.

### 기획안 작성
1. 사용자가 주제를 제시합니다. (예: "유튜브 기획 써줘: AI 도구 추천")
2. **Content Planner**가 `data/style-guide.md`와 `data/feedback-log.md`를 참조하여 기획안을 작성합니다.
3. **Content Reviewer**가 기획안을 검토합니다.
   - 80점 이상: 사용자에게 전달
   - 80점 미만: Content Planner에게 수정 지시 (최대 3회 반복)
4. 사용자에게 최종 기획안을 보여줍니다.

### 피드백 & 학습
5. 사용자가 피드백을 줍니다. ("이 부분 바꿔줘", "이건 좋아", "승인")
6. **Style Learner**가 피드백을 해석하여:
   - `data/feedback-log.md`에 기록
   - `data/style-guide.md` 업데이트
7. 승인 시:
   - 기획안을 `data/approved-plans/`에 저장
   - **Style Analyzer**가 승인된 기획안을 포함하여 스타일 가이드 재분석

### 루프
다음 기획안 작성 시, 업데이트된 스타일 가이드와 피드백 로그가 자동으로 반영됩니다.

## 호출 예시

```
유튜브 기획 써줘: [주제]
```

```
유튜브 기획 써줘: 직장인 퇴근 후 루틴 브이로그
```
