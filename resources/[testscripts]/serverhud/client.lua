-- client.lua

-- Get the QB-Core object
local QBCore = exports['qb-core']:GetCoreObject()

-- Local copy of player data
local playerData = {}

-- Configuration: Set your server name here
local config = {}
config.ServerName = "Keralam" -- Change this to your server's name

-- Function to update the NUI display
local function UpdateUI()
    local displayData = {}

    -- Set player name
    if playerData.charinfo then
        displayData.playerName = playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname
    else
        displayData.playerName = "Unknown"
    end

    -- Player ID
    displayData.playerId = GetPlayerServerId(PlayerId())

    -- Money
    displayData.bank = (playerData.money and playerData.money.bank) or 0
    displayData.cash = (playerData.money and playerData.money.cash) or 0

    -- Job
    displayData.job = (playerData.job and playerData.job.name) or "None"
    displayData.jobLabel = (playerData.job and playerData.job.label) or "None"
    displayData.jobGrade = (playerData.job and playerData.job.grade.name) or "None"

    -- Server name
    displayData.serverName = config.ServerName

    -- Fetch total players and server time, then send to NUI
    QBCore.Functions.TriggerCallback('getPlayerCount', function(playerCount)
        displayData.totalPlayers = playerCount

        QBCore.Functions.TriggerCallback('getServerTime', function(serverTime)
            displayData.serverTime = string.format("%02d:%02d:%02d", serverTime.hour, serverTime.min, serverTime.sec)

            -- Send to NUI
            SendNUIMessage({
                action = "update",
                data = displayData
            })
        end)
    end)
end

function getTime()
    hour = GetClockHours()
    minute = GetClockMinutes()
    if hour <= 9 then
        hour = "0" .. hour
    end
    if minute <= 9 then
        minute = "0" .. minute
    end
    return hour .. ":" .. minute
end


-- On player loaded
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function(data)
    playerData = data
    UpdateUI()
end)

-- On money change
RegisterNetEvent('QBCore:Player:OnMoneyChange', function(moneyType, amount)
    if playerData.money then
        playerData.money[moneyType] = amount
    end
    UpdateUI()
end)

-- On job update
RegisterNetEvent('QBCore:Player:OnJobUpdate', function(job)
    playerData.job = job
    UpdateUI()
end)

-- Periodic UI refresh
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000) -- every 10 seconds
        local newData = QBCore.Functions.GetPlayerData()
        if newData then
            playerData = newData
            UpdateUI()
        end
    end
end)

-- Command to manually check data
RegisterCommand("refreshui", function()
    local newData = QBCore.Functions.GetPlayerData()
    if newData then
        playerData = newData
        UpdateUI()
    end
end, false)
