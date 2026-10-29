local WasUIPro = loadstring(game:HttpGet("https://github.com/WasKKal/WasUI-For-Roblox/raw/refs/heads/main/WasUIPro.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

WasUIPro:SetDefaultTheme("Dark")
WasUIPro:SetDefaultRainbowMode("流动")
WasUIPro:SetLanguage("中文")

-- ==========================================
-- 拦截确认弹窗（破晓）
-- ==========================================
WasUIPro:ShowConfirmDialog({
    title = "破晓",
    description = "是否确定进入【破晓】脚本？",
    confirmText = "确定进入",
    cancelText = "取消退出",
    onConfirm = function()
        
        -- 模拟文字加载动画
        WasUIPro:Notify({ Title = "系统", Content = "正在初始化环境...", Duration = 1 })
        task.wait(0.4)
        WasUIPro:Notify({ Title = "系统", Content = "正在拉取核心模块...", Duration = 1 })
        task.wait(0.4)
        WasUIPro:Notify({ Title = "系统", Content = "正在注入UI界面...", Duration = 1 })
        task.wait(0.4)
        WasUIPro:Notify({ Title = "成功", Content = "【破晓】加载完成！", Duration = 3 })

        -- 主界面创建
        local mainWindow = WasUIPro:CreateWindow({
            Title = "破晓",
            WelcomeText = "按游戏分类选择功能",
            MinimizedText = "破晓",
            Theme = "Dark",
            RainbowMode = "流动",
            Folder = "PoXiao_Config",
            TitleTag = {
                { text = "破晓", backgroundColor = Color3.fromRGB(255, 80, 80), textColor = Color3.fromRGB(255,255,255) }
            },
            FeatureNameColor = {Color3.fromRGB(255, 100, 200), Color3.fromRGB(255, 150, 50)}
        })

        -- ==========================================
        -- 标签1：造船寻宝
        -- ==========================================
        local shipTab = mainWindow:Tab({ Title = "造船寻宝" })
        local shipCategory = shipTab:Category({ Title = "自动化功能", IconName = "anchor" })

        local moveLoop = nil
        local isMoving = false
        local points = {
            Vector3.new(-43.128983, 66.641129, 1123.932861),
            Vector3.new(-46.607533, 49.785690, 8677.564453),
            Vector3.new(-53.364597, -289.227875, 8735.583984),
            Vector3.new(-54.343830, -358.203461, 9490.367188)
        }

        shipCategory:Toggle({
            Title = "刷钱 (自动移动)",
            Value = false,
            FeatureName = "ShipFarm",
            ConfigKey = "ship_farm",
            Callback = function(state)
                isMoving = state
                if moveLoop then task.cancel(moveLoop) moveLoop = nil end
                if state then
                    moveLoop = task.spawn(function()
                        while isMoving do
                            local char = LocalPlayer.Character
                            local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                            if not myRoot then task.wait(0.1) continue end
                            for i = 1, #points - 1 do
                                if not isMoving then break end
                                local startPos = points[i]
                                local endPos = points[i + 1]
                                local duration = 10
                                local elapsed = 0
                                while elapsed < duration and isMoving do
                                    if not myRoot or not myRoot.Parent then break end
                                    local t = elapsed / duration
                                    myRoot.CFrame = CFrame.new(startPos:Lerp(endPos, t))
                                    elapsed = elapsed + 0.01
                                    task.wait(0.01)
                                end
                                if isMoving then task.wait(1) end
                            end
                        end
                    end)
                end
            end
        })-- ==========================================
-- 标签2：保护房子不受怪物入侵
-- ==========================================
local houseTab = mainWindow:Tab({ Title = "保护房子" })
local espCategory = houseTab:Category({ Title = "透视功能 (ESP)", IconName = "eye" })
local combatCategory = houseTab:Category({ Title = "战斗辅助", IconName = "crosshair" })
local moveCategory = houseTab:Category({ Title = "角色移动", IconName = "footprints" })

-- 核心函数：透视武器箱
local function ESP_WeaponBoxes(state)
    if not getgenv().WeaponBoxesESP then getgenv().WeaponBoxesESP = { Enabled = false, Boxes = {}, Connection = nil, SearchInterval = nil } end
    local ESP = getgenv().WeaponBoxesESP
    local function CreateESPForBox(hitbox)
        if ESP.Boxes[hitbox] or not hitbox or not hitbox.Parent then return end
        local highlight = Instance.new("Highlight")
        highlight.Adornee = hitbox
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
        highlight.FillTransparency = 0.5
        highlight.Parent = hitbox
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = hitbox
        billboard.Size = UDim2.new(0, 150, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 500
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "武器箱"
        textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 16
        textLabel.Parent = billboard
        billboard.Parent = hitbox
        ESP.Boxes[hitbox] = { Highlight = highlight, Billboard = billboard }
        hitbox.AncestryChanged:Connect(function(_, parent)
            if not parent and ESP.Boxes[hitbox] then
                if ESP.Boxes[hitbox].Highlight then ESP.Boxes[hitbox].Highlight:Destroy() end
                if ESP.Boxes[hitbox].Billboard then ESP.Boxes[hitbox].Billboard:Destroy() end
                ESP.Boxes[hitbox] = nil
            end
        end)
    end
    local function ScanForBoxes()
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            if descendant:IsA("BasePart") or descendant:IsA("Model") then
                if descendant.Name:lower():find("hitbox") then CreateESPForBox(descendant) end
            end
        end
    end
    local function ClearAllESP()
        for hitbox, espData in pairs(ESP.Boxes) do
            if espData.Highlight then espData.Highlight:Destroy() end
            if espData.Billboard then espData.Billboard:Destroy() end
        end
        ESP.Boxes = {}
    end
    if state then
        if ESP.Enabled then return end
        ESP.Enabled = true
        ScanForBoxes()
        ESP.SearchInterval = task.spawn(function() while ESP.Enabled do task.wait(2) ScanForBoxes() end end)
        ESP.Connection = Workspace.DescendantAdded:Connect(function(descendant)
            if ESP.Enabled and (descendant:IsA("BasePart") or descendant:IsA("Model")) then
                task.wait(0.1)
                if descendant.Name:lower():find("hitbox") then CreateESPForBox(descendant) end
            end
        end)
    else
        ESP.Enabled = false
        if ESP.Connection then ESP.Connection:Disconnect() ESP.Connection = nil end
        if ESP.SearchInterval then task.cancel(ESP.SearchInterval) ESP.SearchInterval = nil end
        ClearAllESP()
    end
end

-- 核心函数：透视 Boss
local function ESP_Bosses(state)
    if not _G.BossESP then _G.BossESP = { Active = false, Connections = {}, ESPObjects = {} } end
    local ESP = _G.BossESP
    local function ClearESP()
        for _, connection in pairs(ESP.Connections) do if connection then connection:Disconnect() end end
        ESP.Connections = {}
        for _, obj in pairs(ESP.ESPObjects) do
            if obj.Billboard then obj.Billboard:Destroy() end
            if obj.Highlight then obj.Highlight:Destroy() end
        end
        ESP.ESPObjects = {}
    end
    local function CreateBossESP(boss)
        if ESP.ESPObjects[boss] then return end
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
        highlight.FillTransparency = 0.5
        highlight.Parent = boss
        local billboard = Instance.new("BillboardGui")
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = boss
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 25)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = boss.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 18
        nameLabel.Parent = billboard
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "Distance"
        distanceLabel.Size = UDim2.new(1, 0, 0, 20)
        distanceLabel.Position = UDim2.new(0, 0, 0, 22)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = "距离: -- 米"
        distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.TextSize = 14
        distanceLabel.Parent = billboard
        ESP.ESPObjects[boss] = { Billboard = billboard, Highlight = highlight }
    end
    local function UpdateDistances()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        for boss, espData in pairs(ESP.ESPObjects) do
            if boss and boss.Parent and espData.Billboard then
                local distanceLabel = espData.Billboard:FindFirstChild("Distance")
                if distanceLabel then
                    distanceLabel.Text = "距离: " .. math.floor((humanoidRootPart.Position - boss.Position).Magnitude) .. " 米"
                end
            end
        end
    end
    if state then
        if ESP.Active then return end
        ESP.Active = true
        for _, obj in pairs(Workspace:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) and string.sub(obj.Name, 1, 5) == "Boss_" then CreateBossESP(obj) end
        end
        table.insert(ESP.Connections, RunService.Heartbeat:Connect(function() if ESP.Active then UpdateDistances() end end))
        table.insert(ESP.Connections, Workspace.DescendantAdded:Connect(function(descendant)
            if ESP.Active and (descendant:IsA("BasePart") or descendant:IsA("Model")) and string.sub(descendant.Name, 1, 5) == "Boss_" then
                task.wait(0.1) CreateBossESP(descendant)
            end
        end))
    else
        ESP.Active = false
        ClearESP()
    end
end

-- 核心函数：透视僵尸
local function ESP_ZombieType(state, typeName, displayTitle, color)
    if not _G[typeName.."ESP"] then _G[typeName.."ESP"] = { Active = false, Connections = {}, ESPObjects = {} } end
    local ESP = _G[typeName.."ESP"]
    local function ClearESP()
        for _, connection in pairs(ESP.Connections) do if connection then connection:Disconnect() end end
        ESP.Connections = {}
        for _, obj in pairs(ESP.ESPObjects) do
            if obj.Billboard then obj.Billboard:Destroy() end
            if obj.Highlight then obj.Highlight:Destroy() end
        end
        ESP.ESPObjects = {}
    end
    local function CreateESP(zombie)
        if ESP.ESPObjects[zombie] then return end
        local highlight = Instance.new("Highlight")
        highlight.FillColor = color
        highlight.OutlineColor = color
        highlight.FillTransparency = 0.5
        highlight.Parent = zombie
        local billboard = Instance.new("BillboardGui")
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 120, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Parent = zombie
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = displayTitle
        nameLabel.TextColor3 = color
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Parent = billboard
        ESP.ESPObjects[zombie] = { Billboard = billboard, Highlight = highlight }
    end
    if state then
        if ESP.Active then return end
        ESP.Active = true
        for _, obj in pairs(Workspace:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Name:lower() == typeName:lower() then CreateESP(obj) end
        end
        table.insert(ESP.Connections, Workspace.DescendantAdded:Connect(function(descendant)
            if ESP.Active and (descendant:IsA("BasePart") or descendant:IsA("Model")) and descendant.Name:lower() == typeName:lower() then
                task.wait(0.1) CreateESP(descendant)
            end
        end))
    else
        ESP.Active = false
        ClearESP()
    end
end        -- 核心函数：自瞄辅助
        local aimConnection = nil
        local function AimAssist(state)
            if state then
                if aimConnection then aimConnection:Disconnect() end
                aimConnection = RunService.RenderStepped:Connect(function()
                    local isAimKeyPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                    if isAimKeyPressed then
                        local bestTarget, bestDist = nil, math.huge
                        local camPos, camLook = Camera.CFrame.Position, Camera.CFrame.LookVector
                        for _, model in ipairs(Workspace:GetDescendants()) do
                            if model:IsA("Model") and model ~= LocalPlayer.Character then
                                local humanoid = model:FindFirstChildOfClass("Humanoid")
                                local head = model:FindFirstChild("Head")
                                if humanoid and humanoid.Health > 0 and head then
                                    local dist = (head.Position - camPos).Magnitude
                                    if dist <= 200 then
                                        local angle = math.deg(math.acos(math.clamp(camLook:Dot((head.Position - camPos).Unit), -1, 1)))
                                        if angle <= 60 and dist < bestDist then bestDist, bestTarget = dist, head end
                                    end
                                end
                            end
                        end
                        if bestTarget then
                            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, bestTarget.Position), 0.15)
                        end
                    end
                end)
            else
                if aimConnection then aimConnection:Disconnect() aimConnection = nil end
            end
        end

        -- 核心函数：穿墙、无限跳、移速、跳跃
        local noclipConn = nil
        local function Noclip(state)
            if state then
                if noclipConn then return end
                noclipConn = RunService.Stepped:Connect(function()
                    if LocalPlayer.Character then
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end)
            else
                if noclipConn then noclipConn:Disconnect() noclipConn = nil end
            end
        end

        local jumpConn = nil
        local function InfiniteJump(state)
            if state then
                if jumpConn then return end
                jumpConn = UserInputService.JumpRequest:Connect(function()
                    if LocalPlayer.Character then
                        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end
                end)
            else
                if jumpConn then jumpConn:Disconnect() jumpConn = nil end
            end
        end

        local function SetWalkspeed(speed)
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = math.clamp(speed, 16, 200) end
            end
        end

        local function SetJumpPower(power)
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.JumpPower = math.clamp(power, 50, 200) end
            end
        end

        -- ==========================================
        -- 绑定所有 UI 控件
        -- ==========================================
        espCategory:Toggle({ Title = "透视武器箱", Callback = function(state) ESP_WeaponBoxes(state) end })
        espCategory:Toggle({ Title = "透视 Boss", Callback = function(state) ESP_Bosses(state) end })
        espCategory:Toggle({ Title = "透视南瓜僵尸", Callback = function(state) ESP_ZombieType(state, "pumpkin", "南瓜僵尸", Color3.fromRGB(255, 165, 0)) end })
        espCategory:Toggle({ Title = "透视隐藏僵尸", Callback = function(state) ESP_ZombieType(state, "secret", "隐藏僵尸", Color3.fromRGB(128, 0, 128)) end })
        espCategory:Toggle({ Title = "透视蝙蝠", Callback = function(state) ESP_ZombieType(state, "bat", "蝙蝠", Color3.fromRGB(0, 100, 255)) end })
        espCategory:Toggle({ Title = "透视普通僵尸", Callback = function(state) ESP_ZombieType(state, "zombie", "普通僵尸", Color3.fromRGB(0, 255, 0)) end })
        
        -- X光透视
        local function Xray(state)
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and LocalPlayer.Character and not part:IsDescendantOf(LocalPlayer.Character) then
                    part.LocalTransparencyModifier = state and 0.7 or 0
                end
            end
        end
        espCategory:Toggle({ Title = "X光透视", Callback = function(state) Xray(state) end })

        combatCategory:Toggle({ Title = "自瞄辅助", Callback = function(state) AimAssist(state) end })
        combatCategory:Toggle({ Title = "穿墙", Callback = function(state) Noclip(state) end })
        combatCategory:Toggle({ Title = "无限跳", Callback = function(state) InfiniteJump(state) end })
        
        moveCategory:Slider({ Title = "移动速度", Min = 16, Max = 200, Default = 16, Callback = function(value) SetWalkspeed(value) end })
        moveCategory:Slider({ Title = "跳跃高度", Min = 50, Max = 200, Default = 50, Callback = function(value) SetJumpPower(value) end })

        -- 快捷键（F1隐藏菜单）
        local isVisible = true
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.F1 then
                isVisible = not isVisible
                mainWindow:SetVisible(isVisible)
            end
        end)

    end -- onConfirm 结束
}) -- ShowConfirmDialog 结束
