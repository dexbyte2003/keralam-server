-- This is so much code, so scary! I would keep this a server command, better security...
lib.addCommand(Config.Command, {
    help = 'Opens Vehicle Spawner Menu',
    restricted = Config.AdminGroups
}, function(source, args, raw)
    TriggerClientEvent('rup-VehicleSpawner:openUi', source)
end)

-- Holy Moly A Fricking Webhook!!

RegisterNetEvent('Rup-VehicleSpawner:DiscordLog', function(data)
    local Player = GetPlayerPed(source)
    local PlayerCoords = GetEntityCoords(Player)

    if Config.Debug then
        print("^3[Identifier]^7: " .. json.encode(GetPlayerIdentifier(source, Config.Discord.LicenseType)))
        print("^2[Source]^7: " .. source)
        print("^5[Data]^7: " .. json.encode(data, { indent = true }))
    end

    local embed = {
        {
            ["color"] = 16711680,
            ["title"] = "Rup-VehicleSpawner",
            ["author"] = {
                ["name"] = 'RUP-SCRIPTS',
                ["icon_url"] = Config.Discord.Icon,
                ["url"] = 'https://discord.gg/PFwfnfUE6a',
            },
            ["fields"] = {
                {["name"] = "ID", ["value"] = "`" .. source .. "`", ["inline"] = true},
                {["name"] = "Player", ["value"] = "`" .. GetPlayerName(source) .. "`", ["inline"] = true},
                {["name"] = "License", ["value"] = "`" .. GetPlayerIdentifier(source, Config.Discord.LicenseType) .. "`", ["inline"] = false},
                {["name"] = "Description", ["value"] = "`" .. GetPlayerName(source) .. "`" .. " spawned a " .. "`" .. data.model .. "`", ["inline"] = true},
                {["name"] = "Coordinates", ["value"] = "`" .. string.format("vector3(%.2f, %.2f, %.2f)", PlayerCoords.x, PlayerCoords.y, PlayerCoords.z) .. "`", ["inline"] = false},
            },
            ["timestamp"] = os.date('%Y-%m-%dT%H:%M'),
            ["footer"] = {
                ["text"] = "Rup-VehicleSpawner",
                ["icon_url"] = Config.Discord.Icon,
            },
        }
    }

    PerformHttpRequest(Config.Discord.Webhook, function(err, text, headers)
        if err == 0 then
            print("^5DEBUG^7: ^7Add your ^8webhook^7 in ^8Config.lua^7!!! Error:", err)
        elseif err ~= 200 and err ~= 204 then
            print("^5DEBUG^7: ^4Error sending death log to Discord:^7 Error:", err)
        end
    end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
end)