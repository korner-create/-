-- MapConfig.lua
-- 판타지 숲 배틀 맵 설정값

local MapConfig = {}

-- 맵 기본 정보
MapConfig.MAP_NAME = "판타지 숲 배틀 맵"
MapConfig.MAP_SIZE = Vector3.new(200, 50, 200)
MapConfig.MAP_CENTER = Vector3.new(0, 0, 0)

-- 게임 설정
MapConfig.MAX_PLAYERS = 16
MapConfig.MIN_PLAYERS = 2
MapConfig.ROUND_TIME = 300        -- 5분 (초)
MapConfig.INTERMISSION_TIME = 15  -- 대기 시간 (초)
MapConfig.RESPAWN_TIME = 5        -- 리스폰 대기 시간 (초)

-- 팀 스폰 위치
MapConfig.SPAWN_LOCATIONS = {
    TeamA = {
        center = Vector3.new(0, 5, -80),   -- 북쪽 엘프 유적
        radius = 15,
        count = 8,
    },
    TeamB = {
        center = Vector3.new(0, 5, 80),    -- 남쪽 드워프 요새
        radius = 15,
        count = 8,
    },
}

-- 아이템 스폰 포인트
MapConfig.ITEM_SPAWN_POINTS = {
    -- 중앙 마법 수정 광장
    Vector3.new(0, 3, 0),
    Vector3.new(10, 3, 0),
    Vector3.new(-10, 3, 0),
    Vector3.new(0, 3, 10),
    Vector3.new(0, 3, -10),
    -- 동쪽 호수
    Vector3.new(60, 3, 10),
    Vector3.new(70, 3, -10),
    -- 서쪽 버섯 숲
    Vector3.new(-60, 3, 10),
    Vector3.new(-70, 3, -10),
}

-- 아이템 종류 및 스폰 가중치
MapConfig.ITEMS = {
    { name = "HealthPotion",   weight = 40, healAmount = 50  },
    { name = "MagicSword",     weight = 20, damage = 30      },
    { name = "ShieldOrb",      weight = 20, defense = 20     },
    { name = "SpeedBoost",     weight = 15, duration = 10    },
    { name = "MagicBomb",      weight = 5,  damage = 80, radius = 15 },
}

-- 맵 지역 설정
MapConfig.ZONES = {
    Center = {
        name = "마법 수정 광장",
        position = Vector3.new(0, 0, 0),
        size = Vector3.new(40, 10, 40),
        isNeutral = true,
    },
    NorthBase = {
        name = "고대 엘프 유적",
        position = Vector3.new(0, 0, -80),
        size = Vector3.new(50, 10, 40),
        team = "TeamA",
    },
    SouthBase = {
        name = "버려진 드워프 요새",
        position = Vector3.new(0, 0, 80),
        size = Vector3.new(50, 10, 40),
        team = "TeamB",
    },
    EastLake = {
        name = "신비로운 호수",
        position = Vector3.new(70, 0, 0),
        size = Vector3.new(60, 5, 60),
        isNeutral = true,
    },
    WestForest = {
        name = "마법 버섯 숲",
        position = Vector3.new(-70, 0, 0),
        size = Vector3.new(60, 10, 60),
        isNeutral = true,
    },
}

-- 색상 테마 (판타지)
MapConfig.COLORS = {
    Ground      = Color3.fromRGB(34, 85, 34),    -- 짙은 녹색
    Stone       = Color3.fromRGB(120, 110, 95),  -- 회갈색
    MagicCrystal = Color3.fromRGB(100, 50, 200), -- 보라색 수정
    Water       = Color3.fromRGB(30, 100, 180),  -- 파란 호수
    Mushroom    = Color3.fromRGB(200, 80, 80),   -- 붉은 버섯
    TeamA_Color = Color3.fromRGB(50, 150, 255),  -- 파란 팀
    TeamB_Color = Color3.fromRGB(255, 80, 80),   -- 빨간 팀
}

return MapConfig
