local QBCore = exports['qb-core']:GetCoreObject()


local disableHudComponents = Config.Disable.hudComponents
local disableControls = Config.Disable.controls
local displayAmmo = Config.Disable.displayAmmo

local function decorSet(Type, Value)
    if Type == 'parked' then
        Config.Density.parked = Value
    elseif Type == 'vehicle' then
        Config.Density.vehicle = Value
    elseif Type == 'multiplier' then
        Config.Density.multiplier = Value
    elseif Type == 'peds' then
        Config.Density.peds = Value
    elseif Type == 'scenario' then
        Config.Density.scenario = Value
    end
end

exports('DecorSet', decorSet)

CreateThread(function()
    while true do

        for i = 1, #disableHudComponents do
            HideHudComponentThisFrame(disableHudComponents[i])
        end

        for i = 1, #disableControls do
            DisableControlAction(2, disableControls[i], true)
        end

        DisplayAmmoThisFrame(displayAmmo)

        SetParkedVehicleDensityMultiplierThisFrame(Config.Density.parked)
        SetVehicleDensityMultiplierThisFrame(Config.Density.vehicle)
        SetRandomVehicleDensityMultiplierThisFrame(Config.Density.multiplier)
        SetPedDensityMultiplierThisFrame(Config.Density.peds)
        SetScenarioPedDensityMultiplierThisFrame(Config.Density.scenario, Config.Density.scenario) -- Walking NPC Density
        Wait(0)
    end
end)

exports('addDisableHudComponents', function(hudComponents)
    local hudComponentsType = type(hudComponents)
    if hudComponentsType == 'number' then
        disableHudComponents[#disableHudComponents + 1] = hudComponents
    elseif hudComponentsType == 'table' and table.type(hudComponents) == "array" then
        for i = 1, #hudComponents do
            disableHudComponents[#disableHudComponents + 1] = hudComponents[i]
        end
    end
end)

exports('removeDisableHudComponents', function(hudComponents)
    local hudComponentsType = type(hudComponents)
    if hudComponentsType == 'number' then
        for i = 1, #disableHudComponents do
            if disableHudComponents[i] == hudComponents then
                table.remove(disableHudComponents, i)
                break
            end
        end
    elseif hudComponentsType == 'table' and table.type(hudComponents) == "array" then
        for i = 1, #disableHudComponents do
            for i2 = 1, #hudComponents do
                if disableHudComponents[i] == hudComponents[i2] then
                    table.remove(disableHudComponents, i)
                end
            end
        end
    end
end)

exports('getDisableHudComponents', function() return disableHudComponents end)

exports('addDisableControls', function(controls)
    local controlsType = type(controls)
    if controlsType == 'number' then
        disableControls[#disableControls + 1] = controls
    elseif controlsType == 'table' and table.type(controls) == "array" then
        for i = 1, #controls do
            disableControls[#disableControls + 1] = controls[i]
        end
    end
end)

exports('removeDisableControls', function(controls)
    local controlsType = type(controls)
    if controlsType == 'number' then
        for i = 1, #disableControls do
            if disableControls[i] == controls then
                table.remove(disableControls, i)
                break
            end
        end
    elseif controlsType == 'table' and table.type(controls) == "array" then
        for i = 1, #disableControls do
            for i2 = 1, #controls do
                if disableControls[i] == controls[i2] then
                    table.remove(disableControls, i)
                end
            end
        end
    end
end)

exports('getDisableControls', function() return disableControls end)

exports('setDisplayAmmo', function(bool) displayAmmo = bool end)

exports('getDisplayAmmo', function() return displayAmmo end)



-- Admin Control NPC
-- Function to Set NPC Density
local function setNPCDensity(parked, vehicle, multiplier, peds, scenario)
    Config.Density.parked = parked
    Config.Density.vehicle = vehicle
    Config.Density.multiplier = multiplier
    Config.Density.peds = peds
    Config.Density.scenario = scenario
end

-- Apply Density Settings Every Frame
CreateThread(function()
    while true do
        Wait(0)
        SetParkedVehicleDensityMultiplierThisFrame(Config.Density.parked)
        SetVehicleDensityMultiplierThisFrame(Config.Density.vehicle)
        SetRandomVehicleDensityMultiplierThisFrame(Config.Density.multiplier)
        SetPedDensityMultiplierThisFrame(Config.Density.peds)
        SetScenarioPedDensityMultiplierThisFrame(Config.Density.scenario)
    end
end)

RegisterCommand("setnpc", function(source, args, rawCommand)
    if args[1] == nil then
        TriggerEvent('chat:addMessage', {
            args = {"^1Usage", "/setnpc [true/false]"}
        })
        return
    end

    -- Check Player Permission (if using a framework like QBCore)
    local player = PlayerPedId()
    local IsUserAdmin = false
    QBCore.Functions.TriggerCallback('qb-admin:isAdmin', function(isAdmin)
        if isAdmin then
            -- Toggle NPC Density
            local state = tostring(args[1]):lower()
            if state == "true" then
                setNPCDensity(0.8, 0.8, 0.8, 0.8, 0.8) -- Set all NPC density values to 0.8 for high density
                TriggerEvent('chat:addMessage', {
                    args = {"^2NPC Density", "Set to high (0.8)."}
                })
            elseif state == "false" then
                setNPCDensity(0.0, 0.0, 0.0, 0.0, 0.0) -- Set all NPC density values to 0.0 for low density
                TriggerEvent('chat:addMessage', {
                    args = {"^2NPC Density", "Set to low (0.0)."}
                })
            else
                TriggerEvent('chat:addMessage', {
                    args = {"^1Usage", "/setnpc [true/false]"}
                })
            end
        else
            TriggerEvent('chat:addMessage', {
                args = {"^1Error", "You do not have permission to use this command!"}
            })
        end
    end)
end, false)