-- ======================================================
-- 🔐 ADMIN PERMISSION CHECK (ACE: group.admin)
-- ======================================================

RegisterNetEvent('npcspawner:server:checkAdmin', function()
    local src = source
    local isAdmin = false

    if Config.AdminOnly and Config.UseGroupAdmin then
        isAdmin = IsPlayerAceAllowed(src, 'command')
    else
        isAdmin = true
    end

    TriggerClientEvent('npcspawner:client:setAdmin', src, isAdmin)
end)

-- ======================================================
-- 💾 PRESET STORAGE (FOUNDATION)
-- ======================================================
-- This is a base implementation.
-- Can be expanded to JSON / database later.

local SavedPresets = {}

RegisterNetEvent('npcspawner:server:savePreset', function(name, data)
    local src = source

    if not IsPlayerAceAllowed(src, 'command') then
        print(('[NPCSpawner] Unauthorized preset save attempt by %s'):format(src))
        return
    end

    SavedPresets[name] = data
end)

RegisterNetEvent('npcspawner:server:getPresets', function()
    local src = source

    if not IsPlayerAceAllowed(src, 'command') then
        return
    end

    TriggerClientEvent('npcspawner:client:receivePresets', src, SavedPresets)
end)

-- ======================================================
-- 🧹 CLEANUP ON PLAYER DROP
-- ======================================================

AddEventHandler('playerDropped', function()
    -- Placeholder for per-player NPC cleanup if needed later
end)

-- ======================================================
-- 🧹 RESOURCE STOP SAFETY
-- ======================================================

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    print('[NPCSpawner] Resource stopped safely')
end)
