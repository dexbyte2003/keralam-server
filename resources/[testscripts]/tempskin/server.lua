local QBCore = exports['qb-core']:GetCoreObject()

-- Define the log prefix for easy searching in console
local function debugLog(msg)
    print("^3[TempSkin-Debug]^7 " .. tostring(msg))
end

-- 1. Create the 'tempskin' table automatically
CreateThread(function()
    Wait(1000) -- Wait for DB to be definitely ready
    debugLog("Checking database table 'tempskin'...")
    
    -- USING DIRECT EXPORT: exports.oxmysql:query
    exports.oxmysql:query([[
        CREATE TABLE IF NOT EXISTS tempskin (
            citizenid VARCHAR(50) NOT NULL,
            lastactive INT(11) NOT NULL,
            PRIMARY KEY (citizenid)
        )
    ]], {}, function(result)
        debugLog("Table check complete.")
    end)
end)

-- Base Skin Template
local baseSkinTemplate = {
    tattoos = {},
    hair = {highlight = -1, style = 0, texture = 0, color = -1},
    model = "default", 
    components = {
        {component_id = 0, texture = 0, drawable = 0}, {component_id = 1, texture = 0, drawable = 0},
        {component_id = 2, texture = 0, drawable = 0}, {component_id = 3, texture = 0, drawable = 0},
        {component_id = 4, texture = 0, drawable = 0}, {component_id = 5, texture = 0, drawable = 0},
        {component_id = 6, texture = 0, drawable = 0}, {component_id = 7, texture = 0, drawable = 0},
        {component_id = 8, texture = 0, drawable = 0}, {component_id = 9, texture = 0, drawable = 0},
        {component_id = 10, texture = 0, drawable = 0}, {component_id = 11, texture = 0, drawable = 0}
    },
    headBlend = {
        skinMix = 0, shapeMix = 0, skinThird = 0, thirdMix = 0, shapeFirst = 0, 
        skinFirst = 0, shapeSecond = 0, skinSecond = 0, shapeThird = 0
    },
    faceFeatures = {
        neckThickness = 0, chinBoneSize = 0, jawBoneWidth = 0, lipsThickness = 0, 
        chinHole = 0, cheeksWidth = 0, cheeksBoneHigh = 0, noseWidth = 0, 
        eyeBrownHigh = 0, cheeksBoneWidth = 0, chinBoneLowering = 0, 
        chinBoneLenght = 0, jawBoneBackSize = 0, noseBoneHigh = 0, eyesOpening = 0, 
        eyeBrownForward = 0, nosePeakLowering = 0, noseBoneTwist = 0, 
        nosePeakHigh = 0, nosePeakSize = 0
    },
    eyeColor = -1,
    props = {
        {prop_id = 0, texture = -1, drawable = -1}, {prop_id = 1, texture = -1, drawable = -1},
        {prop_id = 2, texture = -1, drawable = -1}, {prop_id = 6, texture = -1, drawable = -1},
        {prop_id = 7, texture = -1, drawable = -1}
    },
    headOverlays = {
        eyebrows = {color = 0, style = 0, secondColor = 0, opacity = 0},
        blush = {color = 0, style = 0, secondColor = 0, opacity = 0},
        moleAndFreckles = {color = 0, style = 0, secondColor = 0, opacity = 0},
        sunDamage = {color = 0, style = 0, secondColor = 0, opacity = 0},
        beard = {color = 0, style = 0, secondColor = 0, opacity = 0},
        chestHair = {color = 0, style = 0, secondColor = 0, opacity = 0},
        blemishes = {color = 0, style = 0, secondColor = 0, opacity = 0},
        bodyBlemishes = {color = 0, style = 0, secondColor = 0, opacity = 0},
        makeUp = {color = 0, style = 0, secondColor = 0, opacity = 0},
        ageing = {color = 0, style = 0, secondColor = 0, opacity = 0},
        complexion = {color = 0, style = 0, secondColor = 0, opacity = 0},
        lipstick = {color = 0, style = 0, secondColor = 0, opacity = 0}
    }
}

-- COMMAND: /settempped
QBCore.Commands.Add('settempped', 'Set a temporary ped model', { {name='id', help='Player ID'}, {name='model', help='Ped Model Name'} }, true, function(source, args)
    debugLog("--- Command /settempped Triggered ---")
    local src = source
    local targetId = tonumber(args[1])
    local pedModel = args[2]

    debugLog("Args received: ID=" .. tostring(targetId) .. " Model=" .. tostring(pedModel))

    if not targetId or not pedModel then
        debugLog("Error: Missing arguments")
        TriggerClientEvent('QBCore:Notify', src, "Invalid arguments.", "error")
        return
    end

    local Player = QBCore.Functions.GetPlayer(targetId)
    if not Player then
        debugLog("Error: Player object not found for ID " .. targetId)
        TriggerClientEvent('QBCore:Notify', src, "Player not found.", "error")
        return
    end

    local citizenid = Player.PlayerData.citizenid
    debugLog("Player found. CitizenID: " .. citizenid)

    -- 1. Find current active skin ID
    -- USING DIRECT EXPORT: exports.oxmysql:scalar
    exports.oxmysql:scalar('SELECT id FROM playerskins WHERE citizenid = ? AND active = 1', {citizenid}, function(activeId)
        debugLog("DB Fetch Active Skin ID: " .. tostring(activeId))
        
        if activeId then
            -- 2. Upsert into tempskin
            debugLog("Saving Active ID " .. activeId .. " to tempskin table...")
            -- USING DIRECT EXPORT: exports.oxmysql:insert
            exports.oxmysql:insert('INSERT INTO tempskin (citizenid, lastactive) VALUES (?, ?) ON DUPLICATE KEY UPDATE lastactive = ?', {citizenid, activeId, activeId}, function(insertResult)
                debugLog("Tempskin saved/updated. Result: " .. tostring(insertResult))
            end)
        else
            debugLog("WARNING: No active skin found in playerskins. Skipping backup save.")
        end

        -- 3. Set all to inactive
        debugLog("Setting all skins to active=0 for citizenid: " .. citizenid)
        -- USING DIRECT EXPORT: exports.oxmysql:update
        exports.oxmysql:update('UPDATE playerskins SET active = 0 WHERE citizenid = ?', {citizenid}, function(updateResult)
            debugLog("Rows deactivated: " .. tostring(updateResult))

            -- 4. Prepare Data
            local newSkinData = baseSkinTemplate
            newSkinData.model = pedModel
            local skinJson = json.encode(newSkinData)
            
            debugLog("Inserting new temp ped row for model: " .. pedModel)

            -- 5. Insert new row
            exports.oxmysql:insert('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)', {citizenid, pedModel, skinJson, 1}, function(id)
                debugLog("Insert Complete. New DB ID: " .. tostring(id))
                
                if id then
                    TriggerClientEvent('QBCore:Notify', src, "Temp ped set!", "success")
                    debugLog("Triggering qb-clothes refresh for client ID " .. targetId)
                    TriggerClientEvent('qb-clothes:client:loadPlayerSkin', targetId)
		    TriggerClientEvent("illenium-appearance:client:reloadSkin", targetId, true)
                else
                    debugLog("Error: Insert returned nil ID.")
                end
            end)
        end)
    end)
end, 'admin')

-- COMMAND: /restoreped
QBCore.Commands.Add('restoreped', 'Restore original skin', { {name='id', help='Player ID'} }, true, function(source, args)
    debugLog("--- Command /restoreped Triggered ---")
    local src = source
    local targetId = tonumber(args[1])

    if not targetId then 
        debugLog("Error: No ID provided")
        return 
    end

    local Player = QBCore.Functions.GetPlayer(targetId)
    if not Player then
        debugLog("Error: Player not found for ID " .. targetId)
        TriggerClientEvent('QBCore:Notify', src, "Player not found.", "error")
        return
    end

    local citizenid = Player.PlayerData.citizenid
    debugLog("Processing restore for CitizenID: " .. citizenid)

    -- 1. Fetch lastactive
    exports.oxmysql:scalar('SELECT lastactive FROM tempskin WHERE citizenid = ?', {citizenid}, function(lastActiveId)
        debugLog("Fetched lastActiveId from tempskin: " .. tostring(lastActiveId))

        if not lastActiveId then
            debugLog("Error: No record in tempskin table")
            TriggerClientEvent('QBCore:Notify', src, "No saved temp skin found.", "error")
            return
        end

        -- 2. Make current active = 0
        debugLog("Deactivating current active skin...")
        exports.oxmysql:update('UPDATE playerskins SET active = 0 WHERE citizenid = ? AND active = 1', {citizenid}, function(uResult)
            debugLog("Rows deactivated: " .. tostring(uResult))

            -- 3. Restore old skin
            debugLog("Restoring active=1 for ID: " .. lastActiveId)
            exports.oxmysql:update('UPDATE playerskins SET active = 1 WHERE id = ?', {lastActiveId}, function(affectedRows)
                debugLog("Restore update complete. Rows affected: " .. tostring(affectedRows))

                if affectedRows and affectedRows > 0 then
                    TriggerClientEvent('QBCore:Notify', src, "Skin restored.", "success")
                    TriggerClientEvent('qb-clothes:client:loadPlayerSkin', targetId)
		    TriggerClientEvent("illenium-appearance:client:reloadSkin", targetId, false)
                else
                    debugLog("CRITICAL ERROR: Could not find ID " .. lastActiveId .. " in playerskins table to restore.")
                    TriggerClientEvent('QBCore:Notify', src, "Restore failed: Original ID missing.", "error")
                end
            end)
        end)
    end)
end, 'admin')