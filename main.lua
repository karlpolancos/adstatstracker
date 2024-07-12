local placeIds = {
    [17018663967] = true,
    [17017769292] = true
}

if not placeIds[game.placeId] then
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local function safeInvoke(remoteName, ...)
    local remote = ReplicatedStorage.Remotes:FindFirstChild(remoteName)
    if not remote then
        warn("Remote function '" .. remoteName .. "' not found.")
        return nil
    end
    return remote:InvokeServer(...)
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/karlpolancos/adstatstracker/main/updatewebhook.lua"))()

while true do
    local inventoryResult = safeInvoke("GetInventory")
    if not inventoryResult then
        warn("Failed to retrieve inventory.")
        return -- Consider adding a break condition here based on game logic
    end

    local PlayerStats = {
        Gold = inventoryResult.Currencies.Gold,
        Gems = inventoryResult.Currencies.Gems,
        Level = inventoryResult.Level,
        XP = inventoryResult.XP,
        TraitCrystal = inventoryResult.Items["Trait Crystal"] and inventoryResult.Items["Trait Crystal"] or 0,
        RiskyRice = inventoryResult.Items["Risky Dice"] and inventoryResult.Items["Risky Dice"] or 0,
        FrostBind = inventoryResult.Items["Frost Bind"] and inventoryResult.Items["Frost Bind"] or 0,
        Units = {}
    }

    if not getgenv()['CurrentStats'] then getgenv()['CurrentStats'] = PlayerStats end

    local EquippedUnits = inventoryResult.EquippedUnits
    local AllUnitsInfo = inventoryResult.Units

    if EquippedUnits and AllUnitsInfo then
        for _, unitID in ipairs(EquippedUnits) do
            local unitInfo = AllUnitsInfo[unitID]
            if unitInfo then
                PlayerStats.Units[unitID] = unitInfo
            end
        end
    end

    updateWebhook(PlayerStats)
    wait(5) -- Wait for 5 seconds before the next iteration
end
