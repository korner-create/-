-- ItemSpawner.server.lua
-- 아이템 스폰 및 효과 처리

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapConfig = require(ReplicatedStorage:WaitForChild("MapConfig"))
local GameEvents = require(ReplicatedStorage:WaitForChild("GameEvents"))

local RESPAWN_COOLDOWN = 20  -- 아이템 재스폰 시간 (초)
local activeItems = {}       -- { part = Part, itemData = {...} }

-- 가중치 기반 랜덤 아이템 선택
local function pickRandomItem()
    local totalWeight = 0
    for _, item in ipairs(MapConfig.ITEMS) do
        totalWeight += item.weight
    end

    local roll = math.random(totalWeight)
    local cumulative = 0
    for _, item in ipairs(MapConfig.ITEMS) do
        cumulative += item.weight
        if roll <= cumulative then
            return item
        end
    end
    return MapConfig.ITEMS[1]
end

-- 아이템 파트 생성
local function createItemPart(position, itemData)
    local part = Instance.new("Part")
    part.Name = "Item_" .. itemData.name
    part.Size = Vector3.new(2, 2, 2)
    part.Position = position + Vector3.new(0, 2, 0)
    part.Anchored = false
    part.CanCollide = false
    part.Material = Enum.Material.Neon

    if itemData.name == "HealthPotion" then
        part.Color = Color3.fromRGB(0, 220, 80)
    elseif itemData.name == "MagicSword" then
        part.Color = Color3.fromRGB(80, 120, 255)
    elseif itemData.name == "ShieldOrb" then
        part.Color = Color3.fromRGB(255, 200, 0)
    elseif itemData.name == "SpeedBoost" then
        part.Color = Color3.fromRGB(0, 255, 200)
    elseif itemData.name == "MagicBomb" then
        part.Color = Color3.fromRGB(255, 50, 50)
    end

    -- 회전 애니메이션
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyGyro.Parent = part

    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.Position = position + Vector3.new(0, 2, 0)
    bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPosition.Parent = part

    -- 아이템 이름 빌보드
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = itemData.name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = billboard

    part:SetAttribute("ItemName", itemData.name)
    for k, v in pairs(itemData) do
        if k ~= "name" then
            part:SetAttribute(k, v)
        end
    end

    part.Parent = workspace

    -- 회전 루프
    task.spawn(function()
        while part and part.Parent do
            bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, math.rad(2), 0)
            task.wait(0.05)
        end
    end)

    return part
end

-- 아이템 효과 적용
local function applyItemEffect(player, itemData)
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if itemData.name == "HealthPotion" then
        humanoid.Health = math.min(humanoid.Health + (itemData.healAmount or 50), humanoid.MaxHealth)
        print(player.Name .. " 체력 회복: +" .. (itemData.healAmount or 50))

    elseif itemData.name == "SpeedBoost" then
        local original = humanoid.WalkSpeed
        humanoid.WalkSpeed = original * 2
        task.delay(itemData.duration or 10, function()
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = original
            end
        end)
        print(player.Name .. " 속도 부스트 활성화")

    elseif itemData.name == "MagicSword" then
        -- 임시 공격력 증가 (Tool 지급)
        local tool = Instance.new("Tool")
        tool.Name = "마법 검"
        tool.RequiresHandle = false
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.5, 3, 0.5)
        handle.Color = Color3.fromRGB(80, 120, 255)
        handle.Material = Enum.Material.Neon
        handle.Parent = tool
        tool.Parent = player.Backpack
        print(player.Name .. " 마법 검 획득")

    elseif itemData.name == "ShieldOrb" then
        -- 방어력 증가 태그
        local shieldTag = Instance.new("IntValue")
        shieldTag.Name = "ShieldValue"
        shieldTag.Value = itemData.defense or 20
        shieldTag.Parent = character
        task.delay(15, function()
            if shieldTag and shieldTag.Parent then
                shieldTag:Destroy()
            end
        end)
        print(player.Name .. " 보호막 활성화")
    end
end

-- 스폰 포인트에 아이템 생성
local function spawnItemAt(spawnPos)
    local itemData = pickRandomItem()
    local part = createItemPart(spawnPos, itemData)

    -- 터치 감지
    part.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if not player then return end
        if not part.Parent then return end

        -- 아이템 제거
        part:Destroy()

        -- 효과 적용
        applyItemEffect(player, itemData)

        GameEvents.getEvent("ItemPickedUp"):FireAllClients(player.Name, itemData.name)

        -- 리스폰 예약
        task.delay(RESPAWN_COOLDOWN, function()
            spawnItemAt(spawnPos)
        end)
    end)

    return part
end

-- 초기 아이템 스폰
task.wait(3)  -- 맵 빌드 대기
for _, spawnPos in ipairs(MapConfig.ITEM_SPAWN_POINTS) do
    task.wait(0.2)
    spawnItemAt(spawnPos)
end

print("[ItemSpawner] 초기 아이템 스폰 완료")
