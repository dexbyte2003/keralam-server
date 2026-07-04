Utils = {}

-- ======================================================
-- 🔐 ADMIN PERMISSION CHECK (SERVER → CLIENT)
-- ======================================================

Utils.IsAdmin = nil

RegisterNetEvent('npcspawner:client:setAdmin', function(state)
    Utils.IsAdmin = state
end)

function Utils.RequestAdminStatus(cb)
    Utils.IsAdmin = nil
    TriggerServerEvent('npcspawner:server:checkAdmin')

    CreateThread(function()
        local timeout = GetGameTimer() + 3000
        while Utils.IsAdmin == nil and GetGameTimer() < timeout do
            Wait(50)
        end

        if cb then
            cb(Utils.IsAdmin == true)
        end
    end)
end

-- ======================================================
-- 📦 MODEL LOADING
-- ======================================================

function Utils.LoadModel(model)
    local hash = model
    if type(model) == 'string' then
        hash = joaat(model)
    end

    if not IsModelInCdimage(hash) then
        return false
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 5000

    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(10)
    end

    return hash
end

function Utils.UnloadModel(model)
    local hash = type(model) == 'string' and joaat(model) or model
    if HasModelLoaded(hash) then
        SetModelAsNoLongerNeeded(hash)
    end
end

-- ======================================================
-- 🚫 BLACKLIST CHECKS
-- ======================================================

function Utils.IsPedBlacklisted(model)
    local hash = type(model) == 'string' and joaat(model) or model
    for _, ped in pairs(Config.BlacklistedPeds) do
        if ped == hash then
            return true
        end
    end
    return false
end

function Utils.IsWeaponBlacklisted(weapon)
    local hash = type(weapon) == 'string' and joaat(weapon) or weapon
    for _, w in pairs(Config.BlacklistedWeapons) do
        if w == hash then
            return true
        end
    end
    return false
end

-- ======================================================
-- 🧭 RAYCAST (CROSSHAIR HIT LOCATION)
-- ======================================================

function Utils.RaycastFromCamera(distance)
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()

    local direction = Utils.RotationToDirection(camRot)
    local destination = camPos + direction * distance

    local rayHandle = StartShapeTestRay(
        camPos.x, camPos.y, camPos.z,
        destination.x, destination.y, destination.z,
        -1,
        PlayerPedId(),
        0
    )

    local _, hit, endCoords = GetShapeTestResult(rayHandle)
    return hit, endCoords
end

function Utils.RotationToDirection(rotation)
    local radX = math.rad(rotation.x)
    local radZ = math.rad(rotation.z)

    return vector3(
        -math.sin(radZ) * math.cos(radX),
        math.cos(radZ) * math.cos(radX),
        math.sin(radX)
    )
end

-- ======================================================
-- 🗺️ GROUND SNAP
-- ======================================================

function Utils.GetGroundZ(coords)
    local found, groundZ = GetGroundZFor_3dCoord(
        coords.x, coords.y, coords.z + 100.0, false
    )

    if found then
        return vector3(coords.x, coords.y, groundZ)
    end

    return coords
end

-- ======================================================
-- 🖥️ NOTIFICATIONS (STANDALONE)
-- ======================================================

function Utils.Notify(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(false, false)
end

-- ======================================================
-- 📐 MATH HELPERS
-- ======================================================

function Utils.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Utils.Distance(a, b)
    return #(a - b)
end
