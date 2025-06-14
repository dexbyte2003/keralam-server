-- Ensure QBCore is loaded
local QBCore = exports['qb-core']:GetCoreObject()  -- Correct way to get QBCore export
if not QBCore then
    print('^1 [my_vehicle_unlock] QBCore not found, script might not function correctly! ^7')
    return
end

-- CONFIGURATION
local UNLOCK_KEY = 73 -- Default: 'K' key (check FiveM key mapping for others)
local UNLOCK_RANGE = 5.0 -- Meters: How close you need to be to a vehicle
local NOTIFICATION_DURATION = 2500 -- Milliseconds: How long notifications display

-- You can add a command as an alternative or additional trigger
RegisterCommand('unlockcar', function(source, args, rawCommand)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local closestVehicle = QBCore.Functions.GetClosestVehicle(playerCoords, UNLOCK_RANGE)

    if closestVehicle and DoesEntityExist(closestVehicle) and GetEntityType(closestVehicle) == 2 then
        local vehicleCoords = GetEntityCoords(closestVehicle)
        local distance = #(playerCoords - vehicleCoords)

        if distance <= UNLOCK_RANGE then
            SetVehicleDoorsLocked(closestVehicle, 0)
            SetVehicleUndriveable(closestVehicle, false)
            QBCore.Functions.Notify('Vehicle unlocked via command!', 'success', NOTIFICATION_DURATION)
        else
            QBCore.Functions.Notify('No vehicle in range for command.', 'error', NOTIFICATION_DURATION)
        end
    else
        QBCore.Functions.Notify('No vehicle found nearby for command.', 'error', NOTIFICATION_DURATION)
    end
end, false)


-- You can add a command as an alternative or additional trigger
RegisterCommand('unlockcar', function(source, args, rawCommand)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local closestVehicle = QBCore.Functions.GetClosestVehicle(playerCoords, UNLOCK_RANGE)
    -- local vehicle = GetVehiclePedIsIn(ped)
    local plate = QBCore.Functions.GetPlate(closestVehicle)

    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end, false)
