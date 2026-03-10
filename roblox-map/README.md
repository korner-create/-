# 판타지 숲 배틀 맵 (Fantasy Forest Battle Map)

자연/판타지 테마의 로블록스 배틀 맵입니다.

## 맵 특징

- **테마**: 마법의 숲 — 고대 나무, 빛나는 수정, 신비로운 유적
- **장르**: PvP 배틀 (팀전 or 개인전)
- **플레이어 수**: 2~16명
- **맵 크기**: 200 x 200 스터드

## 맵 구성

```
판타지 숲 배틀 맵
├── 중앙 — 마법 수정 광장 (중립 지역, 아이템 스폰)
├── 북쪽 — 고대 엘프 유적 (팀 A 진영)
├── 남쪽 — 버려진 드워프 요새 (팀 B 진영)
├── 동쪽 — 신비로운 호수 지역 (엄폐물 풍부)
└── 서쪽 — 마법 버섯 숲 (점프 패드, 이동 루트)
```

## 파일 구조

```
src/
├── ServerScriptService/
│   ├── GameManager.server.lua      # 게임 전체 관리
│   ├── RoundManager.server.lua     # 라운드 시스템
│   └── ItemSpawner.server.lua      # 아이템 스폰 관리
├── StarterPlayerScripts/
│   └── PlayerController.client.lua # 플레이어 UI, 조작
├── ReplicatedStorage/
│   ├── MapConfig.lua               # 맵 설정값
│   └── GameEvents.lua              # RemoteEvent 정의
└── Workspace/
    └── MapBuilder.server.lua       # 맵 지형/오브젝트 생성
```

## Roblox Studio 적용 방법

1. Roblox Studio에서 새 프로젝트 열기
2. **Model** 탭 → **Script** 삽입
3. 각 `.lua` 파일을 해당 서비스에 복사
4. `MapBuilder`를 실행해 맵 생성 확인
5. Play 버튼으로 테스트
