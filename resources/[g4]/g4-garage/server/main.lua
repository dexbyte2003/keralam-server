local QBCore = nil

local function GetCore()
    if GetResourceState('qb-core') == 'started' then
        return exports['qb-core']:GetCoreObject()
    end
    return nil
end

local Garages = {}
OutVehicles = {} -- plate -> {netId = netId, owner = citizenid} (Exposed globally to admin.lua)
local SpawningLocks = {}

local function DebugLog(msg)
    if Config.Debug then
        print("[g4-garage] [DEBUG] " .. tostring(msg))
    end
end

-- Fetch core instance
CreateThread(function()
    Wait(500)
    QBCore = GetCore()
    LoadGaragesFromDatabase()
end)

function LoadGaragesFromDatabase()
    MySQL.query('SELECT * FROM `g4-garage_list`', {}, function(results)
        Garages = {}
        if results then
            for _, row in ipairs(results) do
                Garages[row.name] = row
            end
        end
        TriggerClientEvent('g4-garage:client:syncGarages', -1, Garages)
    end)
    
    -- Describe player_vehicles to verify columns
    MySQL.query('DESCRIBE player_vehicles', {}, function(results)
        if results then
            local columns = {}
            for _, row in ipairs(results) do
                table.insert(columns, row.Field)
            end
            DebugLog("player_vehicles columns: " .. table.concat(columns, ", "))
        else
            DebugLog("Failed to describe player_vehicles table!")
        end
    end)
end

RegisterNetEvent('g4-garage:server:requestSync', function()
    local src = source
    TriggerClientEvent('g4-garage:client:syncGarages', src, Garages)
end)

-- Fetch player's owned + shared vehicles
local function FetchOwnedAndSharedVehicles(citizenId, cb)
    -- Select owned vehicles
    MySQL.query('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenId}, function(ownedResults)
        -- Select shared vehicles
        local query = [[
            SELECT pv.* FROM player_vehicles pv
            JOIN `g4-garage_shares` gs ON pv.plate = gs.plate
            WHERE gs.shared_with = ?
        ]]
        MySQL.query(query, {citizenId}, function(sharedResults)
            local list = {}
            local platesMap = {}

            local function process(v, isShared)
                if platesMap[v.plate] then return end
                platesMap[v.plate] = true

                local cleanedPlate = string.gsub(v.plate, "%s+", ""):upper()
                local outState = OutVehicles[cleanedPlate]
                local stateText = "In Garage"
                if outState then
                    stateText = "Out on Road"
                elseif v.state == 0 then
                    stateText = "Out on Road (Unsaved)"
                end

                table.insert(list, {
                    plate = v.plate,
                    model = v.vehicle or v.model,
                    label = QBCore.Shared.Vehicles[v.vehicle or v.model] and QBCore.Shared.Vehicles[v.vehicle or v.model].name or (v.vehicle or v.model),
                    state = stateText,
                    isShared = isShared,
                    fuel = v.fuel or 100,
                    engine = v.engine or 1000,
                    body = v.body or 1000,
                    mods = v.mods or "{}"
                })
            end

            if ownedResults then
                for _, v in ipairs(ownedResults) do process(v, false) end
            end
            if sharedResults then
                for _, v in ipairs(sharedResults) do process(v, true) end
            end

            cb(list)
        end)
    end)
end

-- Callback registers
CreateThread(function()
    Wait(1000)
    QBCore = GetCore()
    if not QBCore then return end

    QBCore.Functions.CreateCallback('g4-garage:server:getVehicles', function(source, cb, garageName)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return cb({}) end
        FetchOwnedAndSharedVehicles(Player.PlayerData.citizenid, cb)
    end)

    QBCore.Functions.CreateCallback('g4-garage:server:getCommunityVehicles', function(source, cb, garageName)
        MySQL.query('SELECT * FROM `g4-garage_community_vehicles` WHERE garage_name = ?', {garageName}, function(results)
            local list = {}
            if results then
                for _, row in ipairs(results) do
                    local plate = "COMM" .. tostring(row.id)
                    if row.plate_type == 'custom' and row.custom_plate and row.custom_plate ~= "" then
                        plate = string.upper(row.custom_plate)
                    end
                    table.insert(list, {
                        plate = plate,
                        model = row.model,
                        label = row.label,
                        state = "Available",
                        isCommunity = true,
                        min_grade = row.min_grade,
                        mods = row.mods,
                        plate_type = row.plate_type or 'static'
                    })
                end
            end
            cb(list)
        end)
    end)
end)

-- Spawn Vehicle Event
RegisterNetEvent('g4-garage:server:spawnVehicle', function(plate, model, garageName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    DebugLog(("spawnVehicle triggered. Plate: %s, Model: %s, Garage: %s"):format(tostring(plate), tostring(model), tostring(garageName)))

    local isCommunity = false
    local communityId = nil

    if plate and string.find(plate, "COMM") then
        isCommunity = true
        communityId = tonumber(string.sub(plate, 5))
    end

    -- Check if garage is a community garage (job/gang)
    local garageData = Garages[garageName]
    local isCommunityGarage = false
    if garageData and (garageData.type == 'job' or garageData.type == 'gang') then
        isCommunityGarage = true
    end

    if isCommunity or isCommunityGarage then
        -- We should also check if it's a community garage.
        -- Let's query `g4-garage_community_vehicles` either by id (if communityId parsed) or by garage_name and model.
        local query = ""
        local params = {}
        if communityId then
            query = 'SELECT * FROM `g4-garage_community_vehicles` WHERE id = ?'
            params = {communityId}
        else
            query = 'SELECT * FROM `g4-garage_community_vehicles` WHERE garage_name = ? AND model = ?'
            params = {garageName, model}
        end

        MySQL.single(query, params, function(result)
            if result then
                -- Perform server-side min_grade check for security
                local playerGrade = 0
                if Player.PlayerData.job and Player.PlayerData.job.name == garageData.job_gang_name then
                    playerGrade = Player.PlayerData.job.grade.level or 0
                elseif Player.PlayerData.gang and Player.PlayerData.gang.name == garageData.job_gang_name then
                    playerGrade = Player.PlayerData.gang.grade.level or 0
                end
                
                local minGradeRequired = tonumber(result.min_grade) or 0
                if playerGrade < minGradeRequired then
                    TriggerClientEvent('QBCore:Notify', src, Config.Locales['not_authorized'], 'error')
                    return
                end

                DebugLog(("Found community vehicle in database. ID: %s, Model: %s"):format(tostring(result.id), tostring(result.model)))
                local props = result.mods and json.decode(result.mods) or nil
                local targetPlate = "COMM" .. tostring(result.id)
                
                if result.plate_type == 'random' then
                    local generatedPlate = nil
                    if QBCore.Functions.GeneratePlate then
                        generatedPlate = QBCore.Functions.GeneratePlate()
                    end
                    if not generatedPlate then
                        -- Fallback random string generation
                        local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
                        local randomStr = ''
                        for i = 1, 8 do
                            local rand = math.random(1, #chars)
                            randomStr = randomStr .. string.sub(chars, rand, rand)
                        end
                        generatedPlate = randomStr
                    end
                    targetPlate = string.upper(generatedPlate)
                elseif result.plate_type == 'custom' and result.custom_plate and result.custom_plate ~= "" then
                    targetPlate = string.upper(result.custom_plate)
                end
                
                -- Force target plate inside props if present
                if not props then props = {} end
                props.plate = targetPlate
                
                DebugLog(("Spawning community vehicle with plate: %s"):format(targetPlate))
                TriggerClientEvent('g4-garage:client:spawnVehicle', src, targetPlate, model, props)
            else
                DebugLog("Community vehicle not found in database, spawning fallback")
                TriggerClientEvent('g4-garage:client:spawnVehicle', src, plate, model, nil)
            end
        end)
    else
        -- Citizen vehicle: Check if spawned already on road
        local cleanedPlate = string.gsub(plate, "%s+", ""):upper()
        
        -- Check spawning locks to prevent race condition/multiple spawns
        if SpawningLocks[cleanedPlate] then
            DebugLog(("Blocked spawn request for %s due to active spawning lock."):format(cleanedPlate))
            TriggerClientEvent('QBCore:Notify', src, 'Vehicle is already spawning!', 'error')
            return
        end
        
        -- Check OutVehicles cache using cleaned plates
        local isAlreadyOut = false
        for outPlate, info in pairs(OutVehicles) do
            if string.gsub(outPlate, "%s+", ""):upper() == cleanedPlate then
                isAlreadyOut = true
                break
            end
        end

        DebugLog(("Checking spawn. cleanedPlate: %s, isAlreadyOut (cache): %s"):format(cleanedPlate, tostring(isAlreadyOut)))

        if isAlreadyOut then
            TriggerClientEvent('QBCore:Notify', src, Config.Locales['vehicle_out'], 'error')
            return
        end

        -- Set spawning lock
        SpawningLocks[cleanedPlate] = true
        SetTimeout(7000, function()
            if SpawningLocks[cleanedPlate] then
                DebugLog(("Spawning lock timed out for %s"):format(cleanedPlate))
                SpawningLocks[cleanedPlate] = nil
            end
        end)

        MySQL.single('SELECT mods, state FROM player_vehicles WHERE REPLACE(UPPER(plate), " ", "") = ?', {cleanedPlate}, function(result)
            if not result then
                DebugLog(("Spawn check: Vehicle not found in player_vehicles database! plate: %s"):format(cleanedPlate))
                SpawningLocks[cleanedPlate] = nil
                return
            end
            
            DebugLog(("Spawn check: Database state is %s for plate %s"):format(tostring(result.state), cleanedPlate))
            -- Check if state indicates out on road
            if result.state == 0 then
                TriggerClientEvent('QBCore:Notify', src, Config.Locales['vehicle_out'], 'error')
                SpawningLocks[cleanedPlate] = nil
                return
            end

            local rawMods = result.mods
            DebugLog(("Spawn check: Raw result.mods from database for %s: %s"):format(cleanedPlate, tostring(rawMods)))
            local props = nil
            if rawMods and rawMods ~= "" and rawMods ~= "{}" then
                props = json.decode(rawMods)
            end
            DebugLog(("Spawning vehicle: %s. Decoded mods table exists: %s"):format(cleanedPlate, tostring(props ~= nil)))
            TriggerClientEvent('g4-garage:client:spawnVehicle', src, plate, model, props)
        end)
    end
end)

RegisterNetEvent('g4-garage:server:setVehicleOut', function(plate, netId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local cleanedPlate = string.gsub(plate, "%s+", ""):upper()
    if not string.find(cleanedPlate, "COMM") then
        DebugLog(("setVehicleOut: Marking vehicle %s (netId: %s) as OUT on road"):format(cleanedPlate, tostring(netId)))
        OutVehicles[cleanedPlate] = { netId = netId, owner = Player.PlayerData.citizenid }
        SpawningLocks[cleanedPlate] = nil
        MySQL.update('UPDATE player_vehicles SET state = 0 WHERE REPLACE(UPPER(plate), " ", "") = ?', {cleanedPlate}, function(affectedRows)
            DebugLog(("setVehicleOut: Database updated state=0 for %s. Affected rows: %s"):format(cleanedPlate, tostring(affectedRows)))
        end)
    end
end)

-- Park Vehicle logic
RegisterNetEvent('g4-garage:server:parkVehicle', function(plate, props)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cleanedPlate = string.gsub(plate, "%s+", ""):upper()
    DebugLog(("parkVehicle: Attempting to park %s"):format(cleanedPlate))
    
    if string.find(cleanedPlate, "COMM") then
        DebugLog(("parkVehicle: Community vehicle despawn triggered for %s"):format(cleanedPlate))
        TriggerClientEvent('g4-garage:client:despawnVehicle', src, plate)
    else
        -- Check if it matches a custom static plate configured inside community vehicles
        MySQL.single('SELECT id FROM `g4-garage_community_vehicles` WHERE REPLACE(UPPER(custom_plate), " ", "") = ?', {cleanedPlate}, function(isCustomCommPlate)
            if isCustomCommPlate then
                DebugLog(("parkVehicle: Custom community plate despawn triggered for %s"):format(cleanedPlate))
                TriggerClientEvent('g4-garage:client:despawnVehicle', src, plate)
            else
                MySQL.single('SELECT citizenid FROM player_vehicles WHERE REPLACE(UPPER(plate), " ", "") = ?', {cleanedPlate}, function(result)
                    if not result then
                        DebugLog(("parkVehicle: Vehicle not found in database for plate: %s"):format(cleanedPlate))
                        TriggerClientEvent('QBCore:Notify', src, Config.Locales['invalid_plate'], 'error')
                        return
                    end

                    -- Allow parking if user is owner or it is shared with them
                    local hasAccess = (result.citizenid == Player.PlayerData.citizenid)
                    if not hasAccess then
                        -- Check shares
                        MySQL.single('SELECT id FROM `g4-garage_shares` WHERE REPLACE(UPPER(plate), " ", "") = ? AND shared_with = ?', {cleanedPlate, Player.PlayerData.citizenid}, function(share)
                            if share then
                                -- Retrieve the exact plate string from the database to avoid any spacing mismatches
                                MySQL.single('SELECT plate FROM player_vehicles WHERE REPLACE(UPPER(plate), " ", "") = ?', {cleanedPlate}, function(pv)
                                    local exactPlate = pv and pv.plate or plate
                                    DespawnAndPark(src, exactPlate, props)
                                end)
                            else
                                TriggerClientEvent('QBCore:Notify', src, Config.Locales['not_owner'], 'error')
                            end
                        end)
                    else
                        -- Retrieve the exact plate string from the database to avoid any spacing mismatches
                        MySQL.single('SELECT plate FROM player_vehicles WHERE REPLACE(UPPER(plate), " ", "") = ?', {cleanedPlate}, function(pv)
                            local exactPlate = pv and pv.plate or plate
                            DespawnAndPark(src, exactPlate, props)
                        end)
                    end
                end)
            end
        end)
    end
end)

function DespawnAndPark(src, plate, props)
    TriggerClientEvent('g4-garage:client:despawnVehicle', src, plate)
    
    local cleanedPlate = string.gsub(plate, "%s+", ""):upper()
    OutVehicles[cleanedPlate] = nil
    
    local fuel = 100
    local engine = 1000
    local body = 1000
    local modsStr = "{}"
    
    if type(props) == 'table' then
        fuel = props.fuel or 100
        engine = props.engineHealth or 1000
        body = props.bodyHealth or 1000
        modsStr = json.encode(props)
    end
    
    DebugLog(("DespawnAndPark: Saving vehicle %s with state=1, mods: %s"):format(cleanedPlate, tostring(props ~= nil)))
    
    -- Update using the exact plate column value, and also match cleaned plate as fallback
    MySQL.update('UPDATE player_vehicles SET state = 1, mods = ?, fuel = ?, engine = ?, body = ? WHERE plate = ? OR REPLACE(UPPER(plate), " ", "") = ?', {
        modsStr,
        fuel,
        engine,
        body,
        plate,
        cleanedPlate
    }, function(affectedRows)
        DebugLog(("DespawnAndPark: Database updated state=1 for %s. Affected rows: %s"):format(cleanedPlate, tostring(affectedRows)))
    end)
end

RegisterNetEvent('g4-garage:server:deleteVehicleEntity', function(netId, plate)
    local src = source
    TriggerClientEvent('g4-garage:client:deleteEntity', src, netId)
end)

-- Share Citizen Vehicle logic
RegisterNetEvent('g4-garage:server:shareVehicle', function(plate, targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if not Player or not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, Config.Locales['player_not_found'], 'error')
        return
    end

    MySQL.single('SELECT citizenid FROM player_vehicles WHERE plate = ?', {plate}, function(result)
        if not result or result.citizenid ~= Player.PlayerData.citizenid then
            TriggerClientEvent('QBCore:Notify', src, Config.Locales['not_owner'], 'error')
            return
        end

        MySQL.insert('INSERT INTO `g4-garage_shares` (plate, citizenid, shared_with) VALUES (?, ?, ?)', {
            plate, Player.PlayerData.citizenid, TargetPlayer.PlayerData.citizenid
        }, function(id)
            if id then
                TriggerClientEvent('QBCore:Notify', src, Config.Locales['share_success'], 'success')
                TriggerClientEvent('QBCore:Notify', TargetPlayer.PlayerData.source, 'A vehicle with plate '..plate..' has been shared with you.', 'success')
            else
                TriggerClientEvent('QBCore:Notify', src, Config.Locales['already_shared'], 'error')
            end
        end)
    end)
end)

RegisterNetEvent('g4-garage:server:unshareVehicle', function(plate, targetCitizenId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    MySQL.query('DELETE FROM `g4-garage_shares` WHERE plate = ? AND citizenid = ? AND shared_with = ?', {
        plate, Player.PlayerData.citizenid, targetCitizenId
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', src, Config.Locales['unshare_success'], 'success')
        end
    end)
end)

RegisterNetEvent('g4-garage:server:reclaimVehicle', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local cost = tonumber(Config.ReclaimCost) or 0
    local hasMoney = false
    local account = 'cash'
    
    if cost > 0 then
        if Player.Functions.GetMoney('cash') >= cost then
            hasMoney = true
            account = 'cash'
        elseif Player.Functions.GetMoney('bank') >= cost then
            hasMoney = true
            account = 'bank'
        end
        
        if not hasMoney then
            TriggerClientEvent('QBCore:Notify', src, Config.Locales['not_enough_money'], 'error')
            return
        end
    end

    local cleanedPlate = string.gsub(plate or "", "%s+", ""):upper()
    
    MySQL.single('SELECT citizenid FROM player_vehicles WHERE REPLACE(UPPER(plate), " ", "") = ?', {cleanedPlate}, function(result)
        if not result then
            TriggerClientEvent('QBCore:Notify', src, Config.Locales['invalid_plate'], 'error')
            return
        end
        
        -- Reset cache and database state
        OutVehicles[cleanedPlate] = nil
        MySQL.update('UPDATE player_vehicles SET state = 1 WHERE REPLACE(UPPER(plate), " ", "") = ?', {cleanedPlate}, function(affectedRows)
            if affectedRows > 0 then
                if cost > 0 then
                    Player.Functions.RemoveMoney(account, cost, "vehicle-reclaim")
                    TriggerClientEvent('QBCore:Notify', src, string.format(Config.Locales['reclaimed_success'], tostring(cost)), 'success')
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Vehicle state reset. You can now spawn it!', 'success')
                end
            else
                TriggerClientEvent('QBCore:Notify', src, 'Failed to reclaim vehicle.', 'error')
            end
        end)
    end)
end)
