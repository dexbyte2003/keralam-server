-- server.lua

local QBCore = exports['qb-core']:GetCoreObject()

-- Callback to get total number of players
QBCore.Functions.CreateCallback('getPlayerCount', function(source, cb)
    local players = QBCore.Functions.GetQBPlayers()
    cb(#players)
end)

-- Callback to get current server time
QBCore.Functions.CreateCallback('getServerTime', function(source, cb)
    local time = os.date("*t") -- Local server time
    cb(time)
end)
