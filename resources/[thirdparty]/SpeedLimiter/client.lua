local isSpeedSet = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)

        while not IsPedInAnyVehicle(PlayerPedId(), false) do
            Citizen.Wait(2500)
        end

        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local currentSpeed = GetEntitySpeed(vehicle)

        if currentSpeed == 0 then
            Citizen.Wait(2000)
        end

        if vehicle ~= nil then
            isSpeedSet = false
            setSpeed(vehicle)
        end

        while isSpeedSet and IsPedInAnyVehicle(PlayerPedId(), false) do
            local currentVeh = GetVehiclePedIsIn(PlayerPedId(), false)
            if currentVeh ~= vehicle then
                setSpeed(currentVeh)
            end
            Citizen.Wait(2500)
        end
    end
end)

function setSpeed(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)

    if (vehicleClass ~= 16) and (vehicleClass ~= 15) then
        local speed = Config.maxSpeed
        if Config.useCategories then
            speed = Config.Categories[vehicleClass + 1].maxSpeed
        end
        if Config.kmh then
            speed = speed / Config.kmhValue
        else
            speed = speed / Config.mphValue
        end

        SetVehicleMaxSpeed(vehicle, speed)
        isSpeedSet = true
    end
end

function setCustomSpeed(vehicle, customSpeed)
    if customSpeed > 0 then
        if Config.kmh then
            customSpeed = customSpeed / Config.kmhValue
        else
            customSpeed = customSpeed / Config.mphValue
        end

        SetVehicleMaxSpeed(vehicle, customSpeed)
        isSpeedSet = true
        TriggerEvent("chat:addMessage", {
            args = {"Speed limit set to: " .. tostring(customSpeed * (Config.kmh and Config.kmhValue or Config.mphValue)) .. (Config.kmh and " km/h" or " mph")}
        })
    else
        TriggerEvent("chat:addMessage", {
            args = {"Invalid speed value. Please provide a positive number."}
        })
    end
end

RegisterCommand("setSpeed", function(source, args, rawCommand)
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if #args > 0 then
            local customSpeed = tonumber(args[1])
            if customSpeed then
                setCustomSpeed(vehicle, customSpeed)
            else
                TriggerEvent("chat:addMessage", {
                    args = {"Invalid speed value. Please enter a valid number."}
                })
            end
        else
            TriggerEvent("chat:addMessage", {
                args = {"Usage: /setSpeed [speed]"}
            })
        end
    else
        TriggerEvent("chat:addMessage", {
            args = {"You need to be in a vehicle to set the speed limit."}
        })
    end
end, false)



local cruiseEnabled = false
local cruiseSpeed = 0.0

RegisterCommand("setcruise", function(source, args)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
        if #args < 1 then
            QBCore.Functions.Notify("Usage: /setcruise [speed in km/h]", "error")
            return
        end

        cruiseSpeed = tonumber(args[1])

        if not cruiseSpeed or cruiseSpeed <= 0 then
            QBCore.Functions.Notify("Please enter a valid speed (km/h) greater than 0", "error")
            return
        end

        cruiseSpeed = cruiseSpeed / 3.6 -- Convert km/h to m/s
        cruiseEnabled = true

        QBCore.Functions.Notify("Cruise control activated at " .. args[1] .. " km/h", "success")
    else
        QBCore.Functions.Notify("You must be driving a vehicle to use this command", "error")
    end
end)

-- Cancel cruise when brake is pressed
Citizen.CreateThread(function()
    while true do
        Wait(0)

        if cruiseEnabled then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if not IsPedInAnyVehicle(playerPed, false) or IsControlPressed(0, 72) then -- Brake (default key is S)
                cruiseEnabled = false
                QBCore.Functions.Notify("Cruise control deactivated", "primary")
            else
                -- Maintain speed
                SetVehicleForwardSpeed(vehicle, cruiseSpeed)
            end
        end
    end
end)

