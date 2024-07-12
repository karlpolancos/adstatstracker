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
