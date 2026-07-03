local activePoints = {}

-- Create a point for a stash or shop
local function createPoint(data, isShop)
    local coords = vec3(data.coords.x, data.coords.y, data.coords.z)
    local id = data.id
    
    local point = lib.points.new({
        coords = coords,
        distance = 3,
        invId = id,
        isShop = isShop,
        label = data.label
    })

    function point:onEnter()
        lib.showTextUI(('[E] - Open %s'):format(self.label), {
            position = 'left-center',
            icon = isShop and 'shop' or 'box-archive'
        })
    end

    function point:onExit()
        lib.hideTextUI()
    end

    function point:nearby()
        if self.currentDistance < 2 and IsControlJustReleased(0, 38) then -- E key
            print(('[DEBUG] Attempting to open %s: %s'):format(self.isShop and 'shop' or 'stash', self.invId))
            local success, err = lib.callback.await('g4-stash-manager:server:openInventory', false, self.isShop and 'shop' or 'stash', self.invId)
            if not success then
                print(('[ERROR] Failed to open inventory: %s'):format(err or 'Unknown Error'))
                lib.notify({ type = 'error', description = err or 'Could not open inventory' })
            else
                if self.isShop then
                    exports.ox_inventory:openInventory('shop', { type = self.invId, id = 1 })
                else
                    exports.ox_inventory:openInventory('stash', self.invId)
                end
            end
        end
        
        DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.3, 0.3, 0.3, 200, 200, 200, 50, false, true, 2, nil, nil, false)
    end

    activePoints[id] = point
end

-- Refresh all points from server
local function refreshConfigs()
    local configs
    local success = false
    
    for i = 1, 5 do
        success, configs = pcall(function()
            return lib.callback.await('g4-stash-manager:server:getConfigs', false)
        end)
        if success and configs then
            break
        end
        Wait(1000)
    end

    if not success or not configs then
        print('[G4 Stash Manager] [ERROR] Failed to load configuration from server (server callback not ready).')
        return
    end

    
    -- Clear existing points
    for k, v in pairs(activePoints) do
        v:remove()
    end
    activePoints = {}

    -- Add stashes
    for _, stash in pairs(configs.stashes) do
        createPoint(stash, false)
    end

    -- Add shops
    for _, shop in pairs(configs.shops) do
        createPoint(shop, true)
    end
end

RegisterNetEvent('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    refreshConfigs()
end)

-- Manager Logic NUI Integration
local function openManager()
    local configs = lib.callback.await('g4-stash-manager:server:getConfigs', false)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openUI',
        configs = configs
    })
end

RegisterCommand('invmng', function()
    -- You can add permission check here if using a framework
    openManager()
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeUI' })
    cb('ok')
end)

RegisterNUICallback('getPlayerCoords', function(data, cb)
    local coords = GetEntityCoords(cache.ped)
    SendNUIMessage({
        action = 'setPlayerCoords',
        coords = { x = coords.x, y = coords.y, z = coords.z },
        target = data.target
    })
    cb('ok')
end)

RegisterNUICallback('saveStash', function(data, cb)
    local success = lib.callback.await('g4-stash-manager:server:saveStash', false, data)
    if success then
        refreshConfigs()
        -- Send updated configs to keep NUI state in sync
        local configs = lib.callback.await('g4-stash-manager:server:getConfigs', false)
        SendNUIMessage({
            action = 'openUI',
            configs = configs
        })
    end
    cb(success and 'ok' or 'error')
end)

RegisterNUICallback('saveShop', function(data, cb)
    local success = lib.callback.await('g4-stash-manager:server:saveShop', false, data)
    if success then
        refreshConfigs()
        -- Send updated configs to keep NUI state in sync
        local configs = lib.callback.await('g4-stash-manager:server:getConfigs', false)
        SendNUIMessage({
            action = 'openUI',
            configs = configs
        })
    end
    cb(success and 'ok' or 'error')
end)

RegisterNUICallback('updateShopItems', function(data, cb)
    local success = lib.callback.await('g4-stash-manager:server:updateShopItems', false, data.id, data.items)
    if success then
        refreshConfigs()
        -- Send updated configs to keep NUI state in sync
        local configs = lib.callback.await('g4-stash-manager:server:getConfigs', false)
        SendNUIMessage({
            action = 'openUI',
            configs = configs
        })
    end
    cb(success and 'ok' or 'error')
end)

RegisterNUICallback('deleteConfig', function(data, cb)
    local success = lib.callback.await('g4-stash-manager:server:deleteConfig', false, data.type, data.id)
    if success then
        refreshConfigs()
        -- Send updated configs to keep NUI state in sync
        local configs = lib.callback.await('g4-stash-manager:server:getConfigs', false)
        SendNUIMessage({
            action = 'openUI',
            configs = configs
        })
    end
    cb(success and 'ok' or 'error')
end)

RegisterNUICallback('teleportTo', function(data, cb)
    if data.coords then
        local ped = cache.ped
        SetEntityCoords(ped, data.coords.x, data.coords.y, data.coords.z + 1.0, false, false, false, true)
        lib.notify({ type = 'success', description = 'Teleported to location' })
    end
    cb('ok')
end)

RegisterNUICallback('getStashItems', function(data, cb)
    local items = lib.callback.await('g4-stash-manager:server:getStashItems', false, data.id)
    cb(items)
end)

RegisterNUICallback('updateStashItems', function(data, cb)
    local success = lib.callback.await('g4-stash-manager:server:updateStashItems', false, data.id, data.toAdd, data.toRemove)
    if success then
        refreshConfigs()
    end
    cb(success and 'ok' or 'error')
end)


