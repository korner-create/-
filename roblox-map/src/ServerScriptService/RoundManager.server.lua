-- RoundManager.server.lua
-- 라운드 시작/종료, 타이머 관리

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapConfig = require(ReplicatedStorage:WaitForChild("MapConfig"))
local GameEvents = require(ReplicatedStorage:WaitForChild("GameEvents"))

-- GameManager에서 공유 상태 참조 (ModuleScript로 분리 시 개선 가능)
local RoundManager = {}

-- 라운드 타이머
local roundTimer = nil
local roundActive = false

-- 점수판 초기화
local function resetScores()
    return { TeamA = 0, TeamB = 0 }
end

-- 승리 팀 판정
local function determineWinner(scores)
    if scores.TeamA > scores.TeamB then
        return "TeamA", "엘프 팀"
    elseif scores.TeamB > scores.TeamA then
        return "TeamB", "드워프 팀"
    else
        return nil, "무승부"
    end
end

-- 라운드 시작
function RoundManager.startRound(scores, teamAssignments)
    if roundActive then return end
    roundActive = true

    print("[RoundManager] 라운드 시작!")

    -- 모든 플레이어에게 라운드 시작 알림
    GameEvents.getEvent("RoundStarted"):FireAllClients({
        duration = MapConfig.ROUND_TIME,
    })

    -- 타이머 카운트다운
    local timeLeft = MapConfig.ROUND_TIME
    roundTimer = task.spawn(function()
        while timeLeft > 0 and roundActive do
            task.wait(1)
            timeLeft -= 1

            -- 10초마다 점수판 동기화
            if timeLeft % 10 == 0 then
                GameEvents.getEvent("UpdateScoreboard"):FireAllClients(scores, {})
            end
        end

        if roundActive then
            RoundManager.endRound(scores)
        end
    end)

    return roundTimer
end

-- 라운드 종료
function RoundManager.endRound(scores)
    if not roundActive then return end
    roundActive = false

    local winnerTeam, winnerName = determineWinner(scores)
    print("[RoundManager] 라운드 종료! 승자: " .. winnerName)

    -- 종료 이벤트 발송
    GameEvents.getEvent("RoundEnded"):FireAllClients({
        winnerTeam = winnerTeam,
        winnerName = winnerName,
        scores = scores,
    })

    -- 인터미션
    task.delay(MapConfig.INTERMISSION_TIME, function()
        -- 점수 초기화 후 새 라운드
        local newScores = resetScores()
        if #Players:GetPlayers() >= MapConfig.MIN_PLAYERS then
            RoundManager.startRound(newScores, {})
        else
            roundActive = false
            print("[RoundManager] 플레이어 부족으로 대기 중...")
        end
    end)
end

-- 라운드 강제 종료 (관리자용)
function RoundManager.forceEnd(scores)
    roundActive = false
    if roundTimer then
        task.cancel(roundTimer)
    end
    RoundManager.endRound(scores)
end

print("[RoundManager] 초기화 완료")

return RoundManager
