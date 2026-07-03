local Predictions = {
    active = {},
    history = {}
}
local isDirty = false
local resourceLoaded = false

-- Loading Data
local function LoadData()
    local file = LoadResourceFile(GetCurrentResourceName(), "predictions.json")
    if file then
        local success, data = pcall(json.decode, file)
        if success and data then
            Predictions = data
            if not Predictions.active then Predictions.active = {} end
            if not Predictions.history then Predictions.history = {} end
            -- Ensure totals structure matches expectations (handling legacy/empty states)
            for _, pred in pairs(Predictions.active) do
                if not pred.totals then
                    pred.totals = {}
                    for i = 1, #pred.options do pred.totals[i] = 0 end
                end
                if not pred.totalPool then pred.totalPool = 0 end
                if not pred.votes then pred.votes = {} end
            end
        else
            print('^3[g4-prediction] Warn: Failed to parse predictions.json, initializing empty state.^7')
        end
    else
        -- Create initial empty file structure directly in resource root
        SaveResourceFile(GetCurrentResourceName(), "predictions.json", json.encode(Predictions), -1)
    end
    resourceLoaded = true
end

-- Saving Data (Immediate Write to prevent data loss on crashes)
local function SaveData()
    if not resourceLoaded then return end
    local success = SaveResourceFile(GetCurrentResourceName(), "predictions.json", json.encode(Predictions), -1)
    if not success then
        print('^1[g4-prediction] Error: Failed to save predictions.json!^7')
    end
end

-- Initialize Data on Start
Citizen.CreateThread(function()
    LoadData()
end)

-- Ensure data is saved on resource stopping (optional safety)
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SaveData()
    end
end)

-- Helper to sanitize prediction data for a specific client to minimize payload size
local function GetSanitizedPredictions(citizenid)
    local sanitized = {}
    for id, pred in pairs(Predictions.active) do
        local myVote = pred.votes[citizenid]
        
        -- Mask stats if hideUntilEnded is enabled OR showStats is disabled (when player hasn't voted yet and voting is open)
        local maskStats = false
        if pred.hideUntilEnded then
            maskStats = true
        elseif (pred.showStats == false) and (not myVote) and (pred.status == 'open') then
            maskStats = true
        end
        
        local totals = {}
        if maskStats then
            for i = 1, #pred.options do totals[i] = 0 end
        else
            totals = pred.totals
        end
        
        sanitized[id] = {
            id = pred.id,
            question = pred.question,
            type = pred.type,
            options = pred.options,
            status = pred.status,
            totals = totals,
            totalPool = maskStats and 0 or pred.totalPool,
            showStats = pred.showStats ~= false,
            hideUntilEnded = pred.hideUntilEnded == true,
            myVote = myVote and { option = myVote.option, amount = myVote.amount } or nil,
            createdAt = pred.createdAt
        }
    end
    return sanitized
end

-- Helper to sanitize history data for a specific client (returns only their own vote & payout details)
local function GetSanitizedHistory(citizenid)
    local sanitized = {}
    for idx, hist in ipairs(Predictions.history) do
        local myVote = hist.votes and hist.votes[citizenid]
        local clientVote = nil
        if myVote then
            local payout = 0
            if hist.type == 'prediction' then
                if myVote.option == hist.winner then
                    local winningPool = hist.totals[hist.winner] or 0
                    if winningPool > 0 then
                        payout = math.floor(myVote.amount * (hist.totalPool / winningPool))
                    end
                end
            end
            clientVote = {
                option = myVote.option,
                amount = myVote.amount,
                payout = payout
            }
        end
        
        sanitized[idx] = {
            id = hist.id,
            question = hist.question,
            type = hist.type,
            options = hist.options,
            status = hist.status,
            winner = hist.winner,
            totals = hist.totals,
            totalPool = hist.totalPool,
            myVote = clientVote,
            endedAt = hist.endedAt
        }
    end
    return sanitized
end

-- Refresh prediction status for all online clients who have menu active
local function BroadcastPredictionsUpdate()
    local players = GetPlayers()
    for _, srcStr in ipairs(players) do
        local src = tonumber(srcStr)
        local Player = Bridge.GetPlayer(src)
        if Player then
            local citizenid = Bridge.GetCitizenId(Player)
            if citizenid then
                TriggerClientEvent('g4-prediction:client:SyncPredictions', src, GetSanitizedPredictions(citizenid), GetSanitizedHistory(citizenid))
            end
        end
    end
end

-- Fetch predictions data for single player
RegisterNetEvent('g4-prediction:server:GetPredictionsData', function()
    local src = source
    local Player = Bridge.GetPlayer(src)
    if not Player then return end
    local citizenid = Bridge.GetCitizenId(Player)
    if not citizenid then return end
    
    TriggerClientEvent('g4-prediction:client:SyncPredictions', src, GetSanitizedPredictions(citizenid), GetSanitizedHistory(citizenid))
end)

-- Cast Vote
RegisterNetEvent('g4-prediction:server:CastVote', function(predictionId, optionIndex, betAmount)
    local src = source
    local Player = Bridge.GetPlayer(src)
    if not Player then return end
    local citizenid = Bridge.GetCitizenId(Player)
    if not citizenid then return end
    
    local idStr = tostring(predictionId)
    local idNum = tonumber(predictionId)
    local prediction = Predictions.active[idStr] or (idNum and Predictions.active[idNum])
    if not prediction then
        Bridge.Notify(src, "Prediction not found", "error")
        return
    end

    if prediction.status ~= 'open' then
        Bridge.Notify(src, "Voting is closed for this prediction", "error")
        return
    end

    -- Verify option bounds
    optionIndex = tonumber(optionIndex)
    if not optionIndex or optionIndex < 1 or optionIndex > #prediction.options then
        Bridge.Notify(src, "Invalid voting option selected", "error")
        return
    end

    -- Verify player hasn't already voted (O(1) dictionary lookup)
    if prediction.votes[citizenid] then
        Bridge.Notify(src, "You have already voted on this prediction", "error")
        return
    end

    betAmount = tonumber(betAmount) or 0

    if prediction.type == 'prediction' then
        if betAmount < Config.MinBet then
            Bridge.Notify(src, string.format("Minimum bet is $%d", Config.MinBet), "error")
            return
        end
        if betAmount > Config.MaxBet then
            Bridge.Notify(src, string.format("Maximum bet is $%d", Config.MaxBet), "error")
            return
        end

        -- Check player money and deduct
        local playerMoney = Bridge.GetMoney(Player)
        if playerMoney < betAmount then
            Bridge.Notify(src, "Insufficient funds", "error")
            return
        end

        local deducted = Bridge.RemoveMoney(Player, betAmount, "Prediction Bet: ID " .. predictionId)
        if not deducted then
            Bridge.Notify(src, "Failed to deduct money", "error")
            return
        end

        -- Add vote
        prediction.votes[citizenid] = {
            option = optionIndex,
            amount = betAmount,
            name = Bridge.GetName(Player),
            citizenid = citizenid
        }
        prediction.totals[optionIndex] = (prediction.totals[optionIndex] or 0) + betAmount
        prediction.totalPool = (prediction.totalPool or 0) + betAmount
        
        Bridge.Notify(src, string.format("Voted option '%s' with $%d!", prediction.options[optionIndex], betAmount), "success")
    else
        -- Normal Poll
        prediction.votes[citizenid] = {
            option = optionIndex,
            amount = 0,
            name = Bridge.GetName(Player),
            citizenid = citizenid
        }
        prediction.totals[optionIndex] = (prediction.totals[optionIndex] or 0) + 1
        prediction.totalPool = (prediction.totalPool or 0) + 1

        Bridge.Notify(src, string.format("Voted for option '%s'!", prediction.options[optionIndex]), "success")
    end

    SaveData()
    BroadcastPredictionsUpdate()
end)

-- Admin Operations Check
RegisterNetEvent('g4-prediction:server:RequestAdminCheck', function()
    local src = source
    local isAdmin = Bridge.IsAdmin(src)
    TriggerClientEvent('g4-prediction:client:ReceiveAdminCheck', src, isAdmin)
end)

-- Create Prediction (Admin)
RegisterNetEvent('g4-prediction:server:CreatePrediction', function(question, predType, options, showStats, hideUntilEnded)
    local src = source
    if not Bridge.IsAdmin(src) then
        Bridge.Notify(src, "Unauthorized", "error")
        return
    end

    if not question or question == "" then
        Bridge.Notify(src, "Question cannot be empty", "error")
        return
    end

    if not options or #options < 2 then
        Bridge.Notify(src, "At least two options are required", "error")
        return
    end

    local id = tostring(os.time())
    local totals = {}
    for i = 1, #options do totals[i] = 0 end

    Predictions.active[id] = {
        id = id,
        question = question,
        type = predType, -- 'prediction' or 'poll'
        options = options,
        status = 'open',
        totals = totals,
        totalPool = 0,
        showStats = showStats ~= false,
        hideUntilEnded = hideUntilEnded == true,
        votes = {},
        createdAt = os.time()
    }

    SaveData()
    Bridge.Notify(src, "Prediction created successfully", "success")
    BroadcastPredictionsUpdate()
end)

-- Close Voting (Admin)
RegisterNetEvent('g4-prediction:server:CloseVoting', function(predictionId)
    local src = source
    if not Bridge.IsAdmin(src) then
        Bridge.Notify(src, "Unauthorized", "error")
        return
    end

    local idStr = tostring(predictionId)
    local idNum = tonumber(predictionId)
    local prediction = Predictions.active[idStr] or (idNum and Predictions.active[idNum])
    if not prediction then return end

    prediction.status = 'closed'
    SaveData()
    Bridge.Notify(src, "Voting closed for prediction", "success")
    BroadcastPredictionsUpdate()
end)

-- End Prediction & Process Payouts (Admin)
RegisterNetEvent('g4-prediction:server:EndPrediction', function(predictionId, winningOptionIndex)
    local src = source
    if not Bridge.IsAdmin(src) then
        Bridge.Notify(src, "Unauthorized", "error")
        return
    end

    local idStr = tostring(predictionId)
    local idNum = tonumber(predictionId)
    local prediction = Predictions.active[idStr] or (idNum and Predictions.active[idNum])
    if not prediction then return end

    winningOptionIndex = tonumber(winningOptionIndex)
    if not winningOptionIndex or winningOptionIndex < 1 or winningOptionIndex > #prediction.options then
        Bridge.Notify(src, "Invalid winning option index", "error")
        return
    end

    -- Handle Money Bet Payouts
    if prediction.type == 'prediction' and prediction.totalPool > 0 then
        local totalPool = prediction.totalPool
        local winningPool = prediction.totals[winningOptionIndex] or 0

        if winningPool > 0 then
            -- standard pari-mutuel payout ratio calculation
            local payoutRatio = totalPool / winningPool

            for citizenid, vote in pairs(prediction.votes) do
                if vote.option == winningOptionIndex then
                    local payout = math.floor(vote.amount * payoutRatio)
                    if payout > 0 then
                        -- Safe payout block to prevent loop crashes on invalid player objects
                        local success, err = pcall(function()
                            local targetPlayer = Bridge.GetPlayerByCitizenId(citizenid)
                            if targetPlayer then
                                Bridge.AddMoney(targetPlayer, payout, "Prediction Win ID " .. idStr)
                                Bridge.Notify(targetPlayer.PlayerData.source, string.format("You won $%d from the prediction: '%s'!", payout, prediction.question), "success")
                            else
                                Bridge.AddOfflineMoney(citizenid, payout, "Prediction Win ID " .. idStr)
                            end
                        end)
                        if not success then
                            print(string.format("^1[g4-prediction] Payout failed for voter %s: %s^7", citizenid, err))
                        end
                    end
                end
            end
        else
            -- If nobody voted for the winning option, refund all money to voters
            for citizenid, vote in pairs(prediction.votes) do
                local success, err = pcall(function()
                    local targetPlayer = Bridge.GetPlayerByCitizenId(citizenid)
                    if targetPlayer then
                        Bridge.AddMoney(targetPlayer, vote.amount, "Prediction Refund ID " .. idStr)
                        Bridge.Notify(targetPlayer.PlayerData.source, string.format("No winners. Your bet of $%d has been refunded.", vote.amount), "primary")
                    else
                        Bridge.AddOfflineMoney(citizenid, vote.amount, "Prediction Refund ID " .. idStr)
                    end
                end)
                if not success then
                    print(string.format("^1[g4-prediction] Refund failed for voter %s: %s^7", citizenid, err))
                end
            end
            print(string.format("^3[g4-prediction] Warning: No winners for prediction ID %s. All bets refunded.^7", idStr))
        end
    end

    -- Add to History
    local historyItem = {
        id = prediction.id,
        question = prediction.question,
        type = prediction.type,
        options = prediction.options,
        status = 'ended',
        winner = winningOptionIndex,
        totals = prediction.totals,
        totalPool = prediction.totalPool,
        votes = prediction.votes, -- Keep votes array for payout history details
        endedAt = os.time()
    }
    table.insert(Predictions.history, historyItem)

    -- Prune History to prevent file bloat
    if #Predictions.history > Config.MaxHistoryItems then
        table.remove(Predictions.history, 1)
    end

    -- Remove from Active
    Predictions.active[idStr] = nil
    if idNum then Predictions.active[idNum] = nil end
    SaveData()

    Bridge.Notify(src, "Prediction resolved successfully", "success")
    BroadcastPredictionsUpdate()
end)

-- Cancel Prediction (Admin)
RegisterNetEvent('g4-prediction:server:CancelPrediction', function(predictionId)
    local src = source
    if not Bridge.IsAdmin(src) then
        Bridge.Notify(src, "Unauthorized", "error")
        return
    end

    local idStr = tostring(predictionId)
    local idNum = tonumber(predictionId)
    local prediction = Predictions.active[idStr] or (idNum and Predictions.active[idNum])
    if not prediction then return end

    -- Refund Everyone
    if prediction.type == 'prediction' then
        for citizenid, vote in pairs(prediction.votes) do
            local success, err = pcall(function()
                local targetPlayer = Bridge.GetPlayerByCitizenId(citizenid)
                if targetPlayer then
                    Bridge.AddMoney(targetPlayer, vote.amount, "Prediction Cancelled Refund ID " .. idStr)
                    Bridge.Notify(targetPlayer.PlayerData.source, string.format("Prediction cancelled. Your bet of $%d was refunded.", vote.amount), "primary")
                else
                    Bridge.AddOfflineMoney(citizenid, vote.amount, "Prediction Cancelled Refund ID " .. idStr)
                end
            end)
            if not success then
                print(string.format("^1[g4-prediction] Cancellation refund failed for voter %s: %s^7", citizenid, err))
            end
        end
    end

    -- Remove from active without history (since it was cancelled)
    Predictions.active[idStr] = nil
    if idNum then Predictions.active[idNum] = nil end
    SaveData()

    Bridge.Notify(src, "Prediction cancelled and all bets refunded", "success")
    BroadcastPredictionsUpdate()
end)
