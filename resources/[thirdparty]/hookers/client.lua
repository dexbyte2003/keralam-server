local isHookerThreadActive = false
local isUsingHooker = false
local disableVehicleControls = false
local hookerModels = Config.HookerPedModels
local hasPayed = nil

local PLAYER_ID <const> = PlayerId()

-- Vehicle controls that will get disabled while interacting with a hooker in your car
local VEHICLE_CONTROLS <const> = {
    [59] = true, -- INPUT_VEH_MOVE_LR
    [60] = true, -- INPUT_VEH_MOVE_UD
    [61] = true, -- INPUT_VEH_MOVE_UP_ONLY
    [62] = true, -- INPUT_VEH_MOVE_DOWN_ONLY
    [63] = true, -- INPUT_VEH_MOVE_LEFT_ONLY
    [64] = true, -- INPUT_VEH_MOVE_RIGHT_ONLY
    [71] = true, -- INPUT_VEH_ACCELERATE
    [72] = true, -- INPUT_VEH_BRAKE
    [73] = true, -- INPUT_VEH_DUCK
    [86] = true  -- INPUT_VEH_HORN
}


-- Utils --
local function DisplayHelpText(msg)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(0, false, true, 50)
end

local function DisplayHint(msg, time)
	CreateThread(function()
        local endTime = GetGameTimer() + time
        while GetGameTimer() < endTime do
            DisplayHelpText(msg)
            Wait(0)
        end
        ClearHelp(true)
    end)
end

local function DisplayNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

-- This only works with mp peds, everyone else will be male regardless. IsPedMale() returns true regardless, so this is better.
local function GetPedGender(ped)
    if GetEntityModel(ped) == `mp_f_freemode_01` then
        return "female"
    else
        return "male"
    end
end


-- Checkers/Getters Functions --
local function GetNearbyPeds()
	local handle, ped = FindFirstPed()
	local success = false
	local peds = {}
	repeat
		peds[#peds+1] = ped
		success, ped = FindNextPed(handle)
	until not success
	EndFindPed(handle)
	return peds
end

local function IsPedEligibleHooker(ped)
    local pedModel = GetEntityModel(ped)
    if not hookerModels[pedModel] then
        return false
    end

    if IsPedInjured(ped) then
        return false
    end

    if IsPedWalking(ped) or IsPedRunning(ped) or IsPedSprinting(ped) then
        return false
    end

    if IsPedInAnyVehicle(ped, true) then
        return false
    end

    if IsPedAPlayer(ped) then
        return false
    end

    return true
end

local function CanVehiclePickUpHookers(vehicle)
    if not IsVehicleDriveable(vehicle, false) then
        return false
    end

    local class = GetVehicleClass(vehicle)
    if Config.BlackListedVehicleClasses[class] then
        return false
    end

    local model = GetEntityModel(vehicle)
    if Config.BlackListedVehicles[model] then
        return false
    end

    return true
end


-- Audio --
local function PlayHookerSpeach(hooker, speechName, speechParam)
    if not IsAnySpeechPlaying(hooker) then
        PlayPedAmbientSpeechNative(hooker, speechName, speechParam)
    end
end


-- AI Behavior --
local function MakeHookerCalm(hooker)
    local _void, groupHash = AddRelationshipGroup("ProstituteInPlay")
    SetRelationshipBetweenGroups(1, groupHash, `PLAYER`)
    SetPedRelationshipGroupHash(hooker, groupHash)

    SetPedConfigFlag(hooker, 26, true)            -- CPED_CONFIG_FLAG_DontDragMeOutCar
    SetPedConfigFlag(hooker, 115, true)           -- CPED_CONFIG_FLAG_FallOutOfVehicleWhenKilled
    SetPedConfigFlag(hooker, 229, true)           -- CPED_CONFIG_FLAG_DisablePanicInVehicle 
    SetBlockingOfNonTemporaryEvents(hooker, true) -- Makes the hooker not react to everything around them
end

local function ResetHookerCalm(hooker)
    SetPedConfigFlag(hooker, 26, false)            -- CPED_CONFIG_FLAG_DontDragMeOutCar
    SetPedConfigFlag(hooker, 115, false)           -- CPED_CONFIG_FLAG_FallOutOfVehicleWhenKilled
    SetPedConfigFlag(hooker, 229, false)           -- CPED_CONFIG_FLAG_DisablePanicInVehicle 
    SetBlockingOfNonTemporaryEvents(hooker, false) -- Makes the hooker not react to everything around them
end


-- Other Functions --
local function IsInSecludedArea(hooker, vehicle)
    local vehicleSpeed = GetEntitySpeed(vehicle)
    if vehicleSpeed >= Config.MaxVehicleSpeed then
        return false
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    local hasLineOfSight = false
    for _index, ped in pairs(GetNearbyPeds()) do
        if ped ~= playerPed and ped ~= hooker and GetPedType(ped) ~= 28 then
            if HasEntityClearLosToEntity(ped, vehicle, 17) then
                if #(coords - GetEntityCoords(ped)) < 75.0 then
                    hasLineOfSight = true
                end
            end
        end
    end

    if hasLineOfSight then
        return false
    end

    return true
end

local function PlaySexSceneAnim(hooker, playerPed, hookerAnim, playerAnim, flag, wait)
    local animTime = GetAnimDuration("mini@prostitutes@sexnorm_veh", hookerAnim) * 1000
    TaskPlayAnim(hooker, "mini@prostitutes@sexnorm_veh", hookerAnim, 2.0, 2.0, animTime, flag, 0.0, false, false, false)
    TaskPlayAnim(playerPed, "mini@prostitutes@sexnorm_veh", playerAnim, 2.0, 2.0, animTime, flag, 0.0, false, false, false)

    if wait then
        Wait(animTime)
    end
end

local function PlaySexScene(scene, hooker, vehicle)
    local playerPed = PlayerPedId()
    local playerGender = GetPedGender(playerPed)
    local timer = 8
    local speach = {}
    local animation = {
        hooker = {},
        player = {}
    }

    speach.param = "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR"

    if scene == "SERVICE_BLOWJOB" then
        if playerGender == "male" then
            speach.name = "SEX_ORAL"
        else
            speach.name = "SEX_ORAL_FEM"
        end

        timer = 4

        -- Hooker anims
        animation.hooker.enter1 = "proposition_to_BJ_p1_prostitute"
        animation.hooker.enter2 = "proposition_to_BJ_p2_prostitute"
        animation.hooker.loop = "BJ_loop_prostitute"
        animation.hooker.exit1 = "BJ_to_proposition_p1_prostitute"
        animation.hooker.exit2 = "BJ_to_proposition_p2_prostitute"

        -- Player anims
        animation.player.enter1 = "proposition_to_BJ_p1_male"
        animation.player.enter2 = "proposition_to_BJ_p2_male"
        animation.player.loop = "BJ_loop_male"
        animation.player.exit1 = "BJ_to_proposition_p1_male"
        animation.player.exit2 = "BJ_to_proposition_p2_male"
    else
        if playerGender == "male" then
            speach.name = "SEX_GENERIC"
        else
            speach.name = "SEX_GENERIC_FEM"
        end

        -- Hooker anims
        animation.hooker.enter1 = "proposition_to_sex_p1_prostitute"
        animation.hooker.enter2 = "proposition_to_sex_p2_prostitute"
        animation.hooker.loop = "sex_loop_prostitute"
        animation.hooker.exit1 = "sex_to_proposition_p1_prostitute"
        animation.hooker.exit2 = "sex_to_proposition_p2_prostitute"

        -- Player anims
        animation.player.enter1 = "proposition_to_sex_p1_male"
        animation.player.enter2 = "proposition_to_sex_p2_male"
        animation.player.loop = "sex_loop_male"
        animation.player.exit1 = "sex_to_proposition_p1_male"
        animation.player.exit2 = "sex_to_proposition_p2_male"
    end

    PlaySexSceneAnim(hooker, playerPed, animation.hooker.enter1, animation.player.enter1, 2, true)
    PlaySexSceneAnim(hooker, playerPed, animation.hooker.enter2, animation.player.enter2, 2, true)

    local loopWait = GetAnimDuration("mini@prostitutes@sexnorm_veh", animation.hooker.loop) * 1000 / 2
    PlaySexSceneAnim(hooker, playerPed, animation.hooker.loop, animation.player.loop, 1, false)

    if scene == "SERVICE_SEX" then
        CreateThread(function()
            Wait(250)

            while timer > 0 do
                ApplyForceToEntity(vehicle, 1, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, 0, true, true, true, true, false)
                Wait(780)
            end
        end)
    end

    while timer > 0 do
        if not DoesEntityExist(hooker) then return end

        PlayHookerSpeach(hooker, speach.name, speach.param)
        Wait(loopWait)

        timer = timer - 1
    end

    PlaySexSceneAnim(hooker, playerPed, animation.hooker.exit1, animation.player.exit1, 2, true)
    PlaySexSceneAnim(hooker, playerPed, animation.hooker.exit2, animation.player.exit2, 2, true)
    PlaySexSceneAnim(hooker, playerPed, "proposition_loop_prostitute", "proposition_loop_male", 1, false)
end

local function DisableVehicleControlsLoop()
    while disableVehicleControls do
        for control, state in pairs(VEHICLE_CONTROLS) do
            DisableControlAction(0, control, state)
        end

        Wait(0)
    end
end

local function DisableVehicleControls(state)
    disableVehicleControls = state
    if disableVehicleControls then
        CreateThread(DisableVehicleControlsLoop)
    end
end


-- Threads/Loops --
local function HookerLoop(hooker)
    CreateThread(function()
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        while true do
            vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if vehicle ~= 0 and #(GetEntityCoords(vehicle) - GetEntityCoords(hooker)) < Config.MaxDistance and GetEntitySpeed(vehicle) <= Config.MaxVehicleSpeed then
                DisplayHelpText(Config.Localization.InviteHooker)
                if IsPlayerPressingHorn(PLAYER_ID) then
                    break
                end
            else
                HookerInteractionCanceled()
                return
            end

            Wait(0)
        end

        isUsingHooker = true

        -- Add relationships and set config flags so the hooker stays calm
        MakeHookerCalm(hooker)

        -- Task the hooker to enter the vehicle
        TaskEnterVehicle(hooker, vehicle, 10000, 0, 1.0, 1, 0)

        -- Wait until the hooker is in the vehicle
        while true do
            local taskState = GetScriptTaskStatus(hooker, "SCRIPT_TASK_ENTER_VEHICLE")
            if taskState == 7 then
                if GetPedInVehicleSeat(vehicle, 0) == hooker then
                    break
                else
                    HookerInteractionCanceled()
                    return
                end
            elseif taskState == 2 then
                HookerInteractionCanceled()
                return
            end

            if not DoesEntityExist(hooker) or IsPedInjured(hooker) or GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then
                HookerInteractionCanceled()
                return
            end

            Wait(100)
        end

        -- Hooker tells player to go to secluded area
        PlayHookerSpeach(hooker, "HOOKER_SECLUDED", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")

        -- Wait until she was finished speaking before we give hint to player
        while IsAnySpeechPlaying(hooker) do
            Wait(100)
        end

        local timeToFindArea = 120 * 1000
        local startTimer = GetGameTimer()
        local endTime = startTimer + timeToFindArea
        local isShowingHint = false
        local shouldAsyncThreadsBreak = false

        -- Wait until we are in a secluded area
        while true do
            Wait(500)

            -- If something wen wrong the cancel
            if not DoesEntityExist(hooker) then
                shouldAsyncThreadsBreak = true
                HookerInteractionCanceled()
                return
            end

            if IsPedInjured(hooker) or GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then
                shouldAsyncThreadsBreak = true
                ResetHookerCalm(hooker)
                HookerInteractionCanceled()
                return
            end

            local isAreaSecluded = IsInSecludedArea(hooker, vehicle)
            if isAreaSecluded then
                shouldAsyncThreadsBreak = true
                break
            end

            -- Check if it has gone more then 3 min since we let her in, if so cancel
            local gameTimer = GetGameTimer()
            if gameTimer > endTime then
                shouldAsyncThreadsBreak = true
                PlayHookerSpeach(hooker, "HOOKER_LEAVES_ANGRY", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
                TaskLeaveVehicle(hooker, vehicle, 0)

                while IsAnySpeechPlaying(hooker) do
                    Wait(100)
                end

                DisplayHint(Config.Localization.FindSecludedAreaFailed, 5000)
                Wait(5000)

                ResetHookerCalm(hooker)
                HookerInteractionCanceled()
                return
            end

            -- If not moving, show hint that we should move
            local vehicleSpeed = GetEntitySpeed(vehicle)
            if not isShowingHint and vehicleSpeed <= Config.MaxVehicleSpeed then
                isShowingHint = true

                Wait(500)

                -- Only check if we are in a secluded area every 500ms even when we stand still
                CreateThread(function()
                    while true do
                        vehicleSpeed = GetEntitySpeed(vehicle)
                        if vehicleSpeed > Config.MaxVehicleSpeed then
                            shouldAsyncThreadsBreak = true
                            isShowingHint = false
                            break
                        end
                        Wait(500)
                    end
                end)

                -- Display the help text
                CreateThread(function()
                    while not shouldAsyncThreadsBreak do
                        DisplayHelpText(Config.Localization.FindSecludedArea)
                        Wait(0)
                    end
                end)
            end
        end

        SetVehicleLights(vehicle, 1) -- Turn off vehicle lights
        DisableVehicleControls(true) -- Disable vehicle movement
        LoadAnimDict("mini@prostitutes@sexnorm_veh")

        Wait(500)
        PlayHookerSpeach(hooker, "HOOKER_OFFER_SERVICE", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
        PlaySexSceneAnim(hooker, PlayerPedId(), "proposition_loop_prostitute", "proposition_loop_male", 1, false)

        while IsAnySpeechPlaying(hooker) do
            Wait(100)
        end

        -- Offer services loop
        local servicesCompleted = 0
        while true do
            if not DoesEntityExist(hooker) then
                HookerInteractionCanceled()
                DisableVehicleControls(false)
                return
            end

            if IsPedInjured(hooker) or GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then
                break
            end

            if servicesCompleted >= Config.MaxServices then
                break
            end

            if servicesCompleted > 0 then
                PlayHookerSpeach(hooker, "HOOKER_OFFER_AGAIN", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
            end

            local service = OfferServices()
            if service == "SERVICE_DECLINE" then
                break
            else
                if Config.PaymentEnabled then
                    TriggerServerEvent('hookers:moneyCheck', service)
                    while hasPayed == nil do
                        Wait(100)
                    end

                    if not hasPayed then
                        hasPayed = nil
                        DisplayNotification(Config.Localization.NotEnoughMoney)
                        break
                    end

                    hasPayed = nil
                    PlaySexScene(service, hooker, vehicle)
                    servicesCompleted = servicesCompleted + 1
                else
                    PlaySexScene(service, hooker, vehicle)
                    servicesCompleted = servicesCompleted + 1
                end
            end

            Wait(100)
        end

        if servicesCompleted >= Config.MaxServices then
            PlayHookerSpeach(hooker, "HOOKER_HAD_ENOUGH", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
        elseif servicesCompleted == 0 then
            PlayHookerSpeach(hooker, "HOOKER_LEAVES_ANGRY", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
        else
            PlayHookerSpeach(hooker, "HOOKER_DECLINED", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
        end

        ClearPedTasks(hooker)
        ClearPedTasks(PlayerPedId())
        RemoveAnimDict("mini@prostitutes@sexnorm_veh")

        TaskLeaveVehicle(hooker, vehicle, 0)
        DisableVehicleControls(false)

        Wait(2000)
        SetVehicleLights(vehicle, 0)

        -- Reset
        Wait(5000)
        ResetHookerCalm(hooker)
        HookerInteractionCanceled()
    end)
end

local function LookingForHookerThread()
    CreateThread(function()
        if isUsingHooker then
            return
        end

        isHookerThreadActive = true
        while true do
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if not vehicle then
                break
            end

            local vehicleSpeed = GetEntitySpeed(vehicle)
            if vehicleSpeed <= Config.MaxVehicleSpeed then
                local vehicleCoords = GetEntityCoords(vehicle)

                for _index, ped in pairs(GetNearbyPeds()) do
                    if ped == playerPed then
                        goto nextPed
                    end

                    local dist = #(GetEntityCoords(ped) - vehicleCoords)
                    if dist > Config.MaxDistance then
                        goto nextPed
                    end

                    if not IsPedEligibleHooker(ped) then
                        goto nextPed
                    end

                    if not CanVehiclePickUpHookers(vehicle) then
                        while dist < Config.MaxDistance do
                            dist = #(GetEntityCoords(ped) - GetEntityCoords(vehicle))
                            DisplayHelpText(Config.Localization.VehicleUnsuitable)
                            Wait(0)
                        end
                    end

                    if not IsVehicleSeatFree(vehicle, 0) then
                        while dist < Config.MaxDistance do
                            dist = #(GetEntityCoords(ped) - GetEntityCoords(vehicle))
                            DisplayHelpText(Config.Localization.FrontSeatOccupied)
                            Wait(0)
                        end
                    else
                        isHookerThreadActive = false
                        HookerLoop(ped)
                        return
                    end

                    ::nextPed::
                end
            end

            Wait(500)
        end
        isHookerThreadActive = false
    end)
end

function HookerInteractionCanceled()
    isUsingHooker = false
    LookingForHookerThread() -- Restart looking for hooker thread
end



-- Events --
AddEventHandler('gameEventTriggered', function(event, args)
    if event == "CEventNetworkPlayerEnteredVehicle" then
        if args[1] == PLAYER_ID then
            if isHookerThreadActive then
                return
            end

            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then
                return
            end

            LookingForHookerThread()
        end
    end
end)

RegisterNetEvent('hookser:paymentReturn')
AddEventHandler('hookser:paymentReturn', function(state)
    hasPayed = state
end)




-- Blip Management Thread
CreateThread(function()
    local hookerBlips = {}

    while true do
        local peds = GetNearbyPeds()
        local currentBlips = {}

        -- Check each ped for eligibility
        for _, ped in ipairs(peds) do
            local pedModel = GetEntityModel(ped)
            if Config.HookerPedModels[pedModel] and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then
                local pedHandle = ped

                -- Create blip if it doesn't exist
                if not hookerBlips[pedHandle] then
                    local blip = AddBlipForEntity(pedHandle)
                    SetBlipSprite(blip, 184) -- Use female icon sprite
                    SetBlipColour(blip, 8)    -- Pink color
                    SetBlipScale(blip, 0.8)
                    SetBlipCategory(blip, 3)   -- NPC category
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Hooker")
                    EndTextCommandSetBlipName(blip)
                    hookerBlips[pedHandle] = blip
                end

                currentBlips[pedHandle] = true
            end
        end

        -- Remove old blips that no longer exist
        for pedHandle, blip in pairs(hookerBlips) do
            if not currentBlips[pedHandle] or not DoesEntityExist(pedHandle) then
                RemoveBlip(blip)
                hookerBlips[pedHandle] = nil
            end
        end

        Wait(5000) -- Adjust interval for performance
    end
end)


-- Add to client.lua
RegisterCommand('locateprostitute', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Get position in front of player
    local forwardOffset = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
    local _, groundZ = GetGroundZFor_3dCoord(forwardOffset.x, forwardOffset.y, forwardOffset.z, false)
    local spawnCoords = vector3(forwardOffset.x, forwardOffset.y, groundZ)

    -- Get random hooker model from config
    local hookerModels = {}
    for model, _ in pairs(Config.HookerPedModels) do
        table.insert(hookerModels, model)
    end
    local selectedModel = hookerModels[math.random(#hookerModels)]

    -- Load model
    RequestModel(selectedModel)
    while not HasModelLoaded(selectedModel) do
        Wait(0)
    end

    -- Create hooker ped
    local hooker = CreatePed(4, selectedModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)
    SetEntityHeading(hooker, GetEntityHeading(playerPed) + 180.0)
    SetModelAsNoLongerNeeded(selectedModel)

    -- Set up hooker behavior
    MakeHookerCalm(hooker)
    TaskWanderStandard(hooker, 10.0, 10)

    -- Set waypoint
    SetNewWaypoint(spawnCoords.x, spawnCoords.y)
    
    -- Notification
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("Prostitute located - waypoint set to her position")
    EndTextCommandThefeedPostTicker(false, true)
end, false)

