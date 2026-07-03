local isUIOpen = false

-- Open Voter UI
local function OpenVoterUI()
    if isUIOpen then return end
    
    -- Request fresh data from server before showing NUI
    TriggerServerEvent('g4-prediction:server:GetPredictionsData')
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openUI",
        isAdmin = false,
        config = {
            minBet = Config.MinBet,
            maxBet = Config.MaxBet,
            currency = Config.Currency
        }
    })
    isUIOpen = true
end

-- Open Admin UI (After server-side validation)
local function OpenAdminUI()
    if isUIOpen then return end
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openUI",
        isAdmin = true,
        config = {
            minBet = Config.MinBet,
            maxBet = Config.MaxBet,
            currency = Config.Currency
        }
    })
    isUIOpen = true
    
    -- Sync data to ensure everything is fresh
    TriggerServerEvent('g4-prediction:server:GetPredictionsData')
end

-- Register Voter Command
RegisterCommand(Config.VoterCommand, function()
    OpenVoterUI()
end, false)

-- Register Admin Command
RegisterCommand(Config.AdminCommand, function()
    -- Check permissions with server before opening
    TriggerServerEvent('g4-prediction:server:RequestAdminCheck')
end, false)

-- Receive Admin Validation
RegisterNetEvent('g4-prediction:client:ReceiveAdminCheck', function(isAdmin)
    if isAdmin then
        OpenAdminUI()
    else
        -- Framework notifications are triggered by server, but client fallback is fine
        SendNUIMessage({
            action = "notify",
            message = "You do not have permission to access the admin panel.",
            type = "error"
        })
    end
end)

-- Receive Synced Prediction Data from Server
RegisterNetEvent('g4-prediction:client:SyncPredictions', function(activePredictions, historyPredictions)
    SendNUIMessage({
        action = "syncData",
        active = activePredictions,
        history = historyPredictions
    })
end)

-- NUI CALLBACKS --

-- Close UI
RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    isUIOpen = false
    cb('ok')
end)

-- Cast Vote Callback
RegisterNUICallback('castVote', function(data, cb)
    if not data.predictionId or not data.optionIndex then 
        cb('error')
        return 
    end
    
    TriggerServerEvent('g4-prediction:server:CastVote', data.predictionId, data.optionIndex, data.betAmount or 0)
    cb('ok')
end)

-- Admin Create Prediction Callback
RegisterNUICallback('createPrediction', function(data, cb)
    if not data.question or not data.type or not data.options then
        cb('error')
        return
    end

    TriggerServerEvent('g4-prediction:server:CreatePrediction', data.question, data.type, data.options, data.showStats, data.hideUntilEnded)
    cb('ok')
end)

-- Admin Close Voting Callback
RegisterNUICallback('closeVoting', function(data, cb)
    if not data.predictionId then 
        cb('error') 
        return 
    end
    
    TriggerServerEvent('g4-prediction:server:CloseVoting', data.predictionId)
    cb('ok')
end)

-- Admin End Prediction (Declare Winner) Callback
RegisterNUICallback('endPrediction', function(data, cb)
    if not data.predictionId or not data.winningOptionIndex then
        cb('error')
        return
    end

    TriggerServerEvent('g4-prediction:server:EndPrediction', data.predictionId, data.winningOptionIndex)
    cb('ok')
end)

-- Admin Cancel Prediction Callback
RegisterNUICallback('cancelPrediction', function(data, cb)
    if not data.predictionId then
        cb('error')
        return
    end

    TriggerServerEvent('g4-prediction:server:CancelPrediction', data.predictionId)
    cb('ok')
end)
