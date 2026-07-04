NPCSpawner = {}
NPCSpawner.Peds = {}

-- ======================================================
-- 🧍 PED COUNT HELPERS
-- ======================================================

function NPCSpawner.GetPedCount()
    return #NPCSpawner.Peds
end

function NPCSpawner.CanSpawn(count)
    return (NPCSpawner.GetPedCount() + count) <= Config.MaxNPCsGlobal
end

-- ======================================================
-- 🗺️ POSITION CALCULATIONS
-- ======================================================

local function getSpawnCoords(options)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    if options.useRaycast then
        local hit, hitCoords = Utils.RaycastFromCamera(100.0)
        if hit then
            coords = hitCoords
        end
    end

    if options.randomRadius and options.randomRadius > 0 then
        local angle = math.random() * math.pi * 2
        local radius = math.random() * options.randomRadius
        coords = coords + vector3(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
            0.0
        )
    end

    if options.useGroundSnap then
        coords = Utils.GetGroundZ(coords)
    end

    if options.heading == 'random' then
        heading = math.random(0, 360)
    elseif type(options.heading) == 'number' then
        heading = options.heading
    end

    return coords, heading
end

-- ======================================================
-- 👥 FORMATION LOGIC
-- ======================================================

local function getFormationOffset(index, formation, spacing)
    spacing = spacing or 1.5

    if formation == 'line' then
        return vector3((index - 1) * spacing, 0.0, 0.0)

    elseif formation == 'circle' then
        local angle = (index / 8) * math.pi * 2
        return vector3(
            math.cos(angle) * spacing * 2,
            math.sin(angle) * spacing * 2,
            0.0
        )

    elseif formation == 'grid' then
        local row = math.floor((index - 1) / 4)
        local col = (index - 1) % 4
        return vector3(col * spacing, row * spacing, 0.0)
    end

    return vector3(0.0, 0.0, 0.0)
end

-- ======================================================
-- 🧍 SPAWN NPC
-- ======================================================

function NPCSpawner.Spawn(data)
    local count = data.count or 1

    if count > Config.MaxNPCsPerSpawn then
        Utils.Notify('~r~Spawn limit exceeded')
        return
    end

    if not NPCSpawner.CanSpawn(count) then
        Utils.Notify('~r~Global NPC limit reached')
        return
    end

    if Utils.IsPedBlacklisted(data.model) then
        Utils.Notify('~r~This ped model is blacklisted')
        return
    end

    local modelHash = Utils.LoadModel(data.model)
    if not modelHash then
        Utils.Notify('~r~Failed to load ped model')
        return
    end

    for i = 1, count do
        local baseCoords, heading = getSpawnCoords(data.spawn)
        local offset = getFormationOffset(i, data.formation, data.spacing)
        local spawnCoords = baseCoords + offset

        local ped = CreatePed(
            4,
            modelHash,
            spawnCoords.x,
            spawnCoords.y,
            spawnCoords.z,
            heading,
            true,
            true
        )

        if DoesEntityExist(ped) then
            SetEntityAsMissionEntity(ped, true, true)

            -- Default states
            SetEntityInvincible(ped, data.states.invincible)
            SetPedCanRagdoll(ped, data.states.ragdoll)
            SetEntityCollision(ped, data.states.collision, data.states.collision)
            FreezeEntityPosition(ped, data.states.frozen)

            if data.states.invisible then
                SetEntityVisible(ped, false, false)
            end

            -- Basic relationship
            SetPedRelationshipGroupHash(ped, `CIVMALE`)
            SetPedFleeAttributes(ped, 0, false)
            SetPedDropsWeaponsWhenDead(ped, false)

            table.insert(NPCSpawner.Peds, ped)
        end
    end

    Utils.UnloadModel(modelHash)
end

-- ======================================================
-- 🧹 CLEANUP
-- ======================================================

function NPCSpawner.DeleteAll()
    for _, ped in ipairs(NPCSpawner.Peds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    NPCSpawner.Peds = {}
end

-- Auto cleanup far NPCs
CreateThread(function()
    while true do
        Wait(5000)
        local playerCoords = GetEntityCoords(PlayerPedId())

        for i = #NPCSpawner.Peds, 1, -1 do
            local ped = NPCSpawner.Peds[i]
            if not DoesEntityExist(ped) then
                table.remove(NPCSpawner.Peds, i)
            else
                local dist = Utils.Distance(playerCoords, GetEntityCoords(ped))
                if dist > Config.MaxDistanceCleanup then
                    DeleteEntity(ped)
                    table.remove(NPCSpawner.Peds, i)
                end
            end
        end
    end
end)
