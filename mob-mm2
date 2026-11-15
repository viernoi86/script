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
local gunESPEnabled = false
local tpMurderLoop = false
local tpSheriffLoop = false

local flySpeed = 60
local flyBV, flyBG

local espBoxes = {}
local murderPlayer, sheriffPlayer

local espConnection
local gunESPConnection
local gunESPHighlight
local noclipConnection

--// UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "The cat factory"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Parent = ScreenGui
Frame.Size = UDim2.fromScale(0.88, 0.76)
Frame.Position = UDim2.fromScale(0.5, 0.5)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(250, 300)
sizeConstraint.MaxSize = Vector2.new(520, 650)
sizeConstraint.Parent = Frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 42)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "The cat factory"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = Title

-- Contenu défilant : les boutons restent accessibles sur les petits écrans.
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Parent = Frame
Content.Position = UDim2.new(0, 6, 0, 48)
Content.Size = UDim2.new(1, -12, 1, -54)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 5
Content.ScrollingDirection = Enum.ScrollingDirection.Y
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ClipsDescendants = true

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 4)
contentPadding.PaddingBottom = UDim.new(0, 8)
contentPadding.PaddingLeft = UDim.new(0, 4)
contentPadding.PaddingRight = UDim.new(0, 4)
contentPadding.Parent = Content

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 8)
contentLayout.Parent = Content

local y = 40

local function createButton(name, callback)
	local button = Instance.new("TextButton")
	button.Parent = Content
	button.Size = UDim2.new(1, -8, 0, 44)
	button.BackgroundColor3 = Color3.fromRGB(190, 35, 45)
	button.Text = name
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 16
	button.TextScaled = true
	button.Font = Enum.Font.GothamSemibold
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 7)
	buttonCorner.Parent = button
	button.Activated:Connect(callback)
	return button
end

local function createCheckbox(labelText, initState, posY, callback)
	local row = Instance.new("Frame")
	row.Parent = Content
	row.Size = UDim2.new(1, -8, 0, 42)
	row.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
	row.BorderSizePixel = 0
	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 7)
	rowCorner.Parent = row

	local checkboxLabel = Instance.new("TextLabel")
	checkboxLabel.Parent = row
	checkboxLabel.Size = UDim2.new(1, -58, 1, 0)
	checkboxLabel.Position = UDim2.new(0, 10, 0, 0)
	checkboxLabel.Text = labelText
	checkboxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	checkboxLabel.BackgroundTransparency = 1
	checkboxLabel.TextSize = 14
	checkboxLabel.TextScaled = true
	checkboxLabel.TextXAlignment = Enum.TextXAlignment.Left
	checkboxLabel.Font = Enum.Font.Gotham

	local box = Instance.new("TextButton")
	box.Parent = row
	box.Size = UDim2.new(0, 34, 0, 30)
	box.Position = UDim2.new(1, -44, 0.5, -15)
	box.Text = initState and "ON" or "OFF"
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.TextSize = 12
	box.Font = Enum.Font.GothamBold
	box.BorderSizePixel = 0
	box.BackgroundColor3 = initState and Color3.fromRGB(0, 160, 75) or Color3.fromRGB(180, 40, 40)
	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 6)
	boxCorner.Parent = box

	box.Activated:Connect(function()
		initState = not initState
		box.Text = initState and "ON" or "OFF"
		box.BackgroundColor3 = initState and Color3.fromRGB(0, 160, 75) or Color3.fromRGB(180, 40, 40)
		callback(initState)
	end)
	return box
end

--// =====================
--// ESP MM2
--// =====================

local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do

		if player ~= LocalPlayer
			and player.Character
			and player.Character:FindFirstChild("HumanoidRootPart") then

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
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

				highlight.Parent = player.Character

				espBoxes[player] = highlight
			end

			espBoxes[player].Adornee = player.Character
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

		if espConnection then
			task.cancel(espConnection)
			espConnection = nil
		end

		for player, highlight in pairs(espBoxes) do
			if highlight then
				highlight:Destroy()
			end
		end

		espBoxes = {}
	end
end

--// =====================
--// GUN ESP
--// =====================

local function removeGunESP()

	if gunESPHighlight then
		gunESPHighlight:Destroy()
		gunESPHighlight = nil
	end

end

local function findGunDrop()

	for _, obj in ipairs(workspace:GetDescendants()) do

		if obj:IsA("BasePart")
			and obj.Name == "GunDrop" then

			return obj
		end

	end

	return nil
end

local function updateGunESP()

	if not gunESPEnabled then
		return
	end

	local gunDrop = findGunDrop()

	if gunDrop then

		if not gunESPHighlight then

			gunESPHighlight = Instance.new("Highlight")

			gunESPHighlight.Name = "GunESP"
			gunESPHighlight.FillColor = Color3.fromRGB(0,170,255)
			gunESPHighlight.OutlineColor = Color3.fromRGB(255,255,255)

			gunESPHighlight.FillTransparency = 0.25
			gunESPHighlight.OutlineTransparency = 0

			gunESPHighlight.DepthMode =
				Enum.HighlightDepthMode.AlwaysOnTop

			gunESPHighlight.Parent = gunDrop
		end

		gunESPHighlight.Adornee = gunDrop

	else

		removeGunESP()

	end
end

local function toggleGunESP()

	gunESPEnabled = not gunESPEnabled

	if gunESPEnabled then

		gunESPConnection = RunService.Heartbeat:Connect(function()
			updateGunESP()
		end)

	else

		if gunESPConnection then
			gunESPConnection:Disconnect()
			gunESPConnection = nil
		end

		removeGunESP()
	end
end

--// =====================
--// FLY
--// =====================

local function startFly()

	local c = LocalPlayer.Character
		or LocalPlayer.CharacterAdded:Wait()

	local hrp = c:WaitForChild("HumanoidRootPart")
	local hum = c:WaitForChild("Humanoid")

	hum.PlatformStand = true
	hum:ChangeState(Enum.HumanoidStateType.Physics)

	flyBV = Instance.new("BodyVelocity")
	flyBV.Parent = hrp
	flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)

	flyBG = Instance.new("BodyGyro")
	flyBG.Parent = hrp
	flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
end

local function stopFly()

	local c = LocalPlayer.Character
		or LocalPlayer.CharacterAdded:Wait()

	local hum = c:WaitForChild("Humanoid")

	hum.PlatformStand = false
	hum:ChangeState(Enum.HumanoidStateType.GettingUp)

	if flyBV then
		flyBV:Destroy()
		flyBV = nil
	end

	if flyBG then
		flyBG:Destroy()
		flyBG = nil
	end
end

RunService.RenderStepped:Connect(function()

	if flyEnabled and flyBV and flyBG then

		local dir = Vector3.zero
		local cam = Camera

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			dir += cam.CFrame.LookVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			dir -= cam.CFrame.LookVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			dir -= cam.CFrame.RightVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			dir += cam.CFrame.RightVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			dir += Vector3.new(0,1,0)
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			dir -= Vector3.new(0,1,0)
		end

		flyBV.Velocity = dir * flySpeed
		flyBG.CFrame = cam.CFrame
	end

end)

--// =====================
--// NOCLIP
--// =====================

local function toggleNoclip()

	noclipEnabled = not noclipEnabled

	if noclipEnabled then

		noclipConnection = RunService.Stepped:Connect(function()

			local c = LocalPlayer.Character

			if c then

				for _, part in pairs(c:GetDescendants()) do

					if part:IsA("BasePart") then
						part.CanCollide = false
					end

				end
			end

		end)

	else

		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end

		local c = LocalPlayer.Character

		if c then

			for _, part in pairs(c:GetDescendants()) do

				if part:IsA("BasePart") then
					part.CanCollide = true
				end

			end

		end
	end
end

--// =====================
--// AUTO COIN
--// =====================

RunService.Heartbeat:Connect(function()

	if not autoCoinEnabled then
		return
	end

	local c = LocalPlayer.Character

	if not c
		or not c:FindFirstChild("HumanoidRootPart") then
		return
	end

	local hrp = c.HumanoidRootPart

	for _, container in pairs(workspace:GetChildren()) do

		if container.Name == "CoinContainer" then

			for _, coin in pairs(container:GetChildren()) do

				if coin:IsA("BasePart")
					and (coin.Position - hrp.Position).Magnitude <= 15 then

					coin.CFrame = hrp.CFrame
				end

			end
		end
	end
end)

--// =====================
--// TP MURDER / SHERIFF
--// =====================

local function tpToPlayer(role)

	for _, p in pairs(Players:GetPlayers()) do

		if p ~= LocalPlayer and p.Character then

			if role == "Murder"
				and (
					p.Backpack:FindFirstChild("Knife")
					or p.Character:FindFirstChild("Knife")
				) then

				if LocalPlayer.Character
					and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					and p.Character:FindFirstChild("HumanoidRootPart") then

					LocalPlayer.Character.HumanoidRootPart.CFrame =
						p.Character.HumanoidRootPart.CFrame
				end

				return

			elseif role == "Sheriff"
				and (
					p.Backpack:FindFirstChild("Gun")
					or p.Character:FindFirstChild("Gun")
				) then

				if LocalPlayer.Character
					and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					and p.Character:FindFirstChild("HumanoidRootPart") then

					LocalPlayer.Character.HumanoidRootPart.CFrame =
						p.Character.HumanoidRootPart.CFrame
				end

				return
			end
		end
	end
end

RunService.Heartbeat:Connect(function()

	if tpMurderLoop then
		tpToPlayer("Murder")
	end

	if tpSheriffLoop then
		tpToPlayer("Sheriff")
	end

end)

--// =====================
--// AVATARS
--// =====================

local function updateAvatars()

	murderPlayer = nil
	sheriffPlayer = nil

	for _, p in pairs(Players:GetPlayers()) do

		if p.Backpack:FindFirstChild("Knife")
			or (
				p.Character
				and p.Character:FindFirstChild("Knife")
			) then

			murderPlayer = p

		elseif p.Backpack:FindFirstChild("Gun")
			or (
				p.Character
				and p.Character:FindFirstChild("Gun")
			) then

			sheriffPlayer = p
		end
	end
end

local avatarFrame = Instance.new("Frame")
avatarFrame.Parent = Content
avatarFrame.Size = UDim2.new(1, -8, 0, 100)
avatarFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
avatarFrame.BorderSizePixel = 0
local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(0, 7)
avatarCorner.Parent = avatarFrame

local murderImg = Instance.new("ImageLabel")
murderImg.Parent = avatarFrame
murderImg.Size = UDim2.new(0, 42, 0, 42)
murderImg.Position = UDim2.new(0, 8, 0, 5)

local murderLabel = Instance.new("TextLabel")
murderLabel.Parent = avatarFrame
murderLabel.Size = UDim2.new(1, -65, 0, 28)
murderLabel.Position = UDim2.new(0, 58, 0, 5)
murderLabel.BackgroundTransparency = 1
murderLabel.TextColor3 = Color3.fromRGB(255,0,0)
murderLabel.Text = "Murder"

local sheriffImg = Instance.new("ImageLabel")
sheriffImg.Parent = avatarFrame
sheriffImg.Size = UDim2.new(0, 42, 0, 42)
sheriffImg.Position = UDim2.new(0, 8, 0, 53)

local sheriffLabel = Instance.new("TextLabel")
sheriffLabel.Parent = avatarFrame
sheriffLabel.Size = UDim2.new(1, -65, 0, 28)
sheriffLabel.Position = UDim2.new(0, 58, 0, 53)
sheriffLabel.BackgroundTransparency = 1
sheriffLabel.TextColor3 = Color3.fromRGB(0,0,255)
sheriffLabel.Text = "Sheriff"

RunService.Heartbeat:Connect(function()

	updateAvatars()

	if murderPlayer then

		murderImg.Image =
			Players:GetUserThumbnailAsync(
				murderPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size48x48
			)
	end

	if sheriffPlayer then

		sheriffImg.Image =
			Players:GetUserThumbnailAsync(
				sheriffPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size48x48
			)
	end
end)

--// =====================
--// TP MAP
--// =====================

local mapPositions = {

	["Hotel"] = CFrame.new(
		-98.87925720214844,
		294.7980041503906,
		8994.6396484375
	),

	["ResearchFacility"] = CFrame.new(
		-50.11008834838867,
		292.0980529785156,
		8949.22265625
	),

	["MilBase"] = CFrame.new(
		-82.31570434570312,
		207.98207092285156,
		9100.775390625
	),

	["Mansion2"] = CFrame.new(
		95.26039123535156,
		277.9229431152344,
		9053.8349609375
	),

	["Bank2"] = CFrame.new(
		-0.09985322505235672,
		311.4306640625,
		9010.900390625
	),

	["BioLab"] = CFrame.new(
		540.3889770507812,
		297.272216796875,
		9891.125
	),

	["Factory"] = CFrame.new(
		33.275352478027344,
		274.09454345703125,
		8994.3525390625
	),

	["Hospital3"] = CFrame.new(
		-3.5253841876983643,
		284.1068420410156,
		8977.275390625
	),

	["House2"] = CFrame.new(
		50.9669189453125,
		269.56195068359375,
		8937.494140625
	),

	["Office3"] = CFrame.new(
		-45.296619415283203,
		304.74822998046875,
		9056.814453125
	),

	["PoliceStation"] = CFrame.new(
		-64.099609375,
		274.24798583984375,
		9043.1025390625
	),

	["Workplace"] = CFrame.new(
		-68.583450317382812,
		291.772216796875,
		9056.783203125
	)
}

local function getCurrentMap()

	for mapName, _ in pairs(mapPositions) do

		local map = workspace:FindFirstChild(mapName, true)

		if map then
			return mapName
		end
	end

	return nil
end

--// =====================
--// BOUTONS
--// =====================

createButton("Fly", function()

	flyEnabled = not flyEnabled

	if flyEnabled then
		startFly()
	else
		stopFly()
	end
end)

createButton("Noclip", toggleNoclip)

createButton("Grab The Gun", function()

	local c = LocalPlayer.Character
		or LocalPlayer.CharacterAdded:Wait()

	local hrp = c:WaitForChild("HumanoidRootPart")

	local gunDrop

	for _, obj in ipairs(workspace:GetDescendants()) do

		if obj:IsA("BasePart")
			and obj.Name == "GunDrop" then

			gunDrop = obj
			break
		end
	end

	if gunDrop then

		local original = hrp.CFrame

		hrp.CFrame =
			gunDrop.CFrame + Vector3.new(0,3,0)

		task.wait(0.2)

		hrp.CFrame = original
	end
end)

createButton("Auto Farm", function()

	local autoFarmOk, autoFarmErr = pcall(function()

		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/viernoi86/script/refs/heads/main/mm2%20auto-farm"
			)
		)()

	end)

	if not autoFarmOk then
		warn("Erreur au lancement d'Auto Farm : " .. tostring(autoFarmErr))
	end

	local antiAFKOk, antiAFKErr = pcall(function()

		loadstring(
			game:HttpGet(
				"https://rawscripts.net/raw/Universal-Script-AntiAFK-script-18076"
			)
		)()

	end)

	if not antiAFKOk then
		warn("Erreur au lancement d'Anti-AFK : " .. tostring(antiAFKErr))
	end
end)

createButton("ESP MM2", toggleESP)

createButton("Gun ESP", toggleGunESP)

createButton("TP Murder", function()
	tpToPlayer("Murder")
end)

createCheckbox(
	"Loop TP Murder",
	tpMurderLoop,
	y,
	function(state)
		tpMurderLoop = state
	end
)

createButton("TP Sheriff", function()
	tpToPlayer("Sheriff")
end)

createCheckbox(
	"Loop TP Sheriff",
	tpSheriffLoop,
	y + 30,
	function(state)
		tpSheriffLoop = state
	end
)

--// =====================
--// TP LOBBY
--// =====================

createButton("TP Lobby", function()

	local player = Players.LocalPlayer

	local character =
		player.Character
		or player.CharacterAdded:Wait()

	character:WaitForChild("HumanoidRootPart").CFrame =
		CFrame.new(
			14.351324988769531,
			504.818115234375,
			-3.2513725757598877
		)
end)

--// =====================
--// TP MAP
--// =====================

createButton("TP Map", function()

	local player = Players.LocalPlayer

	local character =
		player.Character
		or player.CharacterAdded:Wait()

	local hrp =
		character:WaitForChild("HumanoidRootPart")

	local currentMap = getCurrentMap()

	if currentMap
		and mapPositions[currentMap] then

		hrp.CFrame =
			mapPositions[currentMap]

	else

		warn("Map introuvable")
	end
end)

--// =====================
--// BOUTON FLOTTANT : AFFICHER / MASQUER LE GUI
--// =====================

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "OpenCloseButton"
toggleButton.Parent = ScreenGui
toggleButton.Size = UDim2.fromOffset(54, 54)
toggleButton.Position = UDim2.new(1, -72, 0.35, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(190, 35, 45)
toggleButton.Text = "CAT"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 15
toggleButton.Font = Enum.Font.GothamBold
toggleButton.BorderSizePixel = 0
toggleButton.Active = true
toggleButton.ZIndex = 10

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

-- Déplacement à la souris ou au doigt.
local dragging = false
local dragStart = nil
local startPosition = nil
local wasDragged = false

toggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		wasDragged = false
		dragStart = input.Position
		startPosition = toggleButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart
		if delta.Magnitude > 6 then
			wasDragged = true
		end
		toggleButton.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

toggleButton.Activated:Connect(function()
	if not wasDragged then
		Frame.Visible = not Frame.Visible
	end
end)

--// =====================
--// RESET FLY AU RESPAWN
--// =====================

LocalPlayer.CharacterAdded:Connect(function()

	task.wait(1)

	if flyEnabled then

		flyEnabled = false
		stopFly()
	end

	if gunESPEnabled then
		removeGunESP()
	end
end)
