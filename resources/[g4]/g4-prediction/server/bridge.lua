Bridge = {}
local CoreObject = nil
local Framework = nil

-- Detect Framework
Citizen.CreateThread(function()
    if GetResourceState('qbox-core') == 'started' then
        Framework = 'qbox'
        CoreObject = exports['qbox-core']
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'qb'
        CoreObject = exports['qb-core']:GetCoreObject()
    else
        print('^1[g4-prediction] Error: Neither qb-core nor qbox-core was detected!^7')
    end
end)

-- Helper to retrieve Player object by source
function Bridge.GetPlayer(source)
    if not CoreObject then return nil end
    if Framework == 'qbox' then
        return exports.qbx_core:GetPlayer(source)
    elseif Framework == 'qb' then
        return CoreObject.Functions.GetPlayer(source)
    end
    return nil
end

-- Helper to retrieve Player object by Citizen ID (online players)
function Bridge.GetPlayerByCitizenId(citizenid)
    if not CoreObject then return nil end
    if Framework == 'qbox' then
        return exports.qbx_core:GetPlayerActiveByCitizenId(citizenid)
    elseif Framework == 'qb' then
        return CoreObject.Functions.GetPlayerByCitizenId(citizenid)
    end
    return nil
end

-- Get player identifier (Citizen ID)
function Bridge.GetCitizenId(Player)
    if not Player then return nil end
    return Player.PlayerData.citizenid
end

-- Get player name
function Bridge.GetName(Player)
    if not Player then return "Unknown" end
    if Player.PlayerData.charinfo then
        return Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    end
    return "Player " .. Player.PlayerData.source
end

-- Check money
function Bridge.GetMoney(Player, moneyType)
    if not Player then return 0 end
    moneyType = moneyType or Config.Currency
    return Player.PlayerData.money[moneyType] or 0
end

-- Add money to online player
function Bridge.AddMoney(Player, amount, reason)
    if not Player or amount <= 0 then return false end
    local moneyType = Config.Currency
    return Player.Functions.AddMoney(moneyType, amount, reason or "Prediction Payout")
end

-- Remove money
function Bridge.RemoveMoney(Player, amount, reason)
    if not Player or amount <= 0 then return false end
    local moneyType = Config.Currency
    if Bridge.GetMoney(Player, moneyType) < amount then return false end
    return Player.Functions.RemoveMoney(moneyType, amount, reason or "Prediction Vote")
end

-- Add money to offline player (via Framework Core functions)
function Bridge.AddOfflineMoney(citizenid, amount, reason)
    local moneyType = Config.Currency
    
    if Framework == 'qbox' then
        local Player = exports.qbx_core:GetOfflinePlayer(citizenid)
        if Player then
            local success = Player.Functions.AddMoney(moneyType, amount, reason)
            if success then
                Player.Functions.Save()
                print(string.format('^2[g4-prediction] Offline payout of $%d added via Qbox Core for citizenid %s (%s)^7', amount, citizenid, reason))
                return true
            end
        end
    elseif Framework == 'qb' and CoreObject then
        local Player = CoreObject.Functions.GetOfflinePlayer(citizenid)
        if Player then
            local success = Player.Functions.AddMoney(moneyType, amount, reason)
            if success then
                Player.Functions.Save()
                print(string.format('^2[g4-prediction] Offline payout of $%d added via QBCore for citizenid %s (%s)^7', amount, citizenid, reason))
                return true
            end
        end
    end
    
    print(string.format('^1[g4-prediction] Error: Failed to add offline payout of $%d to citizenid %s! Framework method failed.^7', amount, citizenid))
    return false
end

-- Check permissions
function Bridge.IsAdmin(source)
    -- 1. Check Config.AdminIdentifiers list
    local playerIdentifiers = GetPlayerIdentifiers(source)
    if playerIdentifiers then
        for _, id in ipairs(playerIdentifiers) do
            for _, allowedId in ipairs(Config.AdminIdentifiers) do
                if id == allowedId then
                    return true
                end
            end
        end
    end

    -- 2. Framework check
    if Framework == 'qbox' then
        for group, _ in pairs(Config.AdminGroups) do
            if exports.qbx_core:HasPermission(source, group) then
                return true
            end
        end
    elseif Framework == 'qb' then
        for group, _ in pairs(Config.AdminGroups) do
            if CoreObject.Functions.HasPermission(source, group) then
                return true
            end
        end
    end

    -- 3. Fallback: Ace check
    if IsPlayerAceAllowed(source, "command") or IsPlayerAceAllowed(source, "g4_prediction.admin") then
        return true
    end

    return false
end

-- Show Notification
function Bridge.Notify(source, message, msgType)
    msgType = msgType or 'primary'
    if Config.NotificationType == 'chat' then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = {"Prediction", message}
        })
    elseif Framework == 'qbox' or Config.NotificationType == 'qbox' then
        exports.qbx_core:Notify(source, message, msgType)
    elseif Framework == 'qb' or Config.NotificationType == 'qb' then
        TriggerClientEvent('QBCore:Notify', source, message, msgType)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {150, 50, 220},
            multiline = true,
            args = {"Prediction", message}
        })
    end
end
