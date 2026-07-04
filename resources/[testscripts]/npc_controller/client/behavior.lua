NPCBehavior = {}

-- ======================================================
-- 🧠 APPLY BEHAVIOR
-- ======================================================

function NPCBehavior.Apply(ped, behavior)
    if not DoesEntityExist(ped) then return end

    ClearPedTasksImmediately(ped)

    if behavior.type == 'passive' then
        NPCBehavior.Passive(ped)

    elseif behavior.type == 'civilian' then
        NPCBehavior.Civilian(ped, behavior)

    elseif behavior.type == 'guard' then
        NPCBehavior.Guard(ped)

    elseif behavior.type == 'companion' then
        NPCBehavior.FollowPlayer(ped)

    elseif behavior.type == 'aggressive' then
        NPCBehavior.Aggressive(ped, behavior)
    end
end

-- ======================================================
-- 😐 PASSIVE
-- ======================================================

function NPCBehavior.Passive(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStandStill(ped, -1)
end

-- ======================================================
-- 🚶 CIVILIAN (WANDER)
-- ======================================================

function NPCBehavior.Civilian(ped, behavior)
    SetBlockingOfNonTemporaryEvents(ped, false)
    TaskWanderStandard(ped, behavior.wanderRadius or 10.0, 10)
end

-- ======================================================
-- 🛡️ GUARD
-- ======================================================

function NPCBehavior.Guard(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskGuardCurrentPosition(ped, 5.0, 5.0, true)
end

-- ======================================================
-- 🧍 FOLLOW PLAYER (COMPANION)
-- ======================================================

function NPCBehavior.FollowPlayer(ped)
    local playerPed = PlayerPedId()

    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedAsGroupMember(ped, GetPedGroupIndex(playerPed))
    SetPedNeverLeavesGroup(ped, true)

    TaskFollowToOffsetOfEntity(
        ped,
        playerPed,
        0.0, 0.0, 0.0,
        2.0,
        -1,
        2.0,
        true
    )
end

-- ======================================================
-- 🔫 AGGRESSIVE
-- ======================================================

function NPCBehavior.Aggressive(ped, behavior)
    local playerPed = PlayerPedId()

    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Relationship
    SetPedRelationshipGroupHash(ped, `HATES_PLAYER`)
    SetRelationshipBetweenGroups(5, `HATES_PLAYER`, `PLAYER`)
    SetRelationshipBetweenGroups(5, `PLAYER`, `HATES_PLAYER`)

    -- Combat attributes
    SetPedCombatAbility(ped, 2)
    SetPedCombatMovement(ped, 2)
    SetPedCombatRange(ped, 2)
    SetPedAlertness(ped, math.floor((behavior.alertness or 0.5) * 3))

    TaskCombatPed(ped, playerPed, 0, 16)
end

-- ======================================================
-- 🎭 SCENARIO TASKS
-- ======================================================

function NPCBehavior.PlayScenario(ped, scenario)
    if not DoesEntityExist(ped) then return end

    ClearPedTasksImmediately(ped)
    TaskStartScenarioInPlace(ped, scenario, 0, true)
end

-- ======================================================
-- 🧹 STOP ALL TASKS
-- ======================================================

function NPCBehavior.Clear(ped)
    if DoesEntityExist(ped) then
        ClearPedTasksImmediately(ped)
    end
end
