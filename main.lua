local placeIds = {
    [17018663967] = true,
    [17017769292] = true,
}

-- Check place ID and license key
if not placeIds[game.PlaceId] or not getgenv().licenseKey then
    print('Invalid place ID or missing license key.')
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer -- Define LocalPlayer

local function safeInvoke(remoteName, ...)
    local remote = ReplicatedStorage.Remotes:FindFirstChild(remoteName)
    if not remote then
        warn("Remote function '" .. remoteName .. "' not found.")
        return nil
    end
    return remote:InvokeServer(...)
end

local function format(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

print('executed')

updateAccount = function(PlayerStats)
    local requestFunction = syn and syn.request or http_request or request
    if requestFunction then
        requestFunction({
            Url = 'https://panel.moopa.org/api/update-ad',
            Method = 'POST',
            Headers = {
                ['Content-Type'] = 'application/json'
            },
            Body = HttpService:JSONEncode({
                license = getgenv().licenseKey,
                userId = LocalPlayer.UserId,
                username = LocalPlayer.Name,
                gems = PlayerStats.Gems,
                gold = PlayerStats.Gold,
                crystal = PlayerStats.TraitCrystal,
                dice = PlayerStats.RiskyDice,
                frostbind = PlayerStats.FrostBind,
                spiritorb = PlayerStats.SpiritOrbs,
                inventory = PlayerStats.inventory
            })
        })
    else
        warn('No valid request function found.')
    end
end

while task.wait(10) do
    local inventoryResult = safeInvoke("GetInventory")
    if not inventoryResult then
        warn("Failed to retrieve inventory.")
        return -- Consider adding a break condition here based on game logic
    end

    local PlayerStats = {
        Gold = inventoryResult.Currencies.Gold or 0,
        Gems = inventoryResult.Currencies.Gems or 0,
        Level = inventoryResult.Level,
        XP = inventoryResult.XP,
        TraitCrystal = inventoryResult.Items["Trait Crystal"] and inventoryResult.Items["Trait Crystal"] or 0,
        RiskyDice = inventoryResult.Items["Risky Dice"] and inventoryResult.Items["Risky Dice"] or 0,
        FrostBind = inventoryResult.Items["Frost Bind"] and inventoryResult.Items["Frost Bind"] or 0,
        SpiritOrbs = inventoryResult.Items["Spirit Orb"] and inventoryResult.Items["Spirit Orb"] or 0,
        inventory = {
            items = inventoryResult.Items
        },
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

    updateAccount(PlayerStats)
end
