-- PlayerController.client.lua
-- 클라이언트 UI, 점수판, 알림 처리

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local GameEvents = require(ReplicatedStorage:WaitForChild("GameEvents"))

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- ── UI 생성 ──────────────────────────────────────────────

-- 메인 ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 점수판
local scoreFrame = Instance.new("Frame")
scoreFrame.Name = "ScoreFrame"
scoreFrame.Size = UDim2.new(0, 250, 0, 70)
scoreFrame.Position = UDim2.new(0.5, -125, 0, 10)
scoreFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
scoreFrame.BackgroundTransparency = 0.3
scoreFrame.BorderSizePixel = 0
scoreFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = scoreFrame

local teamAScore = Instance.new("TextLabel")
teamAScore.Name = "TeamAScore"
teamAScore.Size = UDim2.new(0.5, 0, 1, 0)
teamAScore.Position = UDim2.new(0, 0, 0, 0)
teamAScore.BackgroundTransparency = 1
teamAScore.Text = "엘프 팀\n0"
teamAScore.TextColor3 = Color3.fromRGB(80, 160, 255)
teamAScore.Font = Enum.Font.GothamBold
teamAScore.TextScaled = true
teamAScore.Parent = scoreFrame

local teamBScore = Instance.new("TextLabel")
teamBScore.Name = "TeamBScore"
teamBScore.Size = UDim2.new(0.5, 0, 1, 0)
teamBScore.Position = UDim2.new(0.5, 0, 0, 0)
teamBScore.BackgroundTransparency = 1
teamBScore.Text = "드워프 팀\n0"
teamBScore.TextColor3 = Color3.fromRGB(255, 80, 80)
teamBScore.Font = Enum.Font.GothamBold
teamBScore.TextScaled = true
teamBScore.Parent = scoreFrame

-- 타이머
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "Timer"
timerLabel.Size = UDim2.new(0, 100, 0, 35)
timerLabel.Position = UDim2.new(0.5, -50, 0, 85)
timerLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
timerLabel.BackgroundTransparency = 0.3
timerLabel.BorderSizePixel = 0
timerLabel.Text = "5:00"
timerLabel.TextColor3 = Color3.new(1, 1, 1)
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextScaled = true
timerLabel.Parent = screenGui

local timerCorner = Instance.new("UICorner")
timerCorner.CornerRadius = UDim.new(0, 6)
timerCorner.Parent = timerLabel

-- 알림 패널 (킬 피드)
local killFeed = Instance.new("Frame")
killFeed.Name = "KillFeed"
killFeed.Size = UDim2.new(0, 220, 0, 120)
killFeed.Position = UDim2.new(1, -230, 0, 10)
killFeed.BackgroundTransparency = 1
killFeed.BorderSizePixel = 0
killFeed.Parent = screenGui

local killFeedLayout = Instance.new("UIListLayout")
killFeedLayout.SortOrder = Enum.SortOrder.LayoutOrder
killFeedLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
killFeedLayout.Parent = killFeed

-- 팀 배정 알림
local teamBanner = Instance.new("Frame")
teamBanner.Name = "TeamBanner"
teamBanner.Size = UDim2.new(0, 300, 0, 80)
teamBanner.Position = UDim2.new(0.5, -150, 0.5, -40)
teamBanner.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
teamBanner.BackgroundTransparency = 0.2
teamBanner.BorderSizePixel = 0
teamBanner.Visible = false
teamBanner.Parent = screenGui

local teamBannerCorner = Instance.new("UICorner")
teamBannerCorner.CornerRadius = UDim.new(0, 12)
teamBannerCorner.Parent = teamBanner

local teamBannerLabel = Instance.new("TextLabel")
teamBannerLabel.Size = UDim2.new(1, 0, 1, 0)
teamBannerLabel.BackgroundTransparency = 1
teamBannerLabel.Text = "팀 배정 중..."
teamBannerLabel.TextColor3 = Color3.new(1, 1, 1)
teamBannerLabel.Font = Enum.Font.GothamBold
teamBannerLabel.TextScaled = true
teamBannerLabel.Parent = teamBanner

-- ── 헬퍼 함수 ────────────────────────────────────────────

-- 킬 피드 메시지 추가
local function addKillFeedMessage(text, color)
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, 0, 0, 22)
    msg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    msg.BackgroundTransparency = 0.5
    msg.Text = text
    msg.TextColor3 = color or Color3.new(1, 1, 1)
    msg.Font = Enum.Font.Gotham
    msg.TextScaled = true
    msg.LayoutOrder = tick()
    msg.Parent = killFeed

    -- 5초 후 사라짐
    TweenService:Create(msg, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
        BackgroundTransparency = 1,
        TextTransparency = 1,
    }):Play()
    task.delay(5, function()
        if msg.Parent then msg:Destroy() end
    end)
end

-- 타이머 포맷
local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%d:%02d", mins, secs)
end

-- 점수판 업데이트
local function updateScoreboard(scores)
    teamAScore.Text = "엘프 팀\n" .. (scores.TeamA or 0)
    teamBScore.Text = "드워프 팀\n" .. (scores.TeamB or 0)
end

-- ── 이벤트 연결 ──────────────────────────────────────────

-- 라운드 시작
GameEvents.getEvent("RoundStarted").OnClientEvent:Connect(function(data)
    local timeLeft = data.duration or 300
    addKillFeedMessage("⚔ 라운드 시작!", Color3.fromRGB(255, 220, 0))

    task.spawn(function()
        while timeLeft > 0 do
            timerLabel.Text = formatTime(timeLeft)
            task.wait(1)
            timeLeft -= 1
        end
        timerLabel.Text = "0:00"
    end)
end)

-- 라운드 종료
GameEvents.getEvent("RoundEnded").OnClientEvent:Connect(function(data)
    local msg = data.winnerName .. " 승리! (A:" .. data.scores.TeamA .. " / B:" .. data.scores.TeamB .. ")"
    addKillFeedMessage("🏆 " .. msg, Color3.fromRGB(255, 215, 0))
    updateScoreboard(data.scores)
end)

-- 플레이어 사망
GameEvents.getEvent("PlayerDied").OnClientEvent:Connect(function(playerName, scores)
    addKillFeedMessage("💀 " .. playerName .. " 사망", Color3.fromRGB(200, 200, 200))
    updateScoreboard(scores)
end)

-- 점수판 갱신
GameEvents.getEvent("UpdateScoreboard").OnClientEvent:Connect(function(scores)
    updateScoreboard(scores)
end)

-- 아이템 획득 알림
GameEvents.getEvent("ItemPickedUp").OnClientEvent:Connect(function(playerName, itemName)
    local color = Color3.fromRGB(100, 255, 150)
    addKillFeedMessage("✨ " .. playerName .. " → " .. itemName, color)
end)

-- 팀 배정
GameEvents.getEvent("TeamAssigned").OnClientEvent:Connect(function(teamName)
    teamBanner.Visible = true
    if teamName == "TeamA" then
        teamBannerLabel.Text = "⚔ 엘프 팀 배정!"
        teamBannerLabel.TextColor3 = Color3.fromRGB(80, 160, 255)
        teamBanner.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
    else
        teamBannerLabel.Text = "🛡 드워프 팀 배정!"
        teamBannerLabel.TextColor3 = Color3.fromRGB(255, 100, 80)
        teamBanner.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    end

    task.delay(3, function()
        TweenService:Create(teamBanner, TweenInfo.new(0.5), {
            BackgroundTransparency = 1,
        }):Play()
        TweenService:Create(teamBannerLabel, TweenInfo.new(0.5), {
            TextTransparency = 1,
        }):Play()
        task.delay(0.5, function()
            teamBanner.Visible = false
            teamBannerLabel.TextTransparency = 0
        end)
    end)
end)

-- 버섯 점프 패드 처리 (클라이언트)
localPlayer.CharacterAdded:Connect(function(character)
    local rootPart = character:WaitForChild("HumanoidRootPart")
    rootPart.Touched:Connect(function(hit)
        if hit:GetAttribute("IsJumpPad") then
            local jumpForce = hit:GetAttribute("JumpForce") or 80
            local velocity = Instance.new("BodyVelocity")
            velocity.Velocity = Vector3.new(0, jumpForce, 0)
            velocity.MaxForce = Vector3.new(0, math.huge, 0)
            velocity.Parent = rootPart
            task.delay(0.2, function()
                if velocity.Parent then velocity:Destroy() end
            end)
        end
    end)
end)

print("[PlayerController] UI 초기화 완료")
