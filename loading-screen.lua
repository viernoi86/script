local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer

-- Création de l'écran
local gui = Instance.new("ScreenGui")
gui.Name = "LoadingScreen"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Fond
local background = Instance.new("Frame")
background.Size = UDim2.fromScale(1, 1)
background.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
background.BorderSizePixel = 0
background.Parent = gui

-- Image
local image = Instance.new("ImageLabel")
image.AnchorPoint = Vector2.new(0.5, 0.5)
image.Position = UDim2.fromScale(0.5, 0.43)
image.Size = UDim2.fromScale(0.3, 0.3)
image.BackgroundTransparency = 1
image.Image = "rbxassetid://95328507502465"
image.ScaleType = Enum.ScaleType.Fit
image.Parent = background

-- Texte
local text = Instance.new("TextLabel")
text.AnchorPoint = Vector2.new(0.5, 0.5)
text.Position = UDim2.fromScale(0.5, 0.72)
text.Size = UDim2.fromScale(0.5, 0.08)
text.BackgroundTransparency = 1
text.Text = "Chargement..."
text.TextColor3 = Color3.fromRGB(255, 255, 255)
text.TextScaled = true
text.Font = Enum.Font.GothamBold
text.Parent = background

-- Barre de chargement
local barBackground = Instance.new("Frame")
barBackground.AnchorPoint = Vector2.new(0.5, 0.5)
barBackground.Position = UDim2.fromScale(0.5, 0.82)
barBackground.Size = UDim2.fromScale(0.4, 0.025)
barBackground.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
barBackground.BorderSizePixel = 0
barBackground.Parent = background

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = barBackground

local bar = Instance.new("Frame")
bar.Size = UDim2.fromScale(0, 1)
bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bar.BorderSizePixel = 0
bar.Parent = barBackground

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = bar

-- Précharge l'image
ContentProvider:PreloadAsync({image})

-- Animation de chargement
for i = 0, 100 do
	text.Text = "Loading... " .. i .. "%"
	
	TweenService:Create(
		bar,
		TweenInfo.new(0.03, Enum.EasingStyle.Linear),
		{Size = UDim2.fromScale(i / 100, 1)}
	):Play()
	
	task.wait(0.03)
end

-- Petite pause
task.wait(0.5)

-- Disparition
local fadeInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

TweenService:Create(background, fadeInfo, {
	BackgroundTransparency = 1
}):Play()

TweenService:Create(image, fadeInfo, {
	ImageTransparency = 1
}):Play()

TweenService:Create(text, fadeInfo, {
	TextTransparency = 1
}):Play()

TweenService:Create(barBackground, fadeInfo, {
	BackgroundTransparency = 1
}):Play()

TweenService:Create(bar, fadeInfo, {
	BackgroundTransparency = 1
}):Play()

task.wait(0.8)
gui:Destroy()
