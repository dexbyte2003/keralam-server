Config = {
    --[[ Debugging ]]
    Debug = false, --[[ Prints and what not :P ]]

    --[[ Command Config ]]
    Command = 'vehiclemenu',        --[[ Command name in game, can make whatever 0-0 ]]
    AdminGroups = { 'group.admin'}, --[[ Add More If needed, its a table ]]

    --[[ Vehicle Config ]]
    Fuel = 'standalone', --[[ legacy, ox, cdn, standalone]]
    Keys = 'standalone', --[[ qb, qbx, standalone]]
    Warp = true,         --[[ Should player warp into the vehicle on spawn, recommend keeping true :P ]]

    --[[ Discord Config ]]
    Discord = {
        Enabled = true,
        Webhook = 'ADD_WEBHOOK_HERE', --[[ Add your webhook or disable the webhook above! ]]
        Icon = 'https://i.imgur.com/OZyXBv0.png',
        LicenseType = 0, --[[ readme.md if you dont know what this is... ]]
    },
}
