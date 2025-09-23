local dict = "core" -- change to your YPT dictionary name
local effect = "bullet_tracer" -- change to your effect name inside YPT

-- Preload particle dictionary
CreateThread(function()
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Wait(10)
    end
end)

-- When shooting, attach the tracer effect
CreateThread(function()
    while true do
        Wait(0)
        if IsPedShooting(PlayerPedId()) then
            local weapon = GetSelectedPedWeapon(PlayerPedId())
            local muzzleBone = GetPedBoneIndex(PlayerPedId(), 0x6F06) -- muzzle flash bone
            UseParticleFxAssetNextCall(dict)
            StartParticleFxNonLoopedOnEntityBone(
                effect, PlayerPedId(), 
                0.0, 0.0, 0.0, 
                0.0, 0.0, 0.0, 
                muzzleBone, 
                1.0, false, false, false
            )
        end
    end
end)
