local uiOpen = false

-- ======================================================
-- 🔐 REQUEST ADMIN STATUS ON JOIN
-- ======================================================

CreateThread(function()
    Wait(1000)
    Utils.RequestAdminStatus(function(isAdmin)
        Utils.IsAdmin = isAdmin
    end)
end)

-- ======================================================
-- 🎮 OPEN / CLOSE UI
-- ======================================================

local function openUI()
    if uiOpen then return end

    Utils.RequestAdminStatus(function(isAdmin)
        if Config.AdminOnly and not isAdmin then
            Utils.Notify('~r~You do not have permission to use NPC Spawner')
            return
        end

        uiOpen = true
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)

        SendNUIMessage({ action = 'open' })

        if Config.UI.blurBackground then
            TriggerScreenblurFadeIn(300)
        end
    end)
end


local function closeUI()
    if not uiOpen then return end

    uiOpen = false

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = 'close'
    })

    if Config.UI.blurBackground then
        TriggerScreenblurFadeOut(300)
    end
end

-- ======================================================
-- ⌨️ KEYBIND
-- ======================================================

RegisterCommand('+npcSpawnerOpen', function()
    openUI()
end, false)

RegisterCommand('-npcSpawnerOpen', function() end, false)

RegisterKeyMapping('+npcSpawnerOpen', 'Open NPC Spawner', 'keyboard', Config.OpenKey)

-- ======================================================
-- 💬 OPTIONAL CHAT COMMAND
-- ======================================================

if Config.AllowCommand then
    RegisterCommand(Config.Command, function()
        openUI()
    end, false)
end

-- ======================================================
-- 🖱️ NUI CALLBACKS
-- ======================================================

RegisterNUICallback('close', function(_, cb)
    closeUI()
    cb('ok')
end)

RegisterNUICallback('spawnNpc', function(data, cb)
    NPCSpawner.Spawn(data)

    -- Apply behavior & combat
    for _, ped in ipairs(NPCSpawner.Peds) do
        NPCBehavior.Apply(ped, data.behavior)

        if data.combat and data.combat.enabled then
            NPCCombat.GiveWeapon(
                ped,
                data.combat.weapon,
                {},
                data.combat.infiniteAmmo
            )

            NPCCombat.Apply(ped, data.combat)
        end
    end

    cb('ok')
end)


-- ======================================================
-- 🔒 CONTROL LOCK (NO INPUT LEAK)
-- ======================================================

CreateThread(function()
    while true do
        if uiOpen and Config.UI.lockControlsWhenOpen then
            DisableControlAction(0, 1, true)    -- LookLeftRight
            DisableControlAction(0, 2, true)    -- LookUpDown
            DisableControlAction(0, 24, true)   -- Attack
            DisableControlAction(0, 25, true)   -- Aim
            DisableControlAction(0, 30, true)   -- MoveLeftRight
            DisableControlAction(0, 31, true)   -- MoveUpDown
            DisableControlAction(0, 75, true)   -- Exit vehicle
            DisableControlAction(0, 200, true)  -- ESC pause
            Wait(0)
        else
            Wait(300)
        end
    end
end)

-- ======================================================
-- 🧹 CLEANUP ON RESOURCE STOP
-- ======================================================

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    closeUI()
end)
