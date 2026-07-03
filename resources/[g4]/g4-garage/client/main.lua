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

local function GetPlayerJobGang()
    QBCore = GetCore()
    if not QBCore then return nil, nil, 0 end
    local PlayerData
    if exports['qbx_core'] and GetResourceState('qbx_core') == 'started' then
        PlayerData = exports['qbx_core']:GetPlayerData()
        return PlayerData.job.name, PlayerData.gang.name, PlayerData.job.grade.level
    else
        PlayerData = QBCore.Functions.GetPlayerData()
        return PlayerData.job.name, PlayerData.gang.name, PlayerData.job.grade.level
    end
end

-- Client garages cache
local Garages = {}
local CurrentGarage = nil
local CurrentGarageData = {}

RegisterNetEvent('g4-garage:client:syncGarages', function(syncedGarages)
    Garages = syncedGarages
    RefreshBlips()
end)

-- Blips management
local Blips = {}
function RefreshBlips()
    if not Config.BlipsEnabled then return end
    for _, blip in ipairs(Blips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    Blips = {}
    for name, data in pairs(Garages) do
        local coords = json.decode(data.coords)
        if coords and coords.menu then
            local blip = AddBlipForCoord(coords.menu.x, coords.menu.y, coords.menu.z)
            SetBlipSprite(blip, 357)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.7)
            if data.type == 'job' then
                SetBlipColour(blip, 3)
            elseif data.type == 'gang' then
                SetBlipColour(blip, 1)
            else
                SetBlipColour(blip, 38)
            end
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(data.label)
            EndTextCommandSetBlipName(blip)
            table.insert(Blips, blip)
        end
    end
end

-- Nearest Zone Checker Thread
CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local inRange = false

        for name, data in pairs(Garages) do
            local coords = json.decode(data.coords)
            if coords then
                -- Menu Check
                if coords.menu then
                    local dist = #(pos - vector3(coords.menu.x, coords.menu.y, coords.menu.z))
                    if dist < 5.0 then
                        wait = 0
                        inRange = true
                        DrawMarker(2, coords.menu.x, coords.menu.y, coords.menu.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 250, 222, false, false, false, true, false, false, false)
                        if dist < 1.5 then
                            ShowHelpNotification("Press ~INPUT_CONTEXT~ to open " .. data.label)
                            if IsControlJustReleased(0, 38) then
                                OpenGarageMenu(name, data)
                            end
                        end
                    end
                end

                -- Delete Point (Park) Check
                if coords.delete then
                    local dist = #(pos - vector3(coords.delete.x, coords.delete.y, coords.delete.z))
                    if dist < 7.0 then
                        wait = 0
                        inRange = true
                        DrawMarker(1, coords.delete.x, coords.delete.y, coords.delete.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 0.5, 255, 70, 70, 150, false, false, false, false, false, false, false)
                        if dist < 3.5 and IsPedInAnyVehicle(ped, false) then
                            ShowHelpNotification("Press ~INPUT_CONTEXT~ to park vehicle")
                            if IsControlJustReleased(0, 38) then
                                ParkVehicle()
                            end
                        end
                    end
                end
            end
        end
        Wait(wait)
    end
end)

function ShowHelpNotification(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function OpenGarageMenu(name, data)
    local job, gang, grade = GetPlayerJobGang()
    if data.type == 'job' and data.job_gang_name ~= job then
        TriggerEvent('QBCore:Notify', Config.Locales['not_authorized'], 'error')
        return
    elseif data.type == 'gang' and data.job_gang_name ~= gang then
        TriggerEvent('QBCore:Notify', Config.Locales['not_authorized'], 'error')
        return
    end

    CurrentGarage = name
    CurrentGarageData = data

    QBCore = GetCore()
    if data.type == 'citizen' then
        QBCore.Functions.TriggerCallback('g4-garage:server:getVehicles', function(vehicles)
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openGarage',
                type = 'citizen',
                vehicles = vehicles,
                garageName = data.label
            })
        end, name)
    else
        -- Community Garages
        QBCore.Functions.TriggerCallback('g4-garage:server:getCommunityVehicles', function(vehicles)
            -- Filter vehicles by the player's grade level
            local filteredVehicles = {}
            for _, v in ipairs(vehicles) do
                local minGrade = tonumber(v.min_grade) or 0
                if grade >= minGrade then
                    table.insert(filteredVehicles, v)
                end
            end

            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openGarage',
                type = 'community',
                vehicles = filteredVehicles,
                garageName = data.label
            })
        end, name)
    end
end

function ParkVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return end
    
    QBCore = GetCore()
    if not QBCore then
        DebugLog("Error: Cannot park vehicle because QBCore is nil!")
        return
    end

    -- GetPlate can return trailing spaces or mismatched cases. Trim it.
    local plate = string.gsub(GetVehicleNumberPlateText(veh) or "", "%s+", ""):upper()
    
    -- Retrieve mods
    local props = nil
    local success, err = pcall(function()
        if exports['qbx_core'] and GetResourceState('qbx_core') == 'started' then
            props = exports['qbx_core']:GetVehicleProperties(veh)
        else
            props = QBCore.Functions.GetVehicleProperties(veh)
        end
    end)

    if not success or not props then
        DebugLog("Error retrieving vehicle properties: " .. tostring(err))
        -- Fallback to basic plate structure if properties failed
        props = { plate = plate }
    end

    DebugLog(("ParkVehicle: Triggering server park for plate %s"):format(plate))
    TriggerServerEvent('g4-garage:server:parkVehicle', plate, props)
end

RegisterNetEvent('g4-garage:client:despawnVehicle', function(plate)
    local pedsVeh = GetVehiclePedIsIn(PlayerPedId(), true)
    local netId = NetworkGetNetworkIdFromEntity(pedsVeh)
    TriggerServerEvent('g4-garage:server:deleteVehicleEntity', netId, plate)
end)

RegisterNetEvent('g4-garage:client:deleteEntity', function(netId, plate)
    local deleted = false
    if netId and NetworkDoesNetworkIdExist(netId) then
        local veh = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(veh) then
            SetEntityAsMissionEntity(veh, true, true)
            DeleteVehicle(veh)
            DeleteEntity(veh)
            deleted = true
        end
    end
    
    -- Fallback: find vehicle by matching plate in close vicinity
    if not deleted and plate then
        local cleanedPlate = string.gsub(plate, "%s+", "")
        local vehicles = GetGamePool('CVehicle')
        for _, veh in ipairs(vehicles) do
            local vehPlate = string.gsub(GetVehicleNumberPlateText(veh) or "", "%s+", "")
            if vehPlate == cleanedPlate then
                SetEntityAsMissionEntity(veh, true, true)
                DeleteVehicle(veh)
                DeleteEntity(veh)
                break
            end
        end
    end
end)

-- UI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    SetNuiFocus(false, false)
    
    -- Client-side double check: Find vehicle in the list and verify if it's already out
    local isOut = false
    if data.plate then
        local cleanedPlate = string.gsub(data.plate, "%s+", ""):upper()
        -- If we have a local cache or can verify the UI state, check it.
        -- We will let the server check, but we pass the clean plate.
    end

    TriggerServerEvent('g4-garage:server:spawnVehicle', data.plate, data.model, CurrentGarage)
    cb('ok')
end)

RegisterNUICallback('shareVehicle', function(data, cb)
    TriggerServerEvent('g4-garage:server:shareVehicle', data.plate, data.targetId)
    cb('ok')
end)

RegisterNUICallback('unshareVehicle', function(data, cb)
    TriggerServerEvent('g4-garage:server:unshareVehicle', data.plate, data.targetCitizenId)
    cb('ok')
end)

RegisterNUICallback('trackVehicle', function(data, cb)
    SetNuiFocus(false, false)
    local plate = string.gsub(data.plate or "", "%s+", ""):upper()
    local targetCoords = nil
    
    -- Find vehicle entity by plate in player's vicinity
    local vehicles = GetGamePool('CVehicle')
    for _, veh in ipairs(vehicles) do
        local vehPlate = string.gsub(GetVehicleNumberPlateText(veh) or "", "%s+", ""):upper()
        if vehPlate == plate then
            targetCoords = GetEntityCoords(veh)
            break
        end
    end
    
    if targetCoords then
        SetNewWaypoint(targetCoords.x, targetCoords.y)
        QBCore.Functions.Notify("Vehicle location marked on your GPS waypoint map!", "success")
    else
        QBCore.Functions.Notify("Vehicle GPS signal lost! Cannot locate the vehicle physically.", "error")
    end
    cb('ok')
end)

RegisterNUICallback('reclaimVehicle', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('g4-garage:server:reclaimVehicle', data.plate)
    cb('ok')
end)

RegisterNetEvent('g4-garage:client:spawnVehicle', function(plate, model, props)
    local coords = json.decode(CurrentGarageData.coords)
    if not coords or not coords.spawn then return end
    
    QBCore = GetCore()
    
    -- Check if spawn point is blocked, if so, dynamically offset to find a free spot
    local spawnX = coords.spawn.x
    local spawnY = coords.spawn.y
    local spawnZ = coords.spawn.z
    local heading = coords.spawn.w or 0.0

    local closestVeh = GetClosestVehicle(spawnX, spawnY, spawnZ, 3.0, 0, 71)
    if DoesEntityExist(closestVeh) then
        -- Find free spot by checking offsets (spiral search with larger spacing)
        local offsets = {
            {x = 5.5, y = 0.0}, {x = -5.5, y = 0.0},
            {x = 0.0, y = 5.5}, {x = 0.0, y = -5.5},
            {x = 5.5, y = 5.5}, {x = -5.5, y = -5.5},
            {x = -5.5, y = 5.5}, {x = 5.5, y = -5.5}
        }
        local foundSpot = false
        for _, offset in ipairs(offsets) do
            local testX = spawnX + offset.x
            local testY = spawnY + offset.y
            local testVeh = GetClosestVehicle(testX, testY, spawnZ, 3.5, 0, 71)
            if not DoesEntityExist(testVeh) then
                spawnX = testX
                spawnY = testY
                foundSpot = true
                break
            end
        end
        if not foundSpot then
            -- Fallback: spawn slightly above or alert user if completely filled
            TriggerEvent('QBCore:Notify', 'All spawn locations blocked!', 'error')
            return
        end
    end
    
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local vehicle = CreateVehicle(hash, spawnX, spawnY, spawnZ, heading, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    
    DebugLog(("Spawning vehicle: %s (model: %s). Has props: %s"):format(plate, model, tostring(props ~= nil)))
    if props then
        DebugLog("Mod Data payload: " .. json.encode(props))
    else
        DebugLog("Mod Data payload is nil!")
    end
    
    SetVehicleNumberPlateText(vehicle, plate)
    
    if props then
        -- Enforce the correct plate inside the props table
        props.plate = plate
        local success, err = pcall(function()
            if exports['qbx_core'] and GetResourceState('qbx_core') == 'started' then
                exports['qbx_core']:SetVehicleProperties(vehicle, props)
            else
                if QBCore then
                    QBCore.Functions.SetVehicleProperties(vehicle, props)
                else
                    DebugLog("Error: QBCore is nil, cannot set vehicle properties!")
                end
            end
        end)
        if not success then
            DebugLog("Error applying vehicle properties: " .. tostring(err))
        else
            DebugLog("Vehicle properties applied successfully.")
        end
    end

    -- Re-enforce plate just in case setting properties changed/reset it
    SetVehicleNumberPlateText(vehicle, plate)

    SetVehRadioStation(vehicle, "OFF")
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    
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

-- Resource start sync
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('g4-garage:server:requestSync')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerServerEvent('g4-garage:server:requestSync')
    end
end)
