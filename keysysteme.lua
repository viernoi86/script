local HttpService = game:GetService("HttpService")

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KeySystem"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 230)
frame.Position = UDim2.new(0.5, -200, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

--// Titre
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 45)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Key System"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = frame

--// Bouton fermer
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.Position = UDim2.new(1, -40, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 25
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

--// Champ clé
local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -40, 0, 45)
keyBox.Position = UDim2.new(0, 20, 0, 60)
keyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
keyBox.PlaceholderText = "Entre ta clé..."
keyBox.Text = ""
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
keyBox.TextSize = 15
keyBox.Font = Enum.Font.Gotham
keyBox.ClearTextOnFocus = false
keyBox.Parent = frame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 7)
boxCorner.Parent = keyBox

--// Bouton vérifier
local verifyButton = Instance.new("TextButton")
verifyButton.Size = UDim2.new(1, -40, 0, 42)
verifyButton.Position = UDim2.new(0, 20, 0, 115)
verifyButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
verifyButton.Text = "Vérifier la clé"
verifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
verifyButton.TextSize = 16
verifyButton.Font = Enum.Font.GothamBold
verifyButton.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 7)
buttonCorner.Parent = verifyButton

--// Statut
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 50)
status.Position = UDim2.new(0, 20, 0, 165)
status.BackgroundTransparency = 1
status.Text = "Entre une clé pour commencer."
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.TextSize = 14
status.Font = Enum.Font.Gotham
status.TextWrapped = true
status.Parent = frame

--// Placement du GUI
if gethui then
    gui.Parent = gethui()
else
    gui.Parent = game:GetService("CoreGui")
end

--// Vérification de la clé
local function verifyKey(key)

    local body = HttpService:JSONEncode({
        key = key
    })

    local success, response = pcall(function()
        return request({
            Url = "https://roblox-key-system-69pk.onrender.com/api/roblox/verify",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = body
        })
    end)

    if not success then
        return false, "Erreur de connexion."
    end

    print("Status:", response.StatusCode)
    print("Response:", response.Body)

    local data

    local decodeSuccess, decodeResult = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)

    if decodeSuccess then
        data = decodeResult
    end

    if response.StatusCode < 200 or response.StatusCode >= 300 then
        local message = "Clé invalide."

        if data and data.message then
            message = tostring(data.message)
        elseif data and data.error then
            message = tostring(data.error)
        end

        return false, message
    end

    local valid = false

    if data then
        if data.valid == true
            or data.success == true
            or data.active == true
            or data.isValid == true then

            valid = true
        end
    end

    if not valid then
        return false, "Clé invalide ou révoquée."
    end

    --// Conservation de l'affichage de l'expiration
    local expiration =
        data.expiresAt
        or data.expires
        or data.expiration
        or data.expirationDate

    if expiration then
        return true, "Clé valide\nExpire le : " .. tostring(expiration)
    end

    return true, "Clé valide\nDurée : illimitée"
end

--// Vérification
verifyButton.MouseButton1Click:Connect(function()

    local key = keyBox.Text:gsub("^%s+", ""):gsub("%s+$", "")

    if key == "" then
        status.Text = "Entre une clé."
        status.TextColor3 = Color3.fromRGB(255, 180, 80)
        return
    end

    verifyButton.Text = "Vérification..."
    verifyButton.Active = false

    status.Text = "Vérification de la clé..."
    status.TextColor3 = Color3.fromRGB(180, 180, 180)

    local valid, message = verifyKey(key)

    if valid then

        --// Clé valide
        print("key valid ✅")

        status.Text = message
        status.TextColor3 = Color3.fromRGB(80, 220, 120)

        --// Petit délai pour voir le message
        task.wait(0.5)

        --// Exécution du script
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/viernoi86/script/refs/heads/main/viernoi86hub.lua"
        ))()

    else

        --// Clé invalide
        print("key invalid❌")

        status.Text = message
        status.TextColor3 = Color3.fromRGB(255, 80, 80)

    end

    verifyButton.Text = "Vérifier la clé"
    verifyButton.Active = true
end)
