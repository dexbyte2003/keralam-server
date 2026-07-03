local QBCore = nil

local function GetCore()
    if GetResourceState('qb-core') == 'started' then
        return exports['qb-core']:GetCoreObject()
    end
    return nil
end

local tempGarageCoords = {}

RegisterNetEvent('g4-garage:client:openAdminMenu', function(isGod)
    print("[g4-garage] Client received openAdminMenu event, isGod: " .. tostring(isGod))
    if not isGod then return end
    QBCore = GetCore()
    if not QBCore then
        print("[g4-garage] Client error: GetCore() returned nil")
    end
    
    -- Request active garages & citizen vehicles list for management
    QBCore.Functions.TriggerCallback('g4-garage:server:getAdminGarageData', function(data)
        print("[g4-garage] Client received admin data callback. Opening NUI.")
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openAdmin',
            garages = data.garages,
            vehicles = data.vehicles
        })
    end)
end)

-- NUI callbacks for admin actions
RegisterNUICallback('adminSetCoords', function(data, cb)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    if data.type == 'menu' then
        tempGarageCoords.menu = { x = pos.x, y = pos.y, z = pos.z }
        TriggerEvent('QBCore:Notify', 'Menu coordinate set!', 'success')
    elseif data.type == 'spawn' then
        tempGarageCoords.spawn = { x = pos.x, y = pos.y, z = pos.z, w = heading }
        TriggerEvent('QBCore:Notify', 'Spawn coordinate set!', 'success')
    elseif data.type == 'delete' then
        tempGarageCoords.delete = { x = pos.x, y = pos.y, z = pos.z }
        TriggerEvent('QBCore:Notify', 'Delete coordinate set!', 'success')
    end
    cb('ok')
end)

RegisterNUICallback('createGarage', function(data, cb)
    if not tempGarageCoords.menu or not tempGarageCoords.spawn or not tempGarageCoords.delete then
        TriggerEvent('QBCore:Notify', 'Please set all 3 coordinates first!', 'error')
        cb('error')
        return
    end

    TriggerServerEvent('g4-garage:server:createGarage', {
        name = data.name,
        label = data.label,
        type = data.type,
        coords = json.encode(tempGarageCoords),
        job_gang_name = data.job_gang_name,
        min_grade = tonumber(data.min_grade) or 0
    })

    tempGarageCoords = {}
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('deleteGarage', function(data, cb)
    TriggerServerEvent('g4-garage:server:deleteGarage', data.name)
    cb('ok')
end)

RegisterNUICallback('adminAddVehicle', function(data, cb)
    TriggerServerEvent('g4-garage:server:adminAddVehicle', data)
    cb('ok')
end)

RegisterNUICallback('adminGetPlayerName', function(data, cb)
    QBCore.Functions.TriggerCallback('g4-garage:server:adminGetPlayerName', function(playerData)
        cb(playerData)
    end, data)
end)

RegisterNUICallback('adminDeleteVehicle', function(data, cb)
    TriggerServerEvent('g4-garage:server:adminDeleteVehicle', data.plate)
    cb('ok')
end)

RegisterNUICallback('adminSpawnVehicle', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('g4-garage:server:adminSpawnVehicle', data.plate, data.model)
    cb('ok')
end)

RegisterNUICallback('adminManageVehicle', function(data, cb)
    TriggerServerEvent('g4-garage:server:adminManageVehicle', data)
    cb('ok')
end)

RegisterNUICallback('adminAddCommunityVehicle', function(data, cb)
    TriggerServerEvent('g4-garage:server:adminAddCommunityVehicle', data)
    cb('ok')
end)

RegisterNUICallback('adminGetCommunityVehicles', function(data, cb)
    QBCore.Functions.TriggerCallback('g4-garage:server:adminGetCommunityVehicles', function(vehicles)
        cb(vehicles)
    end, data.garageName)
end)

RegisterNUICallback('adminDeleteCommunityVehicle', function(data, cb)
    TriggerServerEvent('g4-garage:server:adminDeleteCommunityVehicle', data.id)
    cb('ok')
end)

RegisterNUICallback('adminManageCommunityVehicle', function(data, cb)
    TriggerServerEvent('g4-garage:server:adminManageCommunityVehicle', data)
    cb('ok')
end)

RegisterNetEvent('g4-garage:client:adminSpawnSpawned', function(plate, model, props)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local vehicle = CreateVehicle(hash, pos.x, pos.y, pos.z, heading, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleNumberPlateText(vehicle, plate)
    
    QBCore = GetCore()
    if props then
        props.plate = plate
        local success, err = pcall(function()
            if exports['qbx_core'] and GetResourceState('qbx_core') == 'started' then
                exports['qbx_core']:SetVehicleProperties(vehicle, props)
            else
                if QBCore then
                    QBCore.Functions.SetVehicleProperties(vehicle, props)
                else
                    print("[g4-garage] Error: QBCore is nil, cannot set vehicle properties!")
                end
            end
        end)
        if not success then
            print("[g4-garage] Error applying vehicle properties (admin spawn): " .. tostring(err))
        end
    end

    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    
    -- Wait for the entity to be networked before obtaining its netId
    local timeout = 100
    while not NetworkGetEntityIsNetworked(vehicle) and timeout > 0 do
        Wait(10)
        timeout = timeout - 1
    end
    
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent('g4-garage:server:setVehicleOut', plate, netId)

    -- Give keys to player
    local actualPlate = GetVehicleNumberPlateText(vehicle)
    TriggerEvent('vehiclekeys:client:SetOwner', actualPlate)
end)

RegisterNetEvent('g4-garage:client:openPlayerGarageForAdmin', function(targetCitizenid, targetId)
    QBCore = GetCore()
    QBCore.Functions.TriggerCallback('g4-garage:server:getAdminPlayerGarageData', function(vehicles)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openGarage',
            type = 'citizen',
            vehicles = vehicles,
            garageName = "Admin Player View (ID: " .. targetId .. ")",
            isAdmin = true,
            targetCitizenid = targetCitizenid,
            targetId = targetId
        })
    end, targetCitizenid)
end)

RegisterNetEvent('g4-garage:client:retrieveCurrentVehProperties', function(targetType, targetVal)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        TriggerEvent('QBCore:Notify', 'You must be sitting inside a vehicle!', 'error')
        return
    end

    QBCore = GetCore()
    local props
    if exports['qbx_core'] and GetResourceState('qbx_core') == 'started' then
        props = exports['qbx_core']:GetVehicleProperties(veh)
    else
        props = QBCore.Functions.GetVehicleProperties(veh)
    end

    local modelHash = GetEntityModel(veh)
    -- We can get the exact spawn code from the QBCore shared vehicles list if it matches
    local modelName = nil
    if QBCore and QBCore.Shared and QBCore.Shared.Vehicles then
        for spawnCode, data in pairs(QBCore.Shared.Vehicles) do
            if GetHashKey(spawnCode) == modelHash then
                modelName = spawnCode
                break
            end
        end
    end

    if not modelName then
        modelName = GetDisplayNameFromVehicleModel(modelHash):lower()
    end

    local plate = GetVehicleNumberPlateText(veh)

    TriggerServerEvent('g4-garage:server:addCustomizedVehicle', props, modelName, plate, targetType, targetVal)
end)
