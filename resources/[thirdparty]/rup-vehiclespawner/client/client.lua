local function fetchVehicleModels()
    local vehicleModels = {}
    local models = GetAllVehicleModels()

    -- Vehicle categories
    local vehicleCategories = {
        [0] = "Compacts",
        [1] = "Sedans",
        [2] = "SUVs",
        [3] = "Coupes",
        [4] = "Muscle",
        [5] = "Sports Classics",
        [6] = "Sports",
        [7] = "Super",
        [8] = "Motorcycles",
        [9] = "Off-road",
        [10] = "Industrial",
        [11] = "Utility",
        [12] = "Vans",
        [13] = "Cycles",
        [14] = "Boats",
        [15] = "Helicopters",
        [16] = "Planes",
        [17] = "Service",
        [18] = "Emergency",
        [19] = "Military",
        [20] = "Commercial",
        [21] = "Trains",
        [22] = "Open Wheel",
    }

    local categorizedVehicles = {}

    for _, model in ipairs(models) do
        local class = GetVehicleClassFromName(model) --[[ Grab all vehicle models in game, including add-on! ]]
        local className = vehicleCategories[class] or "Unknown"

        if not categorizedVehicles[className] then
            categorizedVehicles[className] = {}
        end

        --[[ Insert all vehicles in a table, might be a better way but it works and I like it more 0-0 ]]
        table.insert(categorizedVehicles[className], { model = model})
    end

    SendNUIMessage({
        type = 'setVehicleModels',
        models = categorizedVehicles
    })
end

RegisterNUICallback('spawnVehicle', function(data, cb)
    local model = data.model

    local loaded = lib.requestModel(model, 10000)
    if not loaded then
        cb('error')
        return
    end

    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.5)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)

    if IsPedInAnyVehicle(ped, true) then
        local veh = GetVehiclePedIsIn(ped, false)
        if DoesEntityExist(veh) then
            DeleteVehicle(veh)
        end
    end

    if Config.Warp then SetPedIntoVehicle(ped, vehicle, -1) end

    if Config.Keys == 'qb' or Config.Keys == 'qbx' then
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
    elseif Config.Keys == 'standalone' then
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetVehicleDoorsLocked(vehicle, 1)
        SetVehicleEngineOn(vehicle, true, true, false)
    end

    local fuelSystems = {
        ['legacy'] = function(veh) exports['LegacyFuel']:SetFuel(veh, 100.0) end,
        ['cdn'] = function(veh) exports['cdn-fuel']:SetFuel(veh, 100.0) end,
        ['ox'] = function(veh) Entity(veh).state.fuel = 100.0 end,
        ['standalone'] = function(veh) SetVehicleFuelLevel(veh, 100.0) end
    }

    if fuelSystems[Config.Fuel] then
        fuelSystems[Config.Fuel](vehicle)
    else
        print('No valid fuel system')
    end

    SetModelAsNoLongerNeeded(model)
    if Config.Discord.Enabled then
        TriggerServerEvent('Rup-VehicleSpawner:DiscordLog', data)
    end
    cb('ok')
end)

-- Close UI
RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb({ status = 'closed' })
end)

-- Open UI
RegisterNetEvent('rup-VehicleSpawner:openUi', function()
    SetNuiFocus(true, true)
    fetchVehicleModels()
    SendNUIMessage({ action = "openUI" })
end)