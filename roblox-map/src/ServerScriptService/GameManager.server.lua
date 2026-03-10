-- GameManager.server.lua
-- 게임 전체 상태 관리 (팀 배정, 점수, 게임 흐름)

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapConfig = require(ReplicatedStorage:WaitForChild("MapConfig"))
local GameEvents = require(ReplicatedStorage:WaitForChild("GameEvents"))

GameEvents.init()

-- 팀 생성
local function setupTeams()
    -- 기존 팀 정리
    for _, team in ipairs(Teams:GetTeams()) do
        team:Destroy()
    end

    local teamA = Instance.new("Team")
    teamA.Name = "엘프 팀"
    teamA.TeamColor = BrickColor.new("Bright blue")
    teamA.AutoAssignable = false
    teamA.Parent = Teams

    local teamB = Instance.new("Team")
    teamB.Name = "드워프 팀"
    teamB.TeamColor = BrickColor.new("Bright red")
    teamB.AutoAssignable = false
    teamB.Parent = Teams

    return teamA, teamB
end

-- 게임 상태
local GameState = {
    status = "Waiting",  -- Waiting | InRound | Intermission
    scores = { TeamA = 0, TeamB = 0 },
    killCounts = {},     -- [userId] = kills
    teamAssignments = {}, -- [userId] = "TeamA" | "TeamB"
}

local teamA, teamB = setupTeams()

-- 팀 균등 배정
local function assignTeams()
    local playerList = Players:GetPlayers()
    -- 섞기
    for i = #playerList, 2, -1 do
        local j = math.random(i)
        playerList[i], playerList[j] = playerList[j], playerList[i]
    end

    GameState.teamAssignments = {}
    for i, player in ipairs(playerList) do
        local teamName = (i % 2 == 1) and "TeamA" or "TeamB"
        GameState.teamAssignments[player.UserId] = teamName
        player.Team = (teamName == "TeamA") and teamA or teamB

        GameEvents.getEvent("TeamAssigned"):FireClient(player, teamName)
    end

    print("[GameManager] 팀 배정 완료")
end

-- 플레이어 캐릭터 스폰
local function spawnPlayer(player)
    local teamName = GameState.teamAssignments[player.UserId] or "TeamA"
    local spawnConfig = MapConfig.SPAWN_LOCATIONS[teamName]

    -- 랜덤 스폰 위치
    local angle = math.random() * math.pi * 2
    local radius = math.random() * spawnConfig.radius
    local spawnPos = spawnConfig.center + Vector3.new(
        math.cos(angle) * radius,
        3,
        math.sin(angle) * radius
    )

    player:LoadCharacter()
    task.wait(0.1)

    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(spawnPos)
    end
end

-- 플레이어 사망 처리
local function onCharacterAdded(player, character)
    local humanoid = character:WaitForChild("Humanoid")

    -- 킬 카운트 초기화
    if not GameState.killCounts[player.UserId] then
        GameState.killCounts[player.UserId] = 0
    end

    humanoid.Died:Connect(function()
        if GameState.status ~= "InRound" then return end

        -- 킬 획득자 찾기 (태그 시스템)
        local tag = humanoid:FindFirstChild("KillerTag")
        if tag then
            local killer = Players:GetPlayerByUserId(tag.Value)
            if killer and killer ~= player then
                GameState.killCounts[killer.UserId] = (GameState.killCounts[killer.UserId] or 0) + 1

                -- 팀 점수 업데이트
                local killerTeam = GameState.teamAssignments[killer.UserId]
                if killerTeam then
                    GameState.scores[killerTeam] = GameState.scores[killerTeam] + 1
                end
            end
        end

        GameEvents.getEvent("PlayerDied"):FireAllClients(player.Name, GameState.scores)
        GameEvents.getEvent("UpdateScoreboard"):FireAllClients(GameState.scores, GameState.killCounts)

        -- 리스폰 대기
        task.delay(MapConfig.RESPAWN_TIME, function()
            if player.Parent and GameState.status == "InRound" then
                spawnPlayer(player)
                GameEvents.getEvent("PlayerRespawned"):FireClient(player)
            end
        end)
    end)
end

-- 플레이어 입장 처리
Players.PlayerAdded:Connect(function(player)
    GameState.killCounts[player.UserId] = 0

    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player, character)
    end)

    -- 게임 대기 중이면 바로 배정
    if GameState.status == "Waiting" then
        local playerCount = #Players:GetPlayers()
        if playerCount >= MapConfig.MIN_PLAYERS then
            print("[GameManager] 최소 인원 도달, 라운드 시작 준비")
        end
    end
end)

-- 플레이어 퇴장 처리
Players.PlayerRemoving:Connect(function(player)
    GameState.killCounts[player.UserId] = nil
    GameState.teamAssignments[player.UserId] = nil
end)

-- 게임 상태 조회 (클라이언트 요청)
local getGameStateFunc = GameEvents.getFunction("GetGameState")
if getGameStateFunc then
    getGameStateFunc.OnServerInvoke = function(player)
        return {
            status = GameState.status,
            scores = GameState.scores,
            teamName = GameState.teamAssignments[player.UserId],
        }
    end
end

print("[GameManager] 초기화 완료")
