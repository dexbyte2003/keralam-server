-- client.lua

-- Get the QB-Core object
local QBCore = exports['qb-core']:GetCoreObject()

-- Local copy of player data
local playerData = {}

-- Configuration: Set your server name here
local config = {}
config.ServerName = "Keralam"  -- Change this to your server's name

-- Function to update the NUI display
local function UpdateUI()
    local displayData = {}

    -- Set player name from character info if available
    if playerData.charinfo then
        displayData.playerName = playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname
    else
        displayData.playerName = "Unknown"
    end

    -- Retrieve the player server ID using the native function
    displayData.playerId = GetPlayerServerId(PlayerId())

    -- Set money info (bank and cash)
    displayData.bank = (playerData.money and playerData.money.bank) or 0
    displayData.cash = (playerData.money and playerData.money.cash) or 0

    -- Set job and job label
    displayData.job = (playerData.job and playerData.job.name) or "None"
    displayData.jobLabel = (playerData.job and playerData.job.label) or "None"
    displayData.jobGrade = (playerData.job and playerData.job.grade.name) or "None"

    -- Set server name from config
    displayData.serverName = config.ServerName

    -- Send the updated data to the NUI
    SendNUIMessage({
        action = "update",
        data = displayData
    })
end

-- Update the UI when the player is loaded
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function(data)
    playerData = data
    UpdateUI()
end)

-- Update money when it changes
RegisterNetEvent('QBCore:Player:OnMoneyChange', function(moneyType, amount)
    if playerData.money then
        playerData.money[moneyType] = amount
    end
    UpdateUI()
end)

-- Update job information when it changes
RegisterNetEvent('QBCore:Player:OnJobUpdate', function(job)
    playerData.job = job
    UpdateUI()
end)

-- (Optional) A periodic update to ensure UI remains current.
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local newData = QBCore.Functions.GetPlayerData()
        if newData then
            playerData = newData
            UpdateUI()
        end
    end
end)
