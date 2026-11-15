local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local HitboxSize = Vector3.new(20, 20, 20)
local HitboxColor = Color3.fromRGB(255, 0, 0)
local HitboxTransparency = 0.5

local function CreateHitbox(player, character)
    if player == LocalPlayer then
        return
    end

    local root = character:WaitForChild("HumanoidRootPart")

    if character:FindFirstChild("CustomHitbox") then
        return
    end

    local hitbox = Instance.new("Part")
    hitbox.Name = "CustomHitbox"
    hitbox.Size = HitboxSize
    hitbox.Color = HitboxColor
    hitbox.Transparency = HitboxTransparency
    hitbox.Material = Enum.Material.Neon
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.Massless = true

    hitbox.CFrame = root.CFrame
    hitbox.Parent = character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = hitbox
    weld.Parent = hitbox
end

local function SetupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        CreateHitbox(player, character)
    end)

    if player.Character then
        task.spawn(CreateHitbox, player, player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayer(player)
end

Players.PlayerAdded:Connect(SetupPlayer)
