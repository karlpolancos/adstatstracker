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

local function format(num)
    string.format("%d", num)
end

local function updateWebhook(PlayerStats)
    local Time = os.date('!*t', os.time())
    local Embed = {
        title = 'Anime Defenders Track Stats';
        color = '1923263';
        description = "**User**: ||" .. Players.LocalPlayer.Name .. "||\n**Level**: ".. PlayerStats.Level .. " [XP: ".. PlayerStats.XP .. "]";
        fields = {{
            name = 'Stats';
            value = '<:Gems:1261119320038182993> '.. format(PlayerStats.Gems) .. '\n<:Gold:1261119324001665135> '.. format(PlayerStats.Gold) .. '\n<:traitcrystal:1261119321925746728> '.. format(PlayerStats.TraitCrystal) .. '\n <:riskydice:1261122885968461905> '.. format(PlayerStats.RiskyRice) .. '\n<:frostbind:1261122911750721556> '.. format(PlayerStats.FrostBind);
        }};
        timestamp = string.format('%d-%02d-%02dT%02d:%02d:%02dZ', Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec);
    }

    (syn and syn.request or http_request or request) {
        Url = 'https://vkupgraders.cc/updatewebhook';
        Method = 'POST';
        Headers = {
            ['Content-Type'] = 'application/json';
        };
        Body = HttpService:JSONEncode( { webhook = TrackSettings.Webhook.URL, response = { embeds = { Embed } } } );
    };
end

while task.wait(5) do
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
end
