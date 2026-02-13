# YouTube Planner — 코너(korner) 채널

리얼리티 시트콤 브이로그 촬영 기획안을 작성하는 스킬입니다.
4개의 에이전트가 협업하여 **상황 설계 중심**의 기획안을 만들고, 피드백을 학습합니다.

> 스크립트를 쓰지 않습니다. 여러 명이 출연하는 리얼리티 포맷이므로, 대사가 아니라 상황/미션/규칙을 설계합니다.

## 에이전트 구성

1. **Style Analyzer** (`agents/style-analyzer.md`): 채널 스타일 분석 (상황 패턴, 출연진 케미, 편집 스타일 등)
2. **Content Planner** (`agents/content-planner.md`): 촬영 기획안 작성 (상황 설계, 출연진 캐스팅, 촬영 계획)
3. **Content Reviewer** (`agents/content-reviewer.md`): 기획안 검토 (채널 핏, 상황 퀄리티, 실행 가능성 채점)
4. **Style Learner** (`agents/style-learner.md`): 피드백 학습 (촬영 후 피드백 포함)

## 데이터 경로

- 스타일 가이드: `skills/youtube-planner/data/style-guide.md`
- 피드백 로그: `skills/youtube-planner/data/feedback-log.md`
- 샘플 콘텐츠: `skills/youtube-planner/data/samples/`
- 승인된 기획안: `skills/youtube-planner/data/approved-plans/`
- 스타일 변경 이력: `skills/youtube-planner/data/style-history/`

## 워크플로우

### 초기 설정 (최초 1회)
1. 사용자가 기존 영상 정보(제목, 조회수, 기획 메모 등)를 `data/samples/`에 넣습니다.
2. **Style Analyzer**가 샘플을 분석하여 `data/style-guide.md`를 생성합니다.
3. 또는 사용자가 직접 채널 스타일을 설명하면 그 내용으로 가이드를 초기화합니다.

### 기획안 작성
1. 사용자가 주제나 방향을 제시합니다.
2. **Content Planner**가 스타일 가이드와 피드백 로그를 참조하여 촬영 기획안을 작성합니다.
   - 상황 설계, 출연진 캐스팅, 촬영 계획, 편집 방향, 제목/썸네일까지
3. **Content Reviewer**가 기획안을 검토합니다.
   - 80점 이상: 사용자에게 전달
   - 80점 미만: Content Planner에게 수정 지시 (최대 3회 반복)
4. 사용자에게 최종 기획안을 보여줍니다.

### 피드백 & 학습
5. 사용자가 피드백을 줍니다.
6. **Style Learner**가 피드백을 해석하여 시스템 업데이트
7. 승인 시 → 기획안 저장 + 스타일 재분석
8. 촬영 후 → "이거 찍었는데 반응 좋았어/별로였어" 피드백도 학습

### 루프
다음 기획안 작성 시, 업데이트된 스타일 가이드와 피드백 로그가 자동으로 반영됩니다.

## 호출 예시

```
기획 써줘: 멤버들 몰래 집에 CCTV 설치하고 반응 보기
```

```
기획 써줘: 멤버 한 명씩 1일 PD 시키기
```

```
기획 아이디어만 5개 뽑아줘
```
