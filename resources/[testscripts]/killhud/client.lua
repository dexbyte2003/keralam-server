local displayDuration = 1600 -- ms
local damagedPeds = {}

local function showKill()
    SendNUIMessage({
        action = 'showKill',
        emoji = "💀",
        duration = displayDuration
    })
end

-- PvP kills (baseevents)
RegisterNetEvent('baseevents:onPlayerKilled')
AddEventHandler('baseevents:onPlayerKilled', function(victimId, killerId, weaponHash)
    if killerId == GetPlayerServerId(PlayerId()) then
        showKill()
    end
end)

-- Track damage events
AddEventHandler('gameEventTriggered', function(name, args)
    if name == "CEventNetworkEntityDamage" then
        local victim = args[1]
        local attacker = args[2]

        if attacker == PlayerPedId() and DoesEntityExist(victim) and IsEntityAPed(victim) and not IsPedAPlayer(victim) then
            damagedPeds[victim] = true
        end
    end
end)

-- Check if damaged peds die
CreateThread(function()
    while true do
        Wait(500)
        for ped, _ in pairs(damagedPeds) do
            if DoesEntityExist(ped) then
                if IsPedDeadOrDying(ped, true) then
                    showKill()
                    damagedPeds[ped] = nil -- remove from list
                end
            else
                damagedPeds[ped] = nil
            end
        end
    end
end)
