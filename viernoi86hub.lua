local games = {
    [142823291] = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/viernoi86/script/refs/heads/main/viernoi86mm2.lua"))()
        print("MM2")
    end,

    [286090429] = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/viernoi86/arsenal/refs/heads/main/arsenal.lua"))()
        print("Arsenal")
    end
}

local script = games[game.PlaceId]

if script then
    script()
else
    warn("Jeu non supporté : " .. game.PlaceId)
end
