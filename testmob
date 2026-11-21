--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

--// Variables
local Murderer, Sheriff = nil, nil
local roles = {}
local highlightedPlayers = {}
local currentTween = nil
local Connections = {}
local shootConnection = nil
local hasResetThisBag = false

local SelectedTargets = {}
local FlingActive = false
local FlingMurdererActive = false
local FlingSheriffActive = false
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

local Flying = false
local FlySpeed = 50
local BodyGyro, BodyVelocity

local Config = {
    AutoFarm = false,
    FarmMode = "Nearest",
    AutoGrab = false,
    DodgeKnife = false,
    Chams = false,
    GunCham = false,
    KillAura = false,
    AuraDistance = 15,
    KillAll = false,
    SilentAim = false,
    AutoShoot = false,
    BlatantKill = false,
    WalkSpeed = false,
    WalkSpeedValue = 22,
    AntiFling = false,
    Noclip = false,
    AutoReset = false,
    Fly = false,
    AntiAFK = false,
    ShowSilentAimButton = true -- nouveau
}

--// Utils
local function Notify(text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "The cat factory",
        Text = text,
        Duration = 3
    })
end

local function Equip(toolName)
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
    if humanoid and tool then humanoid:EquipTool(tool) end
end

local function TargetModel(target)
    for _, model in pairs(workspace:GetChildren()) do
        if model:IsA("Model") and not string.find(string.lower(model.Name), "lobby") then
            if target == "CoinContainer" and model:FindFirstChild("CoinContainer") then return model.CoinContainer
            elseif target == "Spawns" and model:FindFirstChild("Spawns") then return model.Spawns end
        end
    end
end

local function findGunDrop()
    local spawns = TargetModel("Spawns")
    if spawns and spawns.Parent then return spawns.Parent:FindFirstChild("GunDrop") end
end

local function IsAlive(player)
    local role = roles[player.Name]
    if not role then return false end
    if not role.Killed and not role.Dead then return true end
    if player.Character and player.Character:FindFirstChild("HumanoidCloned") then return true end
    return false
end

local function Fetch(itemName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Backpack:FindFirstChild(itemName) or (player.Character and player.Character:FindFirstChild(itemName)) then
            return player.Name
        end
    end
end

local function TrackCoinBag()
    local role = roles[LocalPlayer.Name]
    if not role then return false end
    local coins = tonumber(role.Coins) or 0
    local elite = LocalPlayer:GetAttribute("Elite")
    return (elite ~= nil and coins >= 50) or (elite == nil and coins >= 40)
end

local function CoinAttribute(part)
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return false end
    local dist = (part.Position - char.PrimaryPart.Position).Magnitude
    if dist <= 4 then
        pcall(function()
            firetouchinterest(part, char.HumanoidRootPart, 1)
            task.wait(0.1)
            firetouchinterest(part, char.HumanoidRootPart, 0)
        end)
    end
    return part:GetAttribute("Collected") ~= true
end

local function tween_teleport(cf, speed)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if currentTween then currentTween:Cancel() end
    hrp.AssemblyLinearVelocity = Vector3.zero
    local dist = (hrp.Position - cf.Position).Magnitude
    local time = math.clamp(dist / speed, 0.1, 4)
    currentTween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = cf})
    currentTween:Play()
end

local function BodyVelocityControl(state)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if state then
        if not hrp:FindFirstChild("BodyVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "BodyVelocity"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
        end
    else
        if hrp:FindFirstChild("BodyVelocity") then hrp.BodyVelocity:Destroy() end
    end
end

local function isPlayerVisible(player)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return false end
    local origin = char.HumanoidRootPart.Position
    local target = player.Character.HumanoidRootPart.Position
    local direction = (target - origin).Unit * 80
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    local result = workspace:Raycast(origin, direction, params)
    return not result or result.Instance:IsDescendantOf(player.Character)
end

local function ShootMurderer(isBlatant)
    local player = LocalPlayer
    if not player then return end
    local Gun = player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun"))
    if not Gun then return end
    if not Murderer then return end
    local murderer = Players:FindFirstChild(Murderer)
    if not murderer or not murderer.Character then return end
    local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
    local murdererHum = murderer.Character:FindFirstChild("Humanoid")
    if not murdererHRP or not murdererHum then return end

    local velocity = murdererHRP.AssemblyLinearVelocity or Vector3.zero
    local moveDir = murdererHum.MoveDirection or Vector3.zero
    local predictedPos = murdererHRP.Position + (velocity * Vector3.new(0, 0.5, 0)) * (2.8 / 15) + moveDir * 2.8

    local ohCFrame1, ohCFrame2 = nil, CFrame.new(predictedPos)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if isBlatant then
        local rootAttachment = murdererHRP:FindFirstChild("RootAttachment")
        ohCFrame1 = rootAttachment and (rootAttachment.WorldCFrame * CFrame.new(0, 2, 0)) or murdererHRP.CFrame
    else
        local gunShoulder = hrp:FindFirstChild("GunShoulderAttachment")
        ohCFrame1 = gunShoulder and gunShoulder.WorldCFrame or hrp.CFrame
    end

    if Gun:FindFirstChild("Handle") and Gun.Handle:FindFirstChild("Reload") and not Gun.Handle.Reload.Playing then
        local shootEvent = workspace:FindFirstChild(player.Name) and workspace[player.Name]:FindFirstChild("Gun") and workspace[player.Name].Gun:FindFirstChild("Shoot")
        if shootEvent then
            shootEvent:FireServer(ohCFrame1, ohCFrame2)
        elseif Gun:FindFirstChild("Shoot") then
            Gun.Shoot:FireServer(ohCFrame1, ohCFrame2)
        end
    end
end

local function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end

    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
        if THumanoid and THumanoid.Sit then return end

        if THead then workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end

        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local SFBasePart = function(BasePart)
            local TimeToWait = 2.2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0,0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0,0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0,0,0))
                        task.wait()
                    end
                end
            until tick() - Time >= TimeToWait
        end

        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.zero
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if TRootPart then SFBasePart(TRootPart)
        elseif THead then SFBasePart(THead)
        elseif Handle then SFBasePart(Handle) end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid

        if getgenv().OldPos then
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity, part.RotVelocity = Vector3.zero, Vector3.zero
                    end
                end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end
end

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 9e4
    BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.CFrame = hrp.CFrame
    BodyGyro.Parent = hrp

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Parent = hrp
    humanoid.PlatformStand = true

    Connections.Fly = RunService.RenderStepped:Connect(function()
        if not Flying or not hrp or not hrp.Parent then return end
        local camera = workspace.CurrentCamera
        local direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0,1,0) end
        if direction.Magnitude > 0 then direction = direction.Unit * FlySpeed end
        BodyVelocity.Velocity = direction
        BodyGyro.CFrame = camera.CFrame
    end)
end

local function StopFly()
    if Connections.Fly then Connections.Fly:Disconnect() Connections.Fly = nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
end

local function findCoin(hrp)
    local container = TargetModel("CoinContainer")
    if not container then return end
    local closest, minDist, valid = nil, math.huge, {}
    local murdererPos = nil
    if Murderer then
        local m = Players:FindFirstChild(Murderer)
        if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
            murdererPos = m.Character.HumanoidRootPart.Position
        end
    end
    for _, coin in pairs(container:GetChildren()) do
        if coin.Name == "Coin_Server" and coin:FindFirstChild("TouchInterest") and CoinAttribute(coin) then
            local pos = coin:FindFirstChild("CoinVisual") and coin.CoinVisual.Position or coin.Position
            local dist = (hrp.Position - pos).Magnitude
            if murdererPos and (pos - murdererPos).Magnitude < 25 then continue end
            if dist < minDist then minDist = dist closest = coin end
            table.insert(valid, coin)
        end
    end
    if Config.FarmMode == "Nearest" then return closest
    else return #valid > 0 and valid[math.random(1, #valid)] or closest end
end

local function AutoFarmLoop()
    while Config.AutoFarm and task.wait() do
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not humanoid or humanoid.Health <= 0 then return end

            if TrackCoinBag() then
                if Config.AutoReset and not hasResetThisBag then
                    hasResetThisBag = true
                    humanoid.Health = 0
                end
                return
            else
                hasResetThisBag = false
            end

            if not IsAlive(LocalPlayer) then return end
            local coin = findCoin(hrp)
            if coin then
                BodyVelocityControl(true)
                local pos = coin:FindFirstChild("CoinVisual") and coin.CoinVisual.Position or coin.Position
                local target = CFrame.new(pos + Vector3.new(0, 1.5, 0))
                local dist = (hrp.Position - pos).Magnitude
                if dist > 180 then
                    hrp.CFrame = target * CFrame.new(0, 8, 0)
                    task.wait(1.2)
                end
                tween_teleport(target, 22)
            end
        end)
    end
    BodyVelocityControl(false)
end

local function ManageChams()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        local hl = player.Character:FindFirstChild("VertexHighlight")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "VertexHighlight"
            hl.FillTransparency = 0.45
            hl.OutlineTransparency = 0
            hl.Parent = player.Character
            highlightedPlayers[player] = hl
        end
        if IsAlive(player) then
            local role = roles[player.Name]
            if role then
                if role.Role == "Murderer" then
                    hl.FillColor = Color3.fromRGB(255, 60, 60)
                    hl.OutlineColor = Color3.fromRGB(180, 0, 0)
                elseif role.Role == "Sheriff" or role.Role == "Hero" then
                    hl.FillColor = Color3.fromRGB(60, 120, 255)
                    hl.OutlineColor = Color3.fromRGB(0, 60, 200)
                else
                    hl.FillColor = Color3.fromRGB(80, 255, 130)
                    hl.OutlineColor = Color3.fromRGB(0, 180, 70)
                end
            end
        else
            hl.FillColor = Color3.fromRGB(160, 160, 160)
            hl.OutlineColor = Color3.fromRGB(100, 100, 100)
        end
    end
end

--==================== UI MOBILE ====================--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "The cat factory"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Taille adaptée téléphone
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 420)
Main.Position = UDim2.new(0.5, -150, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(40, 40, 55)
stroke.Thickness = 1.2

-- Title
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -45, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "The cat factory"
Title.TextColor3 = Color3.fromRGB(235, 235, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 28, 0, 28)
Close.Position = UDim2.new(1, -34, 0.5, -14)
Close.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Close.Text = "✕"
Close.TextColor3 = Color3.fromRGB(255, 90, 90)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 13
Close.Parent = TitleBar
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

Close.MouseButton1Click:Connect(function()
    FlingActive = false
    FlingMurdererActive = false
    FlingSheriffActive = false
    Flying = false
    StopFly()
    ScreenGui:Destroy()
end)

-- Bouton flottant Hide UI (remplace LeftControl)
local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 42, 0, 42)
HideBtn.Position = UDim2.new(1, -52, 0, 12)
HideBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
HideBtn.Text = "👁"
HideBtn.TextSize = 18
HideBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.Parent = ScreenGui
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 12)
local hideStroke = Instance.new("UIStroke", HideBtn)
hideStroke.Color = Color3.fromRGB(60, 60, 80)
hideStroke.Thickness = 1

HideBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Bouton flottant Silent Aim
local SilentAimBtn = Instance.new("TextButton")
SilentAimBtn.Size = UDim2.new(0, 70, 0, 36)
SilentAimBtn.Position = UDim2.new(1, -82, 0, 62)
SilentAimBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
SilentAimBtn.Text = "Silent Aim"
SilentAimBtn.TextSize = 12
SilentAimBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
SilentAimBtn.Font = Enum.Font.GothamBold
SilentAimBtn.Visible = Config.ShowSilentAimButton
SilentAimBtn.Parent = ScreenGui
Instance.new("UICorner", SilentAimBtn).CornerRadius = UDim.new(0, 10)

local function UpdateSilentAimButton()
    if Config.SilentAim then
        SilentAimBtn.BackgroundColor3 = Color3.fromRGB(90, 200, 130)
        SilentAimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SilentAimBtn.Text = "Silent ON"
    else
        SilentAimBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        SilentAimBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
        SilentAimBtn.Text = "Silent Aim"
    end
end

SilentAimBtn.MouseButton1Click:Connect(function()
    Config.SilentAim = not Config.SilentAim
    UpdateSilentAimButton()
    
    if Config.SilentAim then
        if Connections.Silent then Connections.Silent:Disconnect() end
        Connections.Silent = RunService.Heartbeat:Connect(function()
            if not Config.SilentAim or Sheriff ~= LocalPlayer.Name then return end
            local char = LocalPlayer.Character
            if not char then return end
            local gun = char:FindFirstChild("Gun")
            if gun and not shootConnection then
                shootConnection = gun.Activated:Connect(function() ShootMurderer(false) end)
            elseif not gun and shootConnection then
                shootConnection:Disconnect()
                shootConnection = nil
            end
        end)
    else
        if Connections.Silent then Connections.Silent:Disconnect() Connections.Silent = nil end
        if shootConnection then shootConnection:Disconnect() shootConnection = nil end
    end
end)

-- Tabs
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -12, 0, 30)
TabBar.Position = UDim2.new(0, 6, 0, 44)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 3)
TabLayout.Parent = TabBar

local Pages = {}
local CurrentPage = nil

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 46, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -12, 1, -82)
    page.Position = UDim2.new(0, 6, 0, 78)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 90)
    page.CanvasSize = UDim2.new(0, 0, 0, 700)
    page.Visible = false
    page.Parent = Main

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 5)
    list.Parent = page

    Pages[name] = {Button = btn, Page = page}

    btn.MouseButton1Click:Connect(function()
        if CurrentPage then
            Pages[CurrentPage].Page.Visible = false
            Pages[CurrentPage].Button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            Pages[CurrentPage].Button.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
        CurrentPage = name
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(70, 90, 200)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    return page
end

local function CreateToggle(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 235)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 38, 0, 20)
    btn.Position = UDim2.new(1, -46, 0.5, -10)
    btn.BackgroundColor3 = default and Color3.fromRGB(90, 200, 130) or Color3.fromRGB(50, 50, 60)
    btn.Text = ""
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(90, 200, 130) or Color3.fromRGB(50, 50, 60)
        callback(state)
    end)
end

local function CreateButton(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(220, 220, 240)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
end

local function CreateSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 235)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 140, 255)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            label.Text = name .. ": " .. value
            callback(value)
        end
    end)
end

-- Create Pages
local MainPage = CreateTab("Main")
local CombatPage = CreateTab("Combat")
local MovePage = CreateTab("Move")
local VisualPage = CreateTab("Visual")
local TPPage = CreateTab("TP")
local FlingPage = CreateTab("Fling")

-- Open first tab
Pages["Main"].Button.BackgroundColor3 = Color3.fromRGB(70, 90, 200)
Pages["Main"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["Main"].Page.Visible = true
CurrentPage = "Main"

--======== MAIN PAGE ========--
CreateToggle(MainPage, "Auto Farm", false, function(v)
    Config.AutoFarm = v
    if v then
        task.spawn(AutoFarmLoop)
        Connections.NoclipFarm = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if Connections.NoclipFarm then Connections.NoclipFarm:Disconnect() end
        BodyVelocityControl(false)
    end
end)

CreateToggle(MainPage, "Farm Mode: Nearest", true, function(v)
    Config.FarmMode = v and "Nearest" or "Randomize"
end)

CreateToggle(MainPage, "Auto Reset (bag full)", false, function(v)
    Config.AutoReset = v
end)

CreateToggle(MainPage, "Auto Grab Gun", false, function(v)
    Config.AutoGrab = v
    if v then
        Connections.Grab = RunService.Heartbeat:Connect(function()
            if not Config.AutoGrab then return end
            pcall(function()
                if Murderer and Murderer ~= LocalPlayer.Name and IsAlive(LocalPlayer) and findGunDrop() then
                    local drop = findGunDrop()
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if drop and hrp then drop.CFrame = hrp.CFrame end
                end
            end)
        end)
    else
        if Connections.Grab then Connections.Grab:Disconnect() end
    end
end)

CreateToggle(MainPage, "Dodge Knife", false, function(v)
    Config.DodgeKnife = v
    if v then
        Connections.Dodge = RunService.Heartbeat:Connect(function()
            if not Config.DodgeKnife then return end
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name == "ThrowingKnife" then
                        local blade = obj:FindFirstChild("BladePosition")
                        if blade and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            if (blade.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 16 then
                                local old = LocalPlayer.Character.HumanoidRootPart.CFrame
                                LocalPlayer.Character.HumanoidRootPart.CFrame = old + Vector3.new(0, 90, 0)
                                task.wait(0.18)
                                LocalPlayer.Character.HumanoidRootPart.CFrame = old
                            end
                        end
                    end
                end
            end)
        end)
    else
        if Connections.Dodge then Connections.Dodge:Disconnect() end
    end
end)

--======== COMBAT PAGE ========--
CreateToggle(CombatPage, "Kill Aura", false, function(v)
    Config.KillAura = v
    if v then
        Connections.Aura = RunService.Heartbeat:Connect(function()
            if not Config.KillAura or Murderer ~= LocalPlayer.Name then return end
            pcall(function()
                local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
                if not knife then return end
                Equip("Knife")
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and IsAlive(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= Config.AuraDistance then
                            LocalPlayer.Character.Knife.Events.HandleTouched:FireServer(player.Character.HumanoidRootPart)
                        end
                    end
                end
            end)
        end)
    else
        if Connections.Aura then Connections.Aura:Disconnect() end
    end
end)

CreateSlider(CombatPage, "Aura Distance", 5, 40, 15, function(v)
    Config.AuraDistance = v
end)

CreateToggle(CombatPage, "Auto Kill All", false, function(v)
    Config.KillAll = v
    if v then
        Connections.KillAll = RunService.Heartbeat:Connect(function()
            if not Config.KillAll or Murderer ~= LocalPlayer.Name then return end
            if TrackCoinBag() or not Config.AutoFarm then
                pcall(function()
                    Equip("Knife")
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.Knife.Events.HandleTouched:FireServer(player.Character.HumanoidRootPart)
                        end
                    end
                end)
            end
        end)
    else
        if Connections.KillAll then Connections.KillAll:Disconnect() end
    end
end)

CreateToggle(CombatPage, "Silent Aim", false, function(v)
    Config.SilentAim = v
    UpdateSilentAimButton()
    
    if v then
        Connections.Silent = RunService.Heartbeat:Connect(function()
            if not Config.SilentAim or Sheriff ~= LocalPlayer.Name then return end
            local char = LocalPlayer.Character
            if not char then return end
            local gun = char:FindFirstChild("Gun")
            if gun and not shootConnection then
                shootConnection = gun.Activated:Connect(function() ShootMurderer(false) end)
            elseif not gun and shootConnection then
                shootConnection:Disconnect()
                shootConnection = nil
            end
        end)
    else
        if Connections.Silent then Connections.Silent:Disconnect() end
        if shootConnection then shootConnection:Disconnect() shootConnection = nil end
    end
end)

-- Option pour afficher / cacher le bouton Silent Aim flottant
CreateToggle(CombatPage, "Show Silent Aim Button", true, function(v)
    Config.ShowSilentAimButton = v
    SilentAimBtn.Visible = v
end)

CreateToggle(CombatPage, "Auto Shoot Murderer", false, function(v)
    Config.AutoShoot = v
    if v then
        Connections.AutoShoot = RunService.Heartbeat:Connect(function()
            if not Config.AutoShoot or Sheriff ~= LocalPlayer.Name then return end
            if not Murderer then return end
            local murderer = Players:FindFirstChild(Murderer)
            if murderer and isPlayerVisible(murderer) and (TrackCoinBag() or not Config.AutoFarm) then
                Equip("Gun")
                ShootMurderer(false)
            end
        end)
    else
        if Connections.AutoShoot then Connections.AutoShoot:Disconnect() end
    end
end)

CreateToggle(CombatPage, "Blatant Kill Murderer", false, function(v)
    Config.BlatantKill = v
    if v then
        Connections.Blatant = RunService.Heartbeat:Connect(function()
            if not Config.BlatantKill or Sheriff ~= LocalPlayer.Name then return end
            if TrackCoinBag() or not Config.AutoFarm then
                Equip("Gun")
                ShootMurderer(true)
            end
        end)
    else
        if Connections.Blatant then Connections.Blatant:Disconnect() end
    end
end)

--======== MOVE PAGE ========--
CreateToggle(MovePage, "Fly", false, function(v)
    Config.Fly = v
    Flying = v
    if v then StartFly() else StopFly() end
end)

CreateSlider(MovePage, "Fly Speed", 20, 150, 50, function(v)
    FlySpeed = v
end)

CreateToggle(MovePage, "WalkSpeed", false, function(v)
    Config.WalkSpeed = v
    if v then
        Connections.Speed = RunService.Heartbeat:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = Config.WalkSpeedValue end
        end)
    else
        if Connections.Speed then Connections.Speed:Disconnect() end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

CreateSlider(MovePage, "Walk Speed Value", 16, 50, 22, function(v)
    Config.WalkSpeedValue = v
end)

CreateToggle(MovePage, "Noclip", false, function(v)
    Config.Noclip = v
    if v then
        Connections.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if Connections.Noclip then Connections.Noclip:Disconnect() end
    end
end)

CreateToggle(MovePage, "Anti Fling", false, function(v)
    Config.AntiFling = v
    if v then
        Connections.AntiFling = RunService.Stepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
    else
        if Connections.AntiFling then Connections.AntiFling:Disconnect() end
    end
end)

CreateToggle(MovePage, "Anti AFK", false, function(v)
    Config.AntiAFK = v
    if v then
        Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if Connections.AntiAFK then Connections.AntiAFK:Disconnect() end
    end
end)

--======== VISUAL PAGE ========--
CreateToggle(VisualPage, "Player Chams", false, function(v)
    Config.Chams = v
    if v then
        Connections.Chams = RunService.Heartbeat:Connect(ManageChams)
    else
        if Connections.Chams then Connections.Chams:Disconnect() end
        for _, hl in pairs(highlightedPlayers) do if hl then hl:Destroy() end end
        highlightedPlayers = {}
    end
end)

CreateToggle(VisualPage, "Gun Cham", false, function(v)
    Config.GunCham = v
    if v then
        Connections.GunCham = RunService.Heartbeat:Connect(function()
            local drop = findGunDrop()
            if drop and not drop:FindFirstChild("GunESP") then
                local hl = Instance.new("Highlight")
                hl.Name = "GunESP"
                hl.FillColor = Color3.fromRGB(100, 255, 50)
                hl.OutlineColor = Color3.fromRGB(0, 180, 0)
                hl.FillTransparency = 0.4
                hl.Parent = drop
            end
        end)
    else
        if Connections.GunCham then Connections.GunCham:Disconnect() end
    end
end)

--======== TP PAGE ========--
CreateButton(TPPage, "TP Lobby", function()
    for _, folder in pairs(workspace:GetChildren()) do
        if string.find(string.lower(folder.Name), "lobby") then
            for _, obj in pairs(folder:GetDescendants()) do
                if obj:IsA("SpawnLocation") then
                    tween_teleport(CFrame.new(obj.Position + Vector3.new(0, 5, 0)), 6000)
                    return
                end
            end
        end
    end
end)

CreateButton(TPPage, "TP Map", function()
    local spawns = TargetModel("Spawns")
    if not spawns then Notify("Map introuvable") return end
    for _, spawn in pairs(spawns:GetDescendants()) do
        if spawn:IsA("BasePart") or spawn:IsA("SpawnLocation") then
            tween_teleport(spawn.CFrame * CFrame.new(0, 5, 0), 6000)
            return
        end
    end
end)

CreateButton(TPPage, "TP Murderer", function()
    if not Murderer then return Notify("Pas de Murderer") end
    local plr = Players:FindFirstChild(Murderer)
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
    end
end)

CreateButton(TPPage, "TP Sheriff", function()
    if not Sheriff then return Notify("Pas de Sheriff") end
    local plr = Players:FindFirstChild(Sheriff)
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
    end
end)

--======== FLING PAGE ========--
CreateToggle(FlingPage, "Fling Murderer", false, function(v)
    FlingMurdererActive = v
    if v then
        task.spawn(function()
            while FlingMurdererActive do
                if Murderer and Murderer ~= LocalPlayer.Name then
                    local target = Players:FindFirstChild(Murderer)
                    if target and target.Character then SkidFling(target) end
                end
                task.wait(0.3)
            end
        end)
    end
end)

CreateToggle(FlingPage, "Fling Sheriff", false, function(v)
    FlingSheriffActive = v
    if v then
        task.spawn(function()
            while FlingSheriffActive do
                if Sheriff and Sheriff ~= LocalPlayer.Name then
                    local target = Players:FindFirstChild(Sheriff)
                    if target and target.Character then SkidFling(target) end
                end
                task.wait(0.3)
            end
        end)
    end
end)

local FlingStatus = Instance.new("TextLabel")
FlingStatus.Size = UDim2.new(1, 0, 0, 18)
FlingStatus.BackgroundTransparency = 1
FlingStatus.Text = "  0 joueur(s) sélectionné(s)"
FlingStatus.TextColor3 = Color3.fromRGB(180, 180, 200)
FlingStatus.Font = Enum.Font.Gotham
FlingStatus.TextSize = 11
FlingStatus.TextXAlignment = Enum.TextXAlignment.Left
FlingStatus.Parent = FlingPage

local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Size = UDim2.new(1, 0, 0, 120)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
PlayerListFrame.Parent = FlingPage
Instance.new("UICorner", PlayerListFrame).CornerRadius = UDim.new(0, 8)

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, -6, 1, -6)
PlayerScroll.Position = UDim2.new(0, 3, 0, 3)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.ScrollBarThickness = 3
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.Parent = PlayerListFrame

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Padding = UDim.new(0, 3)
PlayerListLayout.Parent = PlayerScroll

local function UpdateFlingStatus()
    local count = 0
    for _ in pairs(SelectedTargets) do count = count + 1 end
    FlingStatus.Text = FlingActive and ("  Fling en cours ("..count..")") or ("  "..count.." joueur(s) sélectionné(s)")
    FlingStatus.TextColor3 = FlingActive and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(180, 180, 200)
end

local function RefreshPlayerList()
    for _, child in pairs(PlayerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local y = 0
    local list = Players:GetPlayers()
    table.sort(list, function(a,b) return a.Name:lower() < b.Name:lower() end)
    for _, player in ipairs(list) do
        if player ~= LocalPlayer then
            local entry = Instance.new("Frame")
            entry.Size = UDim2.new(1, 0, 0, 24)
            entry.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
            entry.Parent = PlayerScroll
            Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 6)

            local check = Instance.new("TextButton")
            check.Size = UDim2.new(0, 20, 0, 20)
            check.Position = UDim2.new(0, 3, 0.5, -10)
            check.BackgroundColor3 = SelectedTargets[player.Name] and Color3.fromRGB(90, 200, 130) or Color3.fromRGB(55, 55, 65)
            check.Text = SelectedTargets[player.Name] and "✓" or ""
            check.TextColor3 = Color3.fromRGB(255,255,255)
            check.Font = Enum.Font.GothamBold
            check.TextSize = 12
            check.Parent = entry
            Instance.new("UICorner", check).CornerRadius = UDim.new(0, 5)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -28, 1, 0)
            nameLabel.Position = UDim2.new(0, 26, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = entry

            check.MouseButton1Click:Connect(function()
                if SelectedTargets[player.Name] then
                    SelectedTargets[player.Name] = nil
                    check.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
                    check.Text = ""
                else
                    SelectedTargets[player.Name] = player
                    check.BackgroundColor3 = Color3.fromRGB(90, 200, 130)
                    check.Text = "✓"
                end
                UpdateFlingStatus()
            end)
            y = y + 27
        end
    end
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, y + 5)
end

CreateButton(FlingPage, "Refresh Player List", function()
    RefreshPlayerList()
    UpdateFlingStatus()
end)

CreateButton(FlingPage, "START FLING TARGET", function()
    if FlingActive then return end
    local count = 0
    for _ in pairs(SelectedTargets) do count = count + 1 end
    if count == 0 then Notify("Aucun joueur sélectionné") return end
    FlingActive = true
    UpdateFlingStatus()
    Notify("Fling démarré ("..count..")")
    task.spawn(function()
        while FlingActive do
            for name, player in pairs(SelectedTargets) do
                if not FlingActive then break end
                if player and player.Parent then
                    SkidFling(player)
                    task.wait(0.15)
                else
                    SelectedTargets[name] = nil
                end
            end
            UpdateFlingStatus()
            task.wait(0.4)
        end
    end)
end)

CreateButton(FlingPage, "STOP FLING TARGET", function()
    FlingActive = false
    UpdateFlingStatus()
    Notify("Fling arrêté")
end)

-- Role updater
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            Murderer = Fetch("Knife")
            Sheriff = Fetch("Gun")
            local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
            if remote then roles = remote:InvokeServer() end
        end)
    end
end)

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    RefreshPlayerList()
end)
Players.PlayerRemoving:Connect(function(player)
    SelectedTargets[player.Name] = nil
    RefreshPlayerList()
    UpdateFlingStatus()
end)

RefreshPlayerList()
UpdateFlingStatus()
UpdateSilentAimButton()

-- LeftControl toujours dispo (PC)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Main.Visible = not Main.Visible
    end
end)

Notify("The cat factory • Mobile ready • Bouton 👁 pour ouvrir/fermer")
