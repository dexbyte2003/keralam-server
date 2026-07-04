local savedPeds = {}
local isUiOpen = false

-- 1. SETUP: Register the starting character
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(0) end
    
    local myPed = PlayerPedId()
    savedPeds[0] = { 
        entity = myPed, 
        model = "Main Character", 
        id = 0,
        isMain = true 
    }
end)

-- 2. BACKGROUND TASK: The "Anchor" Loop
-- Keeps everyone existing in the world
Citizen.CreateThread(function()
    while true do
        Wait(500) -- Increased speed to 500ms for better protection
        for id, data in pairs(savedPeds) do
            local ped = data.entity
            
            -- Only protect peds we aren't currently controlling
            if DoesEntityExist(ped) and ped ~= PlayerPedId() then
                SetEntityAsMissionEntity(ped, true, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetPedCanRagdoll(ped, false)
                
                -- Keep engine on if in vehicle
                if IsPedInAnyVehicle(ped, false) then
                    local veh = GetVehiclePedIsIn(ped, false)
                    SetVehicleEngineOn(veh, true, true, false)
                end
            end
        end
    end
end)

-- 3. COMMANDS & UI
RegisterCommand('npcmenu', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "open" })
    isUiOpen = true
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    isUiOpen = false
    cb('ok')
end)

-- 4. SPAWN NEW NPC
RegisterNUICallback('spawn', function(data, cb)
    local modelName = data.model
    local hash = GetHashKey(modelName)

    if not IsModelInCdimage(hash) then
        cb({ success = false, message = "Invalid Model" })
        return
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local x, y, z = table.unpack(coords + forward * 2.0)

    local ped = CreatePed(26, hash, x, y, z, 0.0, true, true)
    SetEntityAsMissionEntity(ped, true, true)
    TaskStandStill(ped, -1) 
    SetModelAsNoLongerNeeded(hash)

    local pedId = #savedPeds + 1
    savedPeds[pedId] = { entity = ped, model = modelName, id = pedId, isMain = false }

    -- Update UI
    local uiList = {}
    for k, v in pairs(savedPeds) do
        if not v.isMain then table.insert(uiList, v) end
    end
    SendNUIMessage({ type = "updateList", peds = uiList })
    cb({ success = true })
end)

-- 5. SWITCH LOGIC (Fixes Deletion & Emotes)
RegisterNUICallback('play', function(data, cb)
    local targetId = data.id
    local targetPedEntity = nil

    -- A. Find Target
    if savedPeds[targetId] then
        targetPedEntity = savedPeds[targetId].entity
    end

    if not targetPedEntity or not DoesEntityExist(targetPedEntity) then
        cb({ success = false, message = "Character is missing or deleted!" })
        return
    end

    local currentPed = PlayerPedId()
    if currentPed == targetPedEntity then 
        cb({ success = false, message = "Already playing this character" })
        return 
    end

    SetNuiFocus(false, false)
    SendNUIMessage({ type = "close" })

    -- B. UPDATE TRACKING (Main Char Protection)
    -- If we are the Main Character, ensure we are saved in slot 0 with the current entity ID
    -- This handles if the entity ID changed since script start.
    local isMain = false
    if savedPeds[0] and (savedPeds[0].entity == currentPed or savedPeds[0].entity == nil) then
        savedPeds[0].entity = currentPed -- Update reference
        isMain = true
    end

    -- If it's a new NPC we somehow missed (rare), save it
    if not isMain then
        local known = false
        for k,v in pairs(savedPeds) do
            if v.entity == currentPed then known = true break end
        end
        if not known then
            local newId = #savedPeds + 1
            savedPeds[newId] = { entity = currentPed, model = "Previous Char", id = newId, isMain = false }
        end
    end

    -- C. PROTECT OLD BODY (Immediate Anchor)
    -- We do this NOW, before the switch, so it never gets deleted.
    SetEntityAsMissionEntity(currentPed, true, true)
    SetEntityInvincible(currentPed, true)
    SetPedCanRagdoll(currentPed, false)
    SetBlockingOfNonTemporaryEvents(currentPed, true)
    
    -- KEEP ANIMATION: Tell game to keep doing the current task
    SetPedKeepTask(currentPed, true)

    -- D. SWITCH CAMERA
    StartPlayerSwitch(currentPed, targetPedEntity, 0, 1)
    while GetPlayerSwitchState() ~= 8 do Wait(100) end

    -- E. TRANSFER CONTROL
    ChangePlayerPed(PlayerId(), targetPedEntity, true, true)
    
    -- F. WAKE UP NEW BODY (Emote Fix)
    SetEntityAsMissionEntity(targetPedEntity, true, true)
    SetEntityInvincible(targetPedEntity, false)
    SetPedCanRagdoll(targetPedEntity, true)
    
    -- Allow player to override the "Keep Task", but DO NOT clear it immediately.
    -- This means if they were dancing, they keep dancing until you press 'W' to walk.
    SetPedKeepTask(targetPedEntity, false)
    
    -- NOTE: I removed ClearPedTasksImmediately(targetPedEntity) here.
    -- This ensures the emote continues when you enter the body.

    cb({ success = true })
end)

-- 6. DELETE LOGIC
RegisterNUICallback('delete', function(data, cb)
    local pedId = data.id
    if pedId == 0 then
         cb({ success = false, message = "Cannot delete Main Character" })
         return
    end
    if savedPeds[pedId] then
        local ent = savedPeds[pedId].entity
        if ent == PlayerPedId() then
            cb({ success = false, message = "Cannot delete yourself!" })
            return
        end
        DeleteEntity(ent)
        savedPeds[pedId] = nil 
        
        local uiList = {}
        for k, v in pairs(savedPeds) do
            if not v.isMain then table.insert(uiList, v) end
        end
        SendNUIMessage({ type = "updateList", peds = uiList })
        cb({ success = true })
    end
end)