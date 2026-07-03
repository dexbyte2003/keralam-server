local stashes = {}
local shops = {}

-- Helper to trim strings
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- Initialize Tables
local function initialize()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `g4_stashes` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `stash_id` VARCHAR(50) UNIQUE NOT NULL,
            `label` VARCHAR(100) NOT NULL,
            `slots` INT DEFAULT 50,
            `weight` INT DEFAULT 100000,
            `coords` TEXT NOT NULL,
            `access` TEXT DEFAULT NULL
        )
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `g4_shops` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `shop_id` VARCHAR(50) UNIQUE NOT NULL,
            `label` VARCHAR(100) NOT NULL,
            `coords` TEXT NOT NULL,
            `items` TEXT DEFAULT '[]',
            `access` TEXT DEFAULT NULL
        )
    ]])

    -- Check if columns exist (Migration)
    local columnsStash = MySQL.query.await("SHOW COLUMNS FROM `g4_stashes` LIKE 'access'")
    if #columnsStash == 0 then
        MySQL.query.await("ALTER TABLE `g4_stashes` ADD COLUMN `access` TEXT DEFAULT NULL")
    end
    local columnsShop = MySQL.query.await("SHOW COLUMNS FROM `g4_shops` LIKE 'access'")
    if #columnsShop == 0 then
        MySQL.query.await("ALTER TABLE `g4_shops` ADD COLUMN `access` TEXT DEFAULT NULL")
    end

    -- Load Stashes
    local loadedStashes = MySQL.query.await('SELECT * FROM g4_stashes')
    if loadedStashes then
        for _, stash in ipairs(loadedStashes) do
            local coords = type(stash.coords) == 'string' and json.decode(stash.coords) or stash.coords
            local access = stash.access and (type(stash.access) == 'string' and json.decode(stash.access) or stash.access) or nil
            
            local cleanId = trim(tostring(stash.stash_id))
            stashes[cleanId] = {
                id = cleanId,
                label = stash.label,
                slots = stash.slots,
                weight = stash.weight,
                coords = coords,
                access = access
            }
            exports.ox_inventory:RegisterStash(cleanId, stash.label, stash.slots, stash.weight, nil, access, vector3(coords.x, coords.y, coords.z))
        end
    end

    -- Load Shops
    local loadedShops = MySQL.query.await('SELECT * FROM g4_shops')
    if loadedShops then
        for _, shop in ipairs(loadedShops) do
            local coords = type(shop.coords) == 'string' and json.decode(shop.coords) or shop.coords
            local access = shop.access and (type(shop.access) == 'string' and json.decode(shop.access) or shop.access) or nil
            local items = type(shop.items) == 'string' and json.decode(shop.items) or (shop.items or {})
            
            local cleanId = trim(tostring(shop.shop_id))
            shops[cleanId] = {
                id = cleanId,
                label = shop.label,
                coords = coords,
                items = items,
                access = access
            }
            
            exports.ox_inventory:RegisterShop(cleanId, {
                name = shop.label,
                inventory = items,
                groups = access,
                locations = {
                    vector3(coords.x, coords.y, coords.z)
                }
            })
        end
    end
    print('[G4 Stash Manager] Successfully loaded stashes and shops from database.')
end


-- Callbacks & Events
lib.callback.register('g4-stash-manager:server:saveStash', function(source, data)
    local cleanId = trim(tostring(data.id))
    print(('[DEBUG] Saving stash: %s'):format(cleanId))
    
    data.id = cleanId
    local success = MySQL.insert.await('INSERT INTO g4_stashes (stash_id, label, slots, weight, coords, access) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE label = VALUES(label), slots = VALUES(slots), weight = VALUES(weight), coords = VALUES(coords), access = VALUES(access)', {
        cleanId, data.label, data.slots, data.weight, json.encode(data.coords), data.access and json.encode(data.access) or nil
    })

    if success then
        stashes[cleanId] = data
        exports.ox_inventory:RegisterStash(cleanId, data.label, data.slots, data.weight, nil, data.access, vector3(data.coords.x, data.coords.y, data.coords.z))
        return true
    end
    return false
end)

lib.callback.register('g4-stash-manager:server:saveShop', function(source, data)
    local cleanId = trim(tostring(data.id))
    print(('[DEBUG] Saving shop: %s'):format(cleanId))
    
    data.id = cleanId
    local success = MySQL.insert.await('INSERT INTO g4_shops (shop_id, label, coords, items, access) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE label = VALUES(label), coords = VALUES(coords), access = VALUES(access)', {
        cleanId, data.label, json.encode(data.coords), json.encode(data.items or {}), data.access and json.encode(data.access) or nil
    })

    if success then
        shops[cleanId] = data
        exports.ox_inventory:RegisterShop(cleanId, {
            name = data.label,
            inventory = data.items or {},
            groups = data.access,
            locations = {
                vector3(data.coords.x, data.coords.y, data.coords.z)
            }
        })
        return true
    end
    return false
end)

lib.callback.register('g4-stash-manager:server:getConfigs', function(source)
    return {
        stashes = stashes,
        shops = shops
    }
end)

lib.callback.register('g4-stash-manager:server:updateShopItems', function(source, shopId, items)
    local success = MySQL.query.await('UPDATE g4_shops SET items = ? WHERE shop_id = ?', {
        json.encode(items), shopId
    })

    if success then
        if shops[shopId] then
            shops[shopId].items = items
            local coords = shops[shopId].coords
            local access = shops[shopId].access
            exports.ox_inventory:RegisterShop(shopId, {
                name = shops[shopId].label,
                inventory = items,
                groups = access,
                locations = {
                    vector3(coords.x, coords.y, coords.z)
                }
            })
        end
        return true
    end
    return false
end)

lib.callback.register('g4-stash-manager:server:openInventory', function(source, invType, id)
    id = trim(tostring(id))
    print(('[DEBUG] Player %s requested to open %s ID: "%s"'):format(source, invType, id))
    
    if invType == 'stash' then
        if not stashes[id] then
            print(('[ERROR] Stash ID "%s" not found in memory.'):format(id))
            local avail = {}
            for k, v in pairs(stashes) do table.insert(avail, k) end
            print(('[DEBUG] Available Stash IDs: %s'):format(table.concat(avail, ", ")))
            return false, 'Stash config not found on server'
        end
        local stash = stashes[id]
        exports.ox_inventory:RegisterStash(id, stash.label, stash.slots, stash.weight, nil, stash.access, vector3(stash.coords.x, stash.coords.y, stash.coords.z))
        return true
    elseif invType == 'shop' then
        if not shops[id] then
            print(('[ERROR] Shop ID "%s" not found in memory.'):format(id))
            local avail = {}
            for k, v in pairs(shops) do table.insert(avail, k) end
            print(('[DEBUG] Available Shop IDs: %s'):format(table.concat(avail, ", ")))
            return false, 'Shop config not found on server'
        end
        local shop = shops[id]
        exports.ox_inventory:RegisterShop(id, {
            name = shop.label,
            inventory = shop.items,
            groups = shop.access,
            locations = {
                vector3(shop.coords.x, shop.coords.y, shop.coords.z)
            }
        })
        return true
    end
    
    return false, 'Invalid inventory type'
end)

lib.callback.register('g4-stash-manager:server:deleteConfig', function(source, type, id)
    local table = type == 'stash' and 'g4_stashes' or 'g4_shops'
    local col = type == 'stash' and 'stash_id' or 'shop_id'
    local success = MySQL.query.await('DELETE FROM ' .. table .. ' WHERE ' .. col .. ' = ?', {id})
    
    if success then
        if type == 'stash' then
            stashes[id] = nil
        else
            shops[id] = nil
        end
        -- Note: ox_inventory doesn't have an unregister export easily available via Lua in all versions, 
        -- but the point/target removal on client side will handle interaction.
        return true
    end
    return false
end)

lib.callback.register('g4-stash-manager:server:getStashItems', function(source, stashId)
    local inventory = exports.ox_inventory:GetInventory(stashId)
    local items = {}
    if inventory and inventory.items then
        for slot, item in pairs(inventory.items) do
            if item and item.name then
                table.insert(items, {
                    name = item.name,
                    count = item.count,
                    label = item.label or item.name,
                    slot = slot
                })
            end
        end
    end
    return items
end)

lib.callback.register('g4-stash-manager:server:updateStashItems', function(source, stashId, toAdd, toRemove)
    -- Perform removals
    if toRemove then
        for _, item in ipairs(toRemove) do
            if item.name and item.count and item.count > 0 then
                exports.ox_inventory:RemoveItem(stashId, item.name, item.count)
            end
        end
    end

    -- Perform additions
    if toAdd then
        for _, item in ipairs(toAdd) do
            if item.name and item.count and item.count > 0 then
                exports.ox_inventory:AddItem(stashId, item.name, item.count)
            end
        end
    end

    return true
end)


MySQL.ready(initialize)

