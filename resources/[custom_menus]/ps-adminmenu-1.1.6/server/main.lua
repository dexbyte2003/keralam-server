QBCore = exports['qb-core']:GetCoreObject()

lib.addCommand('admingui', {
    help = 'Open the admin menu',
    restricted = 'qbcore.mod'
}, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    -- if not QBCore.Functions.IsOptin(source) then TriggerClientEvent('QBCore:Notify', source, 'You are not on admin duty', 'error'); return end
    if QBCore.Functions.HasPermission(source, 'admin') then TriggerClientEvent('QBCore:Notify', source,'You are not on admin duty. You are a: ' .. (Player and Player.PlayerData.group or 'unknown'), 'error'); return end
    TriggerClientEvent('ps-adminmenu:client:OpenUI', source)
end)
-- Callbacks
