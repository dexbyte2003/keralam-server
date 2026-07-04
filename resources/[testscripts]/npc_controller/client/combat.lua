NPCCombat = {}

-- ======================================================
-- 🔫 APPLY COMBAT SETTINGS
-- ======================================================

function NPCCombat.Apply(ped, combat)
    if not DoesEntityExist(ped) or not combat.enabled then return end

    -- Accuracy & combat tuning
    SetPedAccuracy(ped, combat.accuracy or 35)
    SetPedCombatAbility(ped, 2)
    SetPedCombatMovement(ped, 2)
    SetPedCombatRange(ped, 2)

    -- Aggression
    SetPedCombatAttributes(ped, 46, true) -- Always fight
    SetPedCombatAttributes(ped, 5, combat.useCover)

    -- Fire rate
    SetPedShootRate(ped, math.floor(1000 * (combat.fireRate or 1.0)))

    -- Headshot control
    if combat.headshotChance and combat.headshotChance < 100 then
        SetPedSuffersCriticalHits(ped, false)
    end
end

-- ======================================================
-- 🔫 GIVE WEAPON
-- ======================================================

function NPCCombat.GiveWeapon(ped, weapon, attachments, infiniteAmmo)
    if not DoesEntityExist(ped) then return end
    if not Config.AllowWeapons then return end

    if Utils.IsWeaponBlacklisted(weapon) then
        Utils.Notify('~r~Weapon is blacklisted')
        return
    end

    local weaponHash = type(weapon) == 'string' and joaat(weapon) or weapon

    GiveWeaponToPed(ped, weaponHash, 9999, false, true)

    if infiniteAmmo then
        SetPedInfiniteAmmo(ped, true, weaponHash)
    end

    -- Attachments
    if attachments and Config.AllowWeaponAttachments then
        for _, comp in ipairs(attachments) do
            GiveWeaponComponentToPed(ped, weaponHash, joaat(comp))
        end
    end
end

-- ======================================================
-- 🛡️ DAMAGE & GOD MODE
-- ======================================================

function NPCCombat.ApplyStates(ped, states)
    if not DoesEntityExist(ped) then return end

    -- Invincibility
    SetEntityInvincible(ped, states.invincible)

    -- Ragdoll
    SetPedCanRagdoll(ped, states.ragdoll)

    -- Collision
    SetEntityCollision(ped, states.collision, states.collision)

    -- Freeze
    FreezeEntityPosition(ped, states.frozen)
end

-- ======================================================
-- 💥 FORCE COMBAT TARGET
-- ======================================================

function NPCCombat.AttackTarget(ped, target)
    if not DoesEntityExist(ped) or not DoesEntityExist(target) then return end

    ClearPedTasksImmediately(ped)
    TaskCombatPed(ped, target, 0, 16)
end

-- ======================================================
-- 🧹 REMOVE WEAPONS
-- ======================================================

function NPCCombat.RemoveWeapons(ped)
    if DoesEntityExist(ped) then
        RemoveAllPedWeapons(ped, true)
    end
end
