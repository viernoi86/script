local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedJumpGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 0
frame.Parent = screenGui
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
title.Text = "Modifier WalkSpeed & JumpPower"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Parent = frame
local function createInput(labelText, yPos)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 120, 0, 25)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 80, 0, 25)
    textBox.Position = UDim2.new(0, 140, 0, yPos)
    textBox.PlaceholderText = "Valeur"
    textBox.ClearTextOnFocus = false
    textBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextScaled = true
    textBox.Parent = frame
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 80, 0, 25)
    button.Position = UDim2.new(0, 140, 0, yPos + 30)
    button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    button.Text = "Appliquer"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Parent = frame
    return textBox, button
end
local speedBox, speedButton = createInput("WalkSpeed", 40)
local jumpBox, jumpButton = createInput("JumpPower", 90)
speedButton.MouseButton1Click:Connect(function()
    local speed = tonumber(speedBox.Text)
    if speed and speed > 0 then
        humanoid.WalkSpeed = speed
    else
        warn("Valeur WalkSpeed invalide")
    end
end)
jumpButton.MouseButton1Click:Connect(function()
    local jump = tonumber(jumpBox.Text)
    if jump and jump > 0 then
        humanoid.JumpPower = jump
    else
        warn("Valeur JumpPower invalide")
    end
end)
local dragging = false
local dragStart = nil
local startPos = nil
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        UserInputService.InputChanged:Connect(function(moveInput)
            if dragging and moveInput == input then
                local delta = moveInput.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
end)
