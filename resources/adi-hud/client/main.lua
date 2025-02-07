local QBCore = exports['qb-core']:GetCoreObject()

local function updateHud()
    local playerPed = PlayerPedId()
    local playerId = GetPlayerServerId(PlayerId())
    local playerName = GetPlayerName(PlayerId())
    local health = (GetEntityHealth(playerPed) - 100) / 100 * 100
    local armor = GetPedArmour(playerPed)
    local speed = math.ceil(GetEntitySpeed(GetVehiclePedIsIn(playerPed, false)) * 3.6)
    local job = QBCore.Functions.GetPlayerData().job.name
    local jobRole = QBCore.Functions.GetPlayerData().job.grade.name
    local moneyHand = QBCore.Functions.GetPlayerData().money['cash']
    local moneyBank = QBCore.Functions.GetPlayerData().money['bank']

    SendNUIMessage({
        type = "updateHud",
        playerId = playerId,
        playerName = playerName,
        job = job,
        jobRole = jobRole,
        moneyHand = moneyHand,
        moneyBank = moneyBank,
        health = health,
        armor = armor,
        speed = speed
    })
end

CreateThread(function()
    while true do
        updateHud()
        Wait(1000) -- Update every second
    end
end)
