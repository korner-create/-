-- MapBuilder.server.lua
-- 판타지 숲 배틀 맵 지형 및 오브젝트 생성
-- Workspace > Script 에 넣고 실행하세요

local MapConfig = require(game.ReplicatedStorage:WaitForChild("MapConfig"))

local MapBuilder = {}

-- 파트 생성 헬퍼
local function createPart(props)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = props.canCollide ~= false
    part.Size = props.size or Vector3.new(4, 4, 4)
    part.Position = props.position or Vector3.new(0, 0, 0)
    part.Color = props.color or Color3.fromRGB(150, 150, 150)
    part.Material = props.material or Enum.Material.SmoothPlastic
    part.Name = props.name or "Part"
    part.Parent = props.parent or workspace
    if props.transparency then
        part.Transparency = props.transparency
    end
    return part
end

-- 웨지(삼각형 파트) 생성
local function createWedge(props)
    local wedge = Instance.new("WedgePart")
    wedge.Anchored = true
    wedge.Size = props.size or Vector3.new(4, 4, 4)
    wedge.Position = props.position or Vector3.new(0, 0, 0)
    wedge.Color = props.color or Color3.fromRGB(150, 150, 150)
    wedge.Material = props.material or Enum.Material.SmoothPlastic
    wedge.Name = props.name or "Wedge"
    wedge.Parent = props.parent or workspace
    return wedge
end

-- 텍스트 레이블(BillboardGui) 붙이기
local function addLabel(part, text)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 120, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = billboard
end

-- 맵 폴더 생성
local function setupFolders()
    local mapFolder = Instance.new("Folder")
    mapFolder.Name = "FantasyForestMap"
    mapFolder.Parent = workspace

    local folders = {
        "Ground", "Center", "NorthBase", "SouthBase",
        "EastLake", "WestForest", "Decorations", "SpawnPoints"
    }
    local refs = {}
    for _, name in ipairs(folders) do
        local f = Instance.new("Folder")
        f.Name = name
        f.Parent = mapFolder
        refs[name] = f
    end
    return refs
end

-- 1. 바닥 (Ground)
local function buildGround(folders)
    createPart({
        name = "MainGround",
        size = Vector3.new(220, 2, 220),
        position = Vector3.new(0, -1, 0),
        color = MapConfig.COLORS.Ground,
        material = Enum.Material.Grass,
        parent = folders.Ground,
    })
end

-- 2. 중앙 마법 수정 광장
local function buildCenter(folders)
    -- 광장 바닥
    createPart({
        name = "CenterPlaza",
        size = Vector3.new(42, 1, 42),
        position = Vector3.new(0, 0.5, 0),
        color = Color3.fromRGB(200, 190, 170),
        material = Enum.Material.Cobblestone,
        parent = folders.Center,
    })

    -- 중앙 수정 기둥 (메인)
    createPart({
        name = "CrystalPillarMain",
        size = Vector3.new(4, 14, 4),
        position = Vector3.new(0, 8, 0),
        color = MapConfig.COLORS.MagicCrystal,
        material = Enum.Material.Neon,
        parent = folders.Center,
    })

    -- 주변 수정 4개
    local crystalOffsets = {
        Vector3.new(10, 5, 0), Vector3.new(-10, 5, 0),
        Vector3.new(0, 5, 10), Vector3.new(0, 5, -10),
    }
    for i, offset in ipairs(crystalOffsets) do
        createPart({
            name = "CrystalPillar" .. i,
            size = Vector3.new(2, 8, 2),
            position = offset,
            color = Color3.fromRGB(150, 80, 220),
            material = Enum.Material.Neon,
            parent = folders.Center,
        })
    end

    -- 아이템 스폰 마커 (투명)
    for i, pos in ipairs(MapConfig.ITEM_SPAWN_POINTS) do
        local marker = createPart({
            name = "ItemSpawnPoint" .. i,
            size = Vector3.new(2, 0.5, 2),
            position = pos,
            color = Color3.fromRGB(255, 220, 0),
            material = Enum.Material.Neon,
            transparency = 0.5,
            parent = folders.Center,
        })
        marker:SetAttribute("IsItemSpawn", true)
    end

    addLabel(workspace.FantasyForestMap.Center.CrystalPillarMain, "마법 수정 광장")
end

-- 3. 북쪽 — 엘프 유적 (팀 A)
local function buildNorthBase(folders)
    -- 기지 바닥
    createPart({
        name = "NorthFloor",
        size = Vector3.new(50, 1, 40),
        position = Vector3.new(0, 0.5, -80),
        color = Color3.fromRGB(80, 120, 60),
        material = Enum.Material.LeafyGrass,
        parent = folders.NorthBase,
    })

    -- 엘프 기둥들
    local pillarPositions = {
        Vector3.new(-18, 6, -65), Vector3.new(-18, 6, -95),
        Vector3.new(18, 6, -65),  Vector3.new(18, 6, -95),
    }
    for i, pos in ipairs(pillarPositions) do
        createPart({
            name = "ElfPillar" .. i,
            size = Vector3.new(3, 10, 3),
            position = pos,
            color = Color3.fromRGB(180, 200, 140),
            material = Enum.Material.SmoothPlastic,
            parent = folders.NorthBase,
        })
    end

    -- 팀 A 스폰 포인트
    local spawnConfig = MapConfig.SPAWN_LOCATIONS.TeamA
    for i = 1, spawnConfig.count do
        local angle = (i / spawnConfig.count) * math.pi * 2
        local spawnPos = spawnConfig.center + Vector3.new(
            math.cos(angle) * spawnConfig.radius,
            0,
            math.sin(angle) * spawnConfig.radius
        )
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "TeamA_Spawn" .. i
        spawn.Size = Vector3.new(4, 1, 4)
        spawn.Position = spawnPos
        spawn.TeamColor = BrickColor.new("Bright blue")
        spawn.Anchored = true
        spawn.Material = Enum.Material.SmoothPlastic
        spawn.BrickColor = BrickColor.new("Bright blue")
        spawn.Parent = folders.NorthBase
    end

    addLabel(folders.NorthBase.NorthFloor, "고대 엘프 유적 (팀 A)")
end

-- 4. 남쪽 — 드워프 요새 (팀 B)
local function buildSouthBase(folders)
    -- 기지 바닥
    createPart({
        name = "SouthFloor",
        size = Vector3.new(50, 1, 40),
        position = Vector3.new(0, 0.5, 80),
        color = Color3.fromRGB(100, 80, 60),
        material = Enum.Material.Cobblestone,
        parent = folders.SouthBase,
    })

    -- 드워프 성벽 (앞면)
    createPart({
        name = "SouthWallFront",
        size = Vector3.new(50, 8, 3),
        position = Vector3.new(0, 5, 62),
        color = Color3.fromRGB(120, 100, 80),
        material = Enum.Material.Cobblestone,
        parent = folders.SouthBase,
    })

    -- 드워프 망루 2개
    local towerPositions = { Vector3.new(-22, 8, 80), Vector3.new(22, 8, 80) }
    for i, pos in ipairs(towerPositions) do
        createPart({
            name = "DwarfTower" .. i,
            size = Vector3.new(8, 14, 8),
            position = pos,
            color = Color3.fromRGB(100, 90, 75),
            material = Enum.Material.Cobblestone,
            parent = folders.SouthBase,
        })
    end

    -- 팀 B 스폰 포인트
    local spawnConfig = MapConfig.SPAWN_LOCATIONS.TeamB
    for i = 1, spawnConfig.count do
        local angle = (i / spawnConfig.count) * math.pi * 2
        local spawnPos = spawnConfig.center + Vector3.new(
            math.cos(angle) * spawnConfig.radius,
            0,
            math.sin(angle) * spawnConfig.radius
        )
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "TeamB_Spawn" .. i
        spawn.Size = Vector3.new(4, 1, 4)
        spawn.Position = spawnPos
        spawn.TeamColor = BrickColor.new("Bright red")
        spawn.Anchored = true
        spawn.Material = Enum.Material.SmoothPlastic
        spawn.BrickColor = BrickColor.new("Bright red")
        spawn.Parent = folders.SouthBase
    end

    addLabel(folders.SouthBase.SouthFloor, "버려진 드워프 요새 (팀 B)")
end

-- 5. 동쪽 — 신비로운 호수
local function buildEastLake(folders)
    -- 호수 물
    createPart({
        name = "LakeWater",
        size = Vector3.new(50, 2, 50),
        position = Vector3.new(75, -0.5, 0),
        color = MapConfig.COLORS.Water,
        material = Enum.Material.Water,
        canCollide = false,
        transparency = 0.3,
        parent = folders.EastLake,
    })

    -- 호수 주변 바위 엄폐물
    local rockPositions = {
        { pos = Vector3.new(55, 3, -15), size = Vector3.new(6, 5, 5) },
        { pos = Vector3.new(55, 3, 15),  size = Vector3.new(5, 4, 6) },
        { pos = Vector3.new(95, 3, -10), size = Vector3.new(7, 5, 4) },
        { pos = Vector3.new(95, 3, 10),  size = Vector3.new(6, 6, 5) },
        { pos = Vector3.new(75, 3, -25), size = Vector3.new(5, 4, 5) },
        { pos = Vector3.new(75, 3, 25),  size = Vector3.new(5, 4, 5) },
    }
    for i, rock in ipairs(rockPositions) do
        createPart({
            name = "LakeRock" .. i,
            size = rock.size,
            position = rock.pos,
            color = Color3.fromRGB(130, 120, 105),
            material = Enum.Material.Rock,
            parent = folders.EastLake,
        })
    end

    addLabel(folders.EastLake.LakeWater, "신비로운 호수")
end

-- 6. 서쪽 — 마법 버섯 숲
local function buildWestForest(folders)
    -- 바닥
    createPart({
        name = "MushroomForestFloor",
        size = Vector3.new(60, 1, 60),
        position = Vector3.new(-70, 0.5, 0),
        color = Color3.fromRGB(50, 100, 40),
        material = Enum.Material.LeafyGrass,
        parent = folders.WestForest,
    })

    -- 큰 버섯들 (점프 패드 역할)
    local mushroomData = {
        { pos = Vector3.new(-60, 3, -15), size = Vector3.new(10, 4, 10), stemHeight = 5 },
        { pos = Vector3.new(-80, 5, 10),  size = Vector3.new(14, 4, 14), stemHeight = 8 },
        { pos = Vector3.new(-60, 3, 20),  size = Vector3.new(8, 4, 8),   stemHeight = 5 },
        { pos = Vector3.new(-95, 3, -10), size = Vector3.new(10, 4, 10), stemHeight = 5 },
    }
    for i, m in ipairs(mushroomData) do
        -- 버섯 기둥
        createPart({
            name = "MushroomStem" .. i,
            size = Vector3.new(2, m.stemHeight, 2),
            position = m.pos - Vector3.new(0, m.stemHeight / 2, 0),
            color = Color3.fromRGB(220, 200, 180),
            material = Enum.Material.SmoothPlastic,
            parent = folders.WestForest,
        })
        -- 버섯 갓 (점프 패드)
        local cap = createPart({
            name = "MushroomCap" .. i,
            size = m.size,
            position = m.pos,
            color = MapConfig.COLORS.Mushroom,
            material = Enum.Material.SmoothPlastic,
            parent = folders.WestForest,
        })
        cap:SetAttribute("IsJumpPad", true)
        cap:SetAttribute("JumpForce", 80)
    end

    addLabel(folders.WestForest.MushroomForestFloor, "마법 버섯 숲")
end

-- 7. 맵 경계 안개 효과 (Atmosphere)
local function setupAtmosphere()
    local atmosphere = Instance.new("Atmosphere")
    atmosphere.Density = 0.3
    atmosphere.Offset = 0.25
    atmosphere.Color = Color3.fromRGB(120, 180, 120)
    atmosphere.Decay = Color3.fromRGB(60, 100, 60)
    atmosphere.Glare = 0.1
    atmosphere.Haze = 2
    atmosphere.Parent = workspace.Terrain
end

-- 8. 조명 설정
local function setupLighting()
    local Lighting = game:GetService("Lighting")
    Lighting.Ambient = Color3.fromRGB(80, 90, 120)
    Lighting.Brightness = 2
    Lighting.ColorShift_Top = Color3.fromRGB(100, 150, 80)
    Lighting.TimeOfDay = "17:30:00"  -- 황혼 분위기

    -- 마법 불빛 (PointLight) — 중앙 수정에 추가
    local crystalLight = Instance.new("PointLight")
    crystalLight.Brightness = 5
    crystalLight.Color = Color3.fromRGB(150, 80, 255)
    crystalLight.Range = 40
    crystalLight.Parent = workspace.FantasyForestMap.Center.CrystalPillarMain
end

-- 메인 빌드 함수
function MapBuilder.build()
    print("[MapBuilder] 판타지 숲 배틀 맵 생성 시작...")

    -- 기존 맵 폴더가 있으면 제거
    local existing = workspace:FindFirstChild("FantasyForestMap")
    if existing then existing:Destroy() end

    local folders = setupFolders()

    buildGround(folders)
    print("[MapBuilder] 바닥 생성 완료")

    buildCenter(folders)
    print("[MapBuilder] 중앙 마법 수정 광장 완료")

    buildNorthBase(folders)
    print("[MapBuilder] 북쪽 엘프 유적 (팀 A) 완료")

    buildSouthBase(folders)
    print("[MapBuilder] 남쪽 드워프 요새 (팀 B) 완료")

    buildEastLake(folders)
    print("[MapBuilder] 동쪽 신비로운 호수 완료")

    buildWestForest(folders)
    print("[MapBuilder] 서쪽 마법 버섯 숲 완료")

    setupAtmosphere()
    setupLighting()

    print("[MapBuilder] 맵 생성 완료! ✔")
end

-- 자동 실행
MapBuilder.build()

return MapBuilder
