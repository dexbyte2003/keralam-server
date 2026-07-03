local function getCore()
    if GetResourceState('qbx_core') == 'started' then
        return 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qb'
    end
    return nil
end

local framework = getCore()

local function notify(msg, type)
    if framework == 'qbx' then
        exports.qbx_core:Notify(msg, type)
    else
        exports['qb-core']:Notify(msg, type)
    end
end

local function useItem(itemName)
    local itemConfig = Config.Items[itemName]
    if not itemConfig then return end

    -- Check if player is already at max health/armor to avoid wasting items
    local ped = cache.ped
    local currentHealth = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)
    print(string.format("[g4-healings debug] Health: %s/%s", currentHealth, maxHealth))
    if itemConfig.type == 'health' and currentHealth >= maxHealth then
        notify('You are already at full health!', 'error')
        return
    elseif itemConfig.type == 'armor' and GetPedArmour(ped) >= 100 then
        notify('Your armor is already full!', 'error')
        return
    end

    -- Progress Bar
    if lib.progressBar({
        duration = itemConfig.duration,
        label = itemConfig.label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
        anim = {
            dict = itemConfig.anim.dict,
            clip = itemConfig.anim.clip,
            flag = itemConfig.anim.flag or 49,
        },
        prop = itemConfig.prop
    }) then
        TriggerServerEvent('g4-healings:server:useItem', itemName)
    else
        notify('Canceled', 'error')
    end
end

for itemName, _ in pairs(Config.Items) do
    exports(itemName, function(data, slot)
        useItem(itemName)
    end)
end

RegisterNetEvent('g4-healings:client:useHealthPortion', function()
    useItem('health-portion')
end)

RegisterNetEvent('g4-healings:client:useArmourPortion', function()
    useItem('armour-portion')
end)

RegisterNetEvent('g4-healings:client:addHealth', function(amount)
    local ped = PlayerPedId()

    local currentHealth = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)

    local newHealth = math.min(maxHealth, currentHealth + amount)

    SetEntityHealth(ped, newHealth)
end)

