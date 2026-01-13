--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// STATES
local flyEnabled = false
local noclipEnabled = false
local autoCoinEnabled = false
local espEnabled = false
local tpMurderLoop = false
local tpSheriffLoop = false

local flySpeed = 60
local flyBV, flyBG
local espBoxes = {}
local murderPlayer, sheriffPlayer

--// UI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 450, 0, 600)
Frame.Position = UDim2.new(0.5, -225, 0.5, -300)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "Viernoi86 Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

-- Y tracker
local y = 40
local function createButton(name, callback)
	local button = Instance.new("TextButton", Frame)
	button.Size = UDim2.new(0, 150, 0, 30)
	button.Position = UDim2.new(0, 10, 0, y)
	button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	button.Text = name
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 14
	y += 40
	button.MouseButton1Click:Connect(callback)
	return button
end

local function createCheckbox(labelText, initState, posY, callback)
	local checkboxLabel = Instance.new("TextLabel", Frame)
	checkboxLabel.Size = UDim2.new(0, 100, 0, 30)
	checkboxLabel.Position = UDim2.new(0, 170, 0, posY)
	checkboxLabel.Text = labelText
	checkboxLabel.TextColor3 = Color3.fromRGB(255,255,255)
	checkboxLabel.BackgroundTransparency = 1
	checkboxLabel.TextSize = 14

	local box = Instance.new("TextButton", Frame)
	box.Size = UDim2.new(0, 30, 0, 30)
	box.Position = UDim2.new(0, 270, 0, posY)
	box.Text = ""
	box.BackgroundColor3 = initState and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

	box.MouseButton1Click:Connect(function()
		initState = not initState
		box.BackgroundColor3 = initState and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
		callback(initState)
	end)
	return box
end

--// =====================
--// ESP MM2 OPTIMISE
--// =====================
local espConnection
local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local roleColor = Color3.fromRGB(0,255,0)
			if player == murderPlayer then
				roleColor = Color3.fromRGB(255,0,0)
			elseif player == sheriffPlayer then
				roleColor = Color3.fromRGB(0,0,255)
			end
			if not espBoxes[player] then
				local highlight = Instance.new("Highlight")
				highlight.Name = "ESPHighlight"
				highlight.Adornee = player.Character
				highlight.FillTransparency = 0.5
				highlight.OutlineTransparency = 0
				highlight.OutlineColor = Color3.fromRGB(255,255,255)
				highlight.Parent = player.Character
				espBoxes[player] = highlight
			end
			espBoxes[player].FillColor = roleColor
		end
	end
end

local function toggleESP()
	espEnabled = not espEnabled
	if espEnabled then
		espConnection = task.spawn(function()
			while espEnabled do
				updateESP()
				task.wait(0.15)
			end
		end)
	else
		if espConnection then task.cancel(espConnection) espConnection=nil end
		for _, h in pairs(espBoxes) do if h then h:Destroy() end end
		espBoxes = {}
	end
end

--// =====================
--// FLY (INFINITY YIELD STYLE)
--// =====================
local function startFly()
	local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = c:WaitForChild("HumanoidRootPart")
	local hum = c:WaitForChild("Humanoid")
	hum.PlatformStand = true
	hum:ChangeState(Enum.HumanoidStateType.Physics)

	flyBV = Instance.new("BodyVelocity", hrp)
	flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)

	flyBG = Instance.new("BodyGyro", hrp)
	flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
end

local function stopFly()
	local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = c:WaitForChild("Humanoid")
	hum.PlatformStand = false
	hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	if flyBV then flyBV:Destroy() flyBV=nil end
	if flyBG then flyBG:Destroy() flyBG=nil end
end

RunService.RenderStepped:Connect(function()
	if flyEnabled and flyBV and flyBG then
		local dir = Vector3.zero
		local cam = Camera
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
		flyBV.Velocity = dir * flySpeed
		flyBG.CFrame = cam.CFrame
	end
end)

--// =====================
--// NOCLIP
--// =====================
local noclipConnection
local function toggleNoclip()
	noclipEnabled = not noclipEnabled
	if noclipEnabled then
		noclipConnection = RunService.Stepped:Connect(function()
			local c = LocalPlayer.Character
			if c then
				for _, part in pairs(c:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	else
		if noclipConnection then noclipConnection:Disconnect() noclipConnection=nil end
		local c = LocalPlayer.Character
		if c then
			for _, part in pairs(c:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
end

--// =====================
--// AUTO COIN SAFE
--// =====================
RunService.Heartbeat:Connect(function()
	if not autoCoinEnabled then return end
	local c = LocalPlayer.Character
	if not c or not c:FindFirstChild("HumanoidRootPart") then return end
	local hrp = c.HumanoidRootPart
	for _, container in pairs(workspace:GetChildren()) do
		if container.Name == "CoinContainer" then
			for _, coin in pairs(container:GetChildren()) do
				if coin:IsA("BasePart") and (coin.Position - hrp.Position).Magnitude <= 15 then
					coin.CFrame = hrp.CFrame
				end
			end
		end
	end
end)

--// =====================
--// TP Murder/Sheriff
--// =====================
local function tpToPlayer(role)
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			if role == "Murder" and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
				LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
				return
			elseif role == "Sheriff" and (p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")) then
				LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
				return
			end
		end
	end
end

RunService.Heartbeat:Connect(function()
	if tpMurderLoop then tpToPlayer("Murder") end
	if tpSheriffLoop then tpToPlayer("Sheriff") end
end)

--// =====================
--// AVATARS Murder / Sheriff
--// =====================
local function updateAvatars()
	murderPlayer = nil
	sheriffPlayer = nil
	for _, p in pairs(Players:GetPlayers()) do
		if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
			murderPlayer = p
		elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
			sheriffPlayer = p
		end
	end
end

local avatarFrame = Instance.new("Frame", Frame)
avatarFrame.Size = UDim2.new(0, 200, 0, 100)
avatarFrame.Position = UDim2.new(0, 180, 0, 40)
avatarFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)

local murderImg = Instance.new("ImageLabel", avatarFrame)
murderImg.Size = UDim2.new(0,50,0,50)
murderImg.Position = UDim2.new(0,5,0,5)

local murderLabel = Instance.new("TextLabel", avatarFrame)
murderLabel.Size = UDim2.new(0,100,0,20)
murderLabel.Position = UDim2.new(0,60,0,5)
murderLabel.BackgroundTransparency = 1
murderLabel.TextColor3 = Color3.fromRGB(255,0,0)
murderLabel.Text = "Murder"

local sheriffImg = Instance.new("ImageLabel", avatarFrame)
sheriffImg.Size = UDim2.new(0,50,0,50)
sheriffImg.Position = UDim2.new(0,5,0,55)

local sheriffLabel = Instance.new("TextLabel", avatarFrame)
sheriffLabel.Size = UDim2.new(0,100,0,20)
sheriffLabel.Position = UDim2.new(0,60,0,55)
sheriffLabel.BackgroundTransparency = 1
sheriffLabel.TextColor3 = Color3.fromRGB(0,0,255)
sheriffLabel.Text = "Sheriff"

RunService.Heartbeat:Connect(function()
	updateAvatars()
	if murderPlayer then
		murderImg.Image = Players:GetUserThumbnailAsync(murderPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	end
	if sheriffPlayer then
		sheriffImg.Image = Players:GetUserThumbnailAsync(sheriffPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	end
end)

--// BOUTONS
createButton("Fly", function() flyEnabled = not flyEnabled if flyEnabled then startFly() else stopFly() end end)
createButton("Noclip", toggleNoclip)
createButton("Grab The Gun", function()
	local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = c:WaitForChild("HumanoidRootPart")
	local gunDrop
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "GunDrop" then
			gunDrop = obj
			break
		end
	end
	if gunDrop then
		local original = hrp.CFrame
		hrp.CFrame = gunDrop.CFrame + Vector3.new(0,3,0)
		task.wait(0.2)
		hrp.CFrame = original
	end
end)
createButton("Auto Coins", function() autoCoinEnabled = not autoCoinEnabled end)
createButton("ESP MM2", toggleESP)
createButton("TP Murder", function() tpToPlayer("Murder") end)
createCheckbox("Loop TP Murder", tpMurderLoop, y, function(state) tpMurderLoop = state end)
createButton("TP Sheriff", function() tpToPlayer("Sheriff") end)
createCheckbox("Loop TP Sheriff", tpSheriffLoop, y+30, function(state) tpSheriffLoop = state end)

--// TOGGLE UI
UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.RightShift then
		Frame.Visible = not Frame.Visible
	end
end)

--// RESET FLY AU RESPAWN
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	if flyEnabled then
		flyEnabled = false
		stopFly()
	end
end)
