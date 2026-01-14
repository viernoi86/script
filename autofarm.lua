-- Crée le ScreenGui
local gui = Instance.new("ScreenGui")
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Crée le bouton
local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 120, 0, 50)
button.Position = UDim2.new(0.5, -60, 0.5, -25)
button.Text = "Auto farm 1 round"
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BorderSizePixel = 0

-- Arrondir le bouton
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = button

-- Print quand on clique
button.MouseButton1Click:Connect(function()
	-- v2 Made By Zynic
local Octree = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sleitnick/rbxts-octo-tree/main/src/init.lua", true))()
local rt = {} -- Removable table
rt.Players = game:GetService("Players")
rt.player = rt.Players.LocalPlayer

rt.coinContainer = nil
rt.octree = Octree.new()
rt.Material = Enum.Material.Ice
rt.TpBackToStart = true
rt.radius = 200 -- Radius to search for coins
rt.walkspeed = 30 -- speed at which you will go to a coin measured in walkspeed
rt.touchedCoins = {} -- Table to track touched coins
rt.positionChangeConnections = setmetatable({}, { __mode = "v" }) -- Weak table for connections
rt.Added = nil
rt.Removing = nil
rt.MainGUI = rt.player.PlayerGui.MainGUI or rt.player.PlayerGui:WaitForChild("MainGUI")

function rt:Character () : (Model)
    return self.player.Character or self.player.CharacterAdded:Wait()
end

function rt:Map () : (Model | nil)
    for _, v in workspace:GetDescendants() do
        if v:IsA("Model") and v.Name == "Base" then
            return v.Parent
        end
    end
    return nil
end

function rt.Disconnect (connection:RBXScriptConnection)
    if typeof(connection) ~= "RBXScriptConnection" then return end

    if connection.Connected then
        connection:Disconnect()
    end
end

-- Function to check if a coin has been touched
local function isCoinTouched(coin)
    return rt.touchedCoins[coin]
end

-- Function to mark a coin as touched
local function markCoinAsTouched(coin)
    rt.touchedCoins[coin] = true
    local node = rt.octree:FindFirstNode(coin)
    if node then
        rt.octree:RemoveNode(node)
    end
end

-- Function to track touch interactions
local function setupTouchTracking(coin)
    local touchInterest = coin:FindFirstChildWhichIsA("TouchTransmitter")
    if touchInterest then
        local connection
        connection = touchInterest.AncestryChanged:Connect(function(_, parent)
            if parent == nil then
                -- TouchInterest removed; mark the coin as touched
                markCoinAsTouched(coin)
                rt.Disconnect(connection)
            end
        end)
        rt.positionChangeConnections[coin] = connection
    end
end

local function setupPositionTracking(coin: MeshPart, LastPositonY: number)
    local connection
    connection = coin:GetPropertyChangedSignal("Position"):Connect(function()
        -- Check if the Y position has changed
        local currentY = coin.Position.Y
        if LastPositonY and LastPositonY ~= currentY then

            -- Remove the coin from the octree as it has been moved
            markCoinAsTouched(coin)

            rt.Disconnect(connection)
            coin:Destroy()
            return
        end
    end)
    rt.positionChangeConnections[coin] = connection
end

-- Function to populate the Octree with coins
local function populateOctree()
    rt.octree:ClearAllNodes() -- Clear previous nodes

    for _, descendant in pairs(rt.coinContainer:GetDescendants()) do
        if descendant:IsA("TouchTransmitter") then --and descendant.Material == rt.Material then
            local parentCoin = descendant.Parent
            if not isCoinTouched(parentCoin) then
                rt.octree:CreateNode(parentCoin.Position, parentCoin)
                setupTouchTracking(parentCoin)
            end
            setupPositionTracking(parentCoin, parentCoin.Position.Y)
        end
    end

    rt.Added = rt.coinContainer.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("MeshPart") and descendant.Material == rt.Material then
            local parentCoin = descendant.Parent
            if not isCoinTouched(parentCoin) then
                rt.octree:CreateNode(parentCoin.Position, parentCoin)
                setupTouchTracking(parentCoin)
                setupPositionTracking(parentCoin, parentCoin.Position.Y)
            end
        end
    end)

    rt.Removing = rt.coinContainer.DescendantRemoving:Connect(function(descendant)
        if descendant:IsA("TouchTransmitter") and descendant.Parent.Name == "Coin_Server" then
            local parentCoin = descendant.Parent
            if isCoinTouched(parentCoin) then
                markCoinAsTouched(parentCoin)
            end
        end
    end)
end

local function moveToPositionSlowly(targetPosition: Vector3, duration: number)
    rt.humanoidRootPart = rt:Character().PrimaryPart
    local startPosition = rt.humanoidRootPart.Position
    local startTime = tick()
    
    while true do
        local elapsedTime = tick() - startTime
        local alpha = math.min(elapsedTime / duration, 1)
        rt:Character():PivotTo(CFrame.new(startPosition:Lerp(targetPosition, alpha)))

        if alpha >= 1 then
            task.wait(0.2)
            break
        end

        task.wait() -- Small delay to make the movement smoother
    end
end

-- Function to collect coins
local function collectCoins()
    -- Ensure CoinContainer exists
    rt.coinContainer = rt:Map():FindFirstChild("CoinContainer")
    assert(rt.coinContainer, "CoinContainer not found in the map!")
    rt.waypoint = rt:Character():GetPivot()

    -- Populate Octree
    populateOctree()
    
    while true do
        if rt.MainGUI:WaitForChild("Game").CoinBags.Container.SnowToken.FullBagIcon.Visible then
            print("Full bag")
            break
        end

        -- Find nearest coin
        local nearestNode = rt.octree:GetNearest(rt:Character().PrimaryPart.Position, rt.radius, 1)[1]

        if nearestNode then
            local closestCoin = nearestNode.Object
            print(isCoinTouched(closestCoin))
            if not isCoinTouched(closestCoin) then
                local closestCoinPosition = closestCoin.Position
                local distance = (rt:Character().PrimaryPart.Position - closestCoinPosition).Magnitude
                local duration = distance / rt.walkspeed -- Default walk speed is 26 studs/sec

                -- Move to the coin
                moveToPositionSlowly(closestCoinPosition, duration)

                -- Mark coin as touched and clean up
                markCoinAsTouched(closestCoin)
                task.wait(0.2) -- Ensure touch is registered
            end
        else
            task.wait(1) -- No coins; retry after delay
        end
    end

    if rt.TpBackToStart then
        rt:Character():PivotTo(rt.waypoint)
    end
end

-- Start the auto-farm
local start = coroutine.create(collectCoins)
coroutine.resume(start)

-- Clean up when the player dies or leaves
local died = rt.player.CharacterRemoving:Connect(function()
    coroutine.close(start)
    for _, connection in pairs(rt.positionChangeConnections) do
        rt.Disconnect(connection)
    end
    rt.Disconnect(rt.Added)
    rt.Disconnect(rt.Removing)
    rt = nil
    Octree = nil
end)

rt.Players.PlayerRemoving:Connect(function()
    died:Disconnect()
end)
end)

-- Drag (déplacement)
local dragging = false
local dragStart
local startPos

button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = button.Position
	end
end)

button.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		button.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
