local function getCore()
    if GetResourceState('qbx_core') == 'started' then
        return 'qbx', exports.qbx_core
    elseif GetResourceState('qb-core') == 'started' then
        local qb = exports['qb-core']:GetCoreObject()
        return 'qb', qb
    end
    return nil, nil
end

local framework, core = getCore()

local function notify(source, msg, type)
    if framework == 'qbx' then
        exports.qbx_core:Notify(source, msg, type)
    else
        TriggerClientEvent('QBCore:Notify', source, msg, type)
    end
end

CreateThread(function()
    while not core do
        framework, core = getCore()
        Wait(500)
    end
end)

RegisterNetEvent('g4-healings:server:useItem', function(itemName)
    local source = source
    local itemConfig = Config.Items[itemName]
    if not itemConfig then return end

    local player = framework == 'qbx' and core:GetPlayer(source) or core.Functions.GetPlayer(source)
    if not player then return end

    -- Verify player actually has the item
    local count = exports.ox_inventory:GetItemCount(source, itemName)
    if count <= 0 then return end

    if exports.ox_inventory:RemoveItem(source, itemName, 1) then
        local ped = GetPlayerPed(source)
        
        -- if itemConfig.type == 'health' then
        --     local currentHealth = GetEntityHealth(ped)
        --     local maxHealth = GetEntityMaxHealth(ped)
        --     local newHealth = math.min(maxHealth, currentHealth + itemConfig.amount)
            
        --     SetEntityHealth(ped, newHealth)

        if itemConfig.type == 'health' then
            TriggerClientEvent('g4-healings:client:addHealth', source, itemConfig.amount)
            
        elseif itemConfig.type == 'armor' then
            local currentArmor = GetPedArmour(ped)
            local newArmor = math.min(100, currentArmor + itemConfig.amount)
            
            SetPedArmour(ped, newArmor)
            player.Functions.SetMetaData('armor', newArmor)
        end
        
        notify(source, "Used " .. itemName, 'success')
    end
end)

