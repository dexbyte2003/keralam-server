-- Simple server-side chat handler

RegisterCommand('chat', function(source, args, rawCommand)
    local msg = table.concat(args, " ")
    if msg == "" then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 255, 0, 0 },
            args = { "SYSTEM", "Usage: /chat [message]" }
        })
        return
    end

    local playerName = GetPlayerName(source)
    -- TriggerClientEvent('postMessage', -1, {
    --     color = { 0, 255, 0 },
    --     args = { playerName, msg }
    -- })
    TriggerClientEvent('postMessage', -1, playerName, 'twitter', msg)
end, false)


local QBCore = exports['qb-core']:GetCoreObject()

-- Function to create job-only commands
local function RegisterJobCommand(jobName)
    RegisterCommand(jobName, function(source, args)
        local Player = QBCore.Functions.GetPlayer(source)
        local msg = table.concat(args, " ")

        -- Check if player has the right job
        if Player.PlayerData.job.name ~= jobName then
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 },
                args = { "SYSTEM", "You are not an " .. jobName:upper() }
            })
            return
        end

        -- No message typed
        if msg == "" then
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 },
                args = { "SYSTEM", "Usage: /" .. jobName .. " [message]" }
            })
            return
        end

        -- Send to all players with the same job
        for _, id in pairs(QBCore.Functions.GetPlayers()) do
            local Target = QBCore.Functions.GetPlayer(id)
            if Target.PlayerData.job.name == jobName then
                -- TriggerClientEvent('postMessage', id, {
                --     color = { 0, 150, 255 },
                --     args = { "[" .. jobName:upper() .. "] " .. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, msg }
                -- })
                TriggerClientEvent('postMessage', -1, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, jobName, msg)
            end
        end
    end, false)
end

-- Create commands for specific jobs
RegisterJobCommand("ambulance")
RegisterJobCommand("police")
RegisterJobCommand("mechanic")
