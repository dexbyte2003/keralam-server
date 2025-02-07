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
