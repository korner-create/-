-- GameEvents.lua
-- RemoteEvent / RemoteFunction 정의 및 초기화

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameEvents = {}

-- 이벤트 이름 목록
local EVENT_NAMES = {
    "RoundStarted",      -- 라운드 시작 (클라이언트에 알림)
    "RoundEnded",        -- 라운드 종료 (승리 팀 정보 포함)
    "PlayerDied",        -- 플레이어 사망
    "PlayerRespawned",   -- 플레이어 리스폰
    "ItemSpawned",       -- 아이템 스폰 위치 동기화
    "ItemPickedUp",      -- 아이템 획득
    "DamageDealt",       -- 데미지 발생 (히트 이펙트)
    "UpdateScoreboard",  -- 점수판 갱신
    "TeamAssigned",      -- 팀 배정
}

local FUNCTION_NAMES = {
    "GetGameState",  -- 현재 게임 상태 조회
}

-- 폴더 생성 (없을 경우)
local function getOrCreateFolder(name)
    local folder = ReplicatedStorage:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = ReplicatedStorage
    end
    return folder
end

-- RemoteEvent 초기화
function GameEvents.init()
    local eventsFolder = getOrCreateFolder("GameEvents")
    local functionsFolder = getOrCreateFolder("GameFunctions")

    for _, name in ipairs(EVENT_NAMES) do
        if not eventsFolder:FindFirstChild(name) then
            local event = Instance.new("RemoteEvent")
            event.Name = name
            event.Parent = eventsFolder
        end
    end

    for _, name in ipairs(FUNCTION_NAMES) do
        if not functionsFolder:FindFirstChild(name) then
            local func = Instance.new("RemoteFunction")
            func.Name = name
            func.Parent = functionsFolder
        end
    end
end

-- 이벤트 가져오기
function GameEvents.getEvent(name)
    return ReplicatedStorage.GameEvents:FindFirstChild(name)
end

function GameEvents.getFunction(name)
    return ReplicatedStorage.GameFunctions:FindFirstChild(name)
end

return GameEvents
