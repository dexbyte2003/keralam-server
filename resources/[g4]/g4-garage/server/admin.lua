local QBCore = nil

local function GetCore()
    if GetResourceState('qb-core') == 'started' then
        return exports['qb-core']:GetCoreObject()
    end
    return nil
end

local function DebugLog(msg)
    if Config.Debug then
        print("[g4-garage] [DEBUG] " .. tostring(msg))
    end
end

RegisterCommand('garageadmin', function(source, args, rawCommand)
    local src = source
    DebugLog("/garageadmin triggered by source: " .. tostring(src))
    QBCore = GetCore()
    if not QBCore then
        DebugLog("Error: Framework core object not found!")
        return
    end
    if src == 0 then return end
    
    local isGod = false
    if exports['qbx_core'] and GetResourceState('qbx_core') == 'started' then
        isGod = exports['qbx_core']:HasPermission(src, 'god') or exports['qbx_core']:HasPermission(src, 'admin')
        DebugLog("qbx_core permission check result: " .. tostring(isGod))
    else
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            -- Fallback checks for standard QBCore structures
            local permission = QBCore.Functions.GetPermission(src)
            DebugLog("qb-core permission returned: " .. json.encode(permission))
            if type(permission) == 'string' then
                isGod = (permission == 'god' or permission == 'admin')
            elseif type(permission) == 'table' then
                isGod = permission['god'] or permission['admin']
            end
            
            if not isGod and QBCore.Functions.HasPermission then
                isGod = QBCore.Functions.HasPermission(src, 'god') or QBCore.Functions.HasPermission(src, 'admin')
            end
        else
            DebugLog("Error: Player object not resolved for source: " .. tostring(src))
        end
    end

    DebugLog("Final isGod clearance: " .. tostring(isGod))
    if isGod then
        TriggerClientEvent('g4-garage:client:openAdminMenu', src, true)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have access to this command.', 'error')
    end
end)

RegisterCommand('viewgarage', function(source, args, rawCommand)
    local src = source
    QBCore = GetCore()
    if src == 0 then return end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid Player ID. Usage: /viewgarage [id]', 'error')
        return
    end

    local isGod = false
    if exports['qbx_core'] and GetResourceState('qbx_core') == 'started' then
        isGod = exports['qbx_core']:HasPermission(src, 'god') or exports['qbx_core']:HasPermission(src, 'admin')
    else
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local permission = QBCore.Functions.GetPermission(src)
            if type(permission) == 'string' then
                isGod = (permission == 'god' or permission == 'admin')
            elseif type(permission) == 'table' then
                isGod = permission['god'] or permission['admin']
            end
            if not isGod and QBCore.Functions.HasPermission then
                isGod = QBCore.Functions.HasPermission(src, 'god') or QBCore.Functions.HasPermission(src, 'admin')
            end
        end
    end

    if isGod then
        local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
        if not TargetPlayer then
            TriggerClientEvent('QBCore:Notify', src, 'Target player not online.', 'error')
            return
        end
        local citizenid = TargetPlayer.PlayerData.citizenid
        TriggerClientEvent('g4-garage:client:openPlayerGarageForAdmin', src, citizenid, targetId)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have access to this command.', 'error')
    end
end)

RegisterCommand('addthisveh', function(source, args, rawCommand)
    local src = source
    QBCore = GetCore()
    if src == 0 then return end

    local isGod = false
    if exports['qbx_core'] and GetResourceState('qbx_core') == 'started' then
        isGod = exports['qbx_core']:HasPermission(src, 'god') or exports['qbx_core']:HasPermission(src, 'admin')
    else
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local permission = QBCore.Functions.GetPermission(src)
            if type(permission) == 'string' then
                isGod = (permission == 'god' or permission == 'admin')
            elseif type(permission) == 'table' then
                isGod = permission['god'] or permission['admin']
            end
        end
    end

    if not isGod then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have access to this command.', 'error')
        return
    end

    -- Usage: /addthisveh [citizenid/playerid/community] [garage_name]
    local targetType = args[1] -- citizenid, playerid, or community
    local targetVal = args[2]  -- target details identifier value

    if not targetType or not targetVal then
        TriggerClientEvent('QBCore:Notify', src, 'Usage: /addthisveh [citizenid / playerid / community] [value]', 'error')
        return
    end

    TriggerClientEvent('g4-garage:client:retrieveCurrentVehProperties', src, targetType, targetVal)
end)

RegisterNetEvent('g4-garage:server:addCustomizedVehicle', function(props, model, plate, targetType, targetVal)
    local src = source
    QBCore = GetCore()
    if not props or not model or not plate then return end

    if targetType == 'community' then
        -- Add to community vehicles fleet
        MySQL.insert('INSERT INTO `g4-garage_community_vehicles` (garage_name, model, label, min_grade, mods) VALUES (?, ?, ?, ?, ?)', {
            targetVal, model, model, 0, json.encode(props)
        }, function(id)
            if id then
                TriggerClientEvent('QBCore:Notify', src, 'Customized vehicle model '..model..' added to '..targetVal..' fleet!', 'success')
            end
        end)
    else
        local citizenid = targetVal
        local license = 'unknown'

        if targetType == 'playerid' then
            local targetId = tonumber(targetVal)
            if targetId then
                local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
                if TargetPlayer then
                    citizenid = TargetPlayer.PlayerData.citizenid
                    license = TargetPlayer.PlayerData.license
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Target player not online.', 'error')
                    return
                end
            else
                TriggerClientEvent('QBCore:Notify', src, 'Invalid Player ID.', 'error')
                return
            end
        else
            -- citizenid fallback
            local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenid)
            if TargetPlayer then
                license = TargetPlayer.PlayerData.license
            end
        end

        MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            license,
            citizenid,
            model,
            GetHashKey(model),
            json.encode(props),
            plate,
            1
        }, function(id)
            if id then
                TriggerClientEvent('QBCore:Notify', src, 'Customized vehicle ('..plate..') successfully added to '..citizenid..' garage!', 'success')
            end
        end)
    end
end)

-- Admin Callback helper for initial load data
CreateThread(function()
    Wait(1000)
    QBCore = GetCore()
    if not QBCore then return end

    QBCore.Functions.CreateCallback('g4-garage:server:adminGetPlayerName', function(source, cb, data)
        local response = { name = nil, citizenid = nil }
        if data.identType == 'playerid' then
            local targetId = tonumber(data.playerid)
            if targetId then
                local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
                if TargetPlayer then
                    response.name = TargetPlayer.PlayerData.charinfo.firstname .. " " .. TargetPlayer.PlayerData.charinfo.lastname
                    response.citizenid = TargetPlayer.PlayerData.citizenid
                end
            end
        else
            -- Search online players by citizen ID
            local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(data.citizenid)
            if TargetPlayer then
                response.name = TargetPlayer.PlayerData.charinfo.firstname .. " " .. TargetPlayer.PlayerData.charinfo.lastname
                response.citizenid = TargetPlayer.PlayerData.citizenid
            else
                -- Fallback lookup in database charinfo if offline
                local result = MySQL.single.await('SELECT charinfo, citizenid FROM players WHERE citizenid = ?', {data.citizenid})
                if result then
                    local charinfo = json.decode(result.charinfo)
                    if charinfo then
                        response.name = (charinfo.firstname or "") .. " " .. (charinfo.lastname or "") .. " (Offline)"
                        response.citizenid = result.citizenid
                    end
                end
            end
        end
        cb(response)
    end)

    QBCore.Functions.CreateCallback('g4-garage:server:getAdminPlayerGarageData', function(source, cb, targetCitizenid)
        MySQL.query('SELECT * FROM player_vehicles WHERE citizenid = ?', {targetCitizenid}, function(vehicles)
            local data = {}
            if vehicles then
                for _, v in ipairs(vehicles) do
                    table.insert(data, {
                        plate = v.plate,
                        citizenid = v.citizenid,
                        model = v.vehicle or v.model,
                        label = QBCore.Shared.Vehicles[v.vehicle or v.model] and QBCore.Shared.Vehicles[v.vehicle or v.model].name or (v.vehicle or v.model),
                        state = v.state == 1 and "In Garage" or "Out on Road",
                        fuel = v.fuel or 100,
                        engine = v.engine or 1000,
                        body = v.body or 1000,
                        mods = v.mods or "{}"
                    })
                end
            end
            cb(data)
        end)
    end)

    QBCore.Functions.CreateCallback('g4-garage:server:getAdminGarageData', function(source, cb)
        MySQL.query('SELECT * FROM `g4-garage_list`', {}, function(garages)
            MySQL.query('SELECT * FROM player_vehicles', {}, function(vehicles)
                local data = {
                    garages = garages or {},
                    vehicles = {}
                }
                if vehicles then
                    for _, v in ipairs(vehicles) do
                        table.insert(data.vehicles, {
                            plate = v.plate,
                            citizenid = v.citizenid,
                            model = v.vehicle or v.model,
                            state = v.state == 1 and "In Garage" or "Out on Road",
                            fuel = v.fuel or 100
                        })
                    end
                end
                cb(data)
            end)
        end)
    end)
end)

-- Create Garage
RegisterNetEvent('g4-garage:server:createGarage', function(data)
    local src = source
    MySQL.insert('INSERT INTO `g4-garage_list` (name, label, type, coords, job_gang_name, min_grade) VALUES (?, ?, ?, ?, ?, ?)', {
        data.name, data.label, data.type, data.coords, data.job_gang_name, data.min_grade
    }, function(id)
        if id then
            TriggerClientEvent('QBCore:Notify', src, Config.Locales['garage_created'], 'success')
            LoadGaragesFromDatabase()
        end
    end)
end)

-- Delete Garage
RegisterNetEvent('g4-garage:server:deleteGarage', function(name)
    local src = source
    MySQL.query('DELETE FROM `g4-garage_list` WHERE name = ?', {name}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', src, Config.Locales['garage_deleted'], 'success')
            LoadGaragesFromDatabase()
        end
    end)
end)

-- Add Community/Job Vehicle
RegisterNetEvent('g4-garage:server:adminAddCommunityVehicle', function(data)
    local src = source
    MySQL.insert('INSERT INTO `g4-garage_community_vehicles` (garage_name, model, label, min_grade, plate_type, custom_plate) VALUES (?, ?, ?, ?, ?, ?)', {
        data.garage_name, data.model, data.label, tonumber(data.min_grade) or 0, data.plate_type or 'static', data.custom_plate
    }, function(id)
        if id then
            TriggerClientEvent('QBCore:Notify', src, 'Community vehicle added successfully!', 'success')
        end
    end)
end)

RegisterNetEvent('g4-garage:server:adminDeleteCommunityVehicle', function(id)
    local src = source
    MySQL.query('DELETE FROM `g4-garage_community_vehicles` WHERE id = ?', {id}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Community fleet vehicle deleted.', 'success')
        end
    end)
end)

RegisterNetEvent('g4-garage:server:adminManageCommunityVehicle', function(data)
    local src = source
    MySQL.update('UPDATE `g4-garage_community_vehicles` SET label = ?, min_grade = ?, plate_type = ?, custom_plate = ? WHERE id = ?', {
        data.label,
        tonumber(data.min_grade) or 0,
        data.plate_type or 'static',
        data.custom_plate,
        data.id
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Fleet vehicle updated successfully.', 'success')
        end
    end)
end)

CreateThread(function()
    Wait(1000)
    QBCore = GetCore()
    if not QBCore then return end
    QBCore.Functions.CreateCallback('g4-garage:server:adminGetCommunityVehicles', function(source, cb, garageName)
        MySQL.query('SELECT * FROM `g4-garage_community_vehicles` WHERE garage_name = ?', {garageName}, function(results)
            local list = {}
            if results then
                for _, row in ipairs(results) do
                    table.insert(list, {
                        id = row.id,
                        model = row.model,
                        label = row.label,
                        min_grade = row.min_grade,
                        plate_type = row.plate_type,
                        custom_plate = row.custom_plate
                    })
                end
            end
            cb(list)
        end)
    end)
end)

-- Admin Citizen Vehicle management
RegisterNetEvent('g4-garage:server:adminAddVehicle', function(data)
    local src = source
    local citizenid = data.citizenid
    local license = 'unknown'
    
    if data.identType == 'playerid' then
        local targetId = tonumber(data.playerid)
        if targetId then
            local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
            if TargetPlayer then
                citizenid = TargetPlayer.PlayerData.citizenid
                license = TargetPlayer.PlayerData.license
            else
                TriggerClientEvent('QBCore:Notify', src, 'Player ID not online.', 'error')
                return
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Invalid Player ID format.', 'error')
            return
        end
    else
        -- Using Citizen ID
        local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(data.citizenid)
        if TargetPlayer then
            license = TargetPlayer.PlayerData.license
        end
    end

    if not citizenid or citizenid == "" then
        TriggerClientEvent('QBCore:Notify', src, 'Citizen ID cannot be empty.', 'error')
        return
    end

    local plate = data.plate
    if not plate or plate == "" then
        plate = QBCore.Functions.GeneratePlate()
    end
    plate = string.upper(plate)

    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        license,
        citizenid,
        data.model,
        GetHashKey(data.model),
        '{}',
        plate,
        1
    }, function(id)
        if id then
            TriggerClientEvent('QBCore:Notify', src, 'Vehicle '..plate..' added to player '..citizenid, 'success')
        end
    end)
end)

RegisterNetEvent('g4-garage:server:adminDeleteVehicle', function(plate)
    local src = source
    MySQL.query('DELETE FROM player_vehicles WHERE plate = ?', {plate}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Vehicle '..plate..' deleted from database.', 'success')
        end
    end)
end)

RegisterNetEvent('g4-garage:server:adminSpawnVehicle', function(plate, model)
    local src = source
    MySQL.single('SELECT mods FROM player_vehicles WHERE plate = ?', {plate}, function(result)
        local props = result and result.mods and json.decode(result.mods) or nil
        TriggerClientEvent('g4-garage:client:adminSpawnSpawned', src, plate, model, props)
    end)
end)

RegisterNetEvent('g4-garage:server:adminManageVehicle', function(data)
    local src = source
    local targetState = tonumber(data.state) or 1
    local origPlate = data.originalPlate or data.plate
    local cleanOrigPlate = string.gsub(origPlate, "%s+", ""):upper()
    local newPlate = string.upper(data.plate or origPlate)
    
    -- Check if plate is changed and check modifications json update
    MySQL.single('SELECT mods FROM player_vehicles WHERE REPLACE(UPPER(plate), " ", "") = ?', {cleanOrigPlate}, function(vehicleData)
        if not vehicleData then return end
        
        local mods = json.decode(vehicleData.mods or '{}')
        mods.plate = newPlate -- Update within internal properties block
        
        MySQL.update('UPDATE player_vehicles SET plate = ?, state = ?, fuel = ?, mods = ? WHERE REPLACE(UPPER(plate), " ", "") = ?', {
            newPlate,
            targetState,
            tonumber(data.fuel) or 100,
            json.encode(mods),
            cleanOrigPlate
        }, function(affectedRows)
            if affectedRows > 0 then
                TriggerClientEvent('QBCore:Notify', src, 'Vehicle details updated successfully.', 'success')
                
                -- Despawn if state set to In Garage
                if targetState == 1 then
                    local netId = nil
                    if OutVehicles[cleanOrigPlate] then
                        netId = OutVehicles[cleanOrigPlate].netId
                        OutVehicles[cleanOrigPlate] = nil
                    end
                    local cleanNewPlate = string.gsub(newPlate, "%s+", ""):upper()
                    if OutVehicles[cleanNewPlate] then
                        netId = OutVehicles[cleanNewPlate].netId
                        OutVehicles[cleanNewPlate] = nil
                    end
                    TriggerClientEvent('g4-garage:client:deleteEntity', -1, netId, origPlate)
                    TriggerClientEvent('g4-garage:client:deleteEntity', -1, netId, newPlate)
                end
            end
        end)
    end)
end)
