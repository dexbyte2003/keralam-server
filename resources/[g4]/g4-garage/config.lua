Config = {}

-- Automatically attempts to detect framework, or you can force 'qb' or 'qbox'
Config.Framework = 'qb' -- 'qb' or 'qbox' (will auto fallback to exports if qbox detected)

Config.SpawnDistanceLimit = 15.0 -- Distance check for spawning/deleting vehicles
Config.BlipsEnabled = true

Config.DefaultSpawnState = 1 -- 1 = in garage, 0 = out on the road
Config.Debug = false -- Toggle console debug messages (true/false)
Config.ReclaimCost = 500 -- Cost to reclaim despawned vehicle back to garage

Config.Locales = {
    ['not_authorized'] = 'You are not authorized to use this garage.',
    ['vehicle_out'] = 'This vehicle is already out on the road!',
    ['no_vehicle_nearby'] = 'No vehicle nearby to park.',
    ['vehicle_parked'] = 'Vehicle successfully parked!',
    ['not_owner'] = 'You do not own this vehicle or have access to it.',
    ['invalid_plate'] = 'Invalid vehicle plate.',
    ['already_shared'] = 'This vehicle is already shared with this player.',
    ['share_success'] = 'Vehicle shared successfully!',
    ['unshare_success'] = 'Vehicle share removed.',
    ['garage_created'] = 'Garage successfully created!',
    ['garage_deleted'] = 'Garage successfully deleted!',
    ['player_not_found'] = 'Player not found.',
    ['not_enough_money'] = 'You do not have enough money to reclaim this vehicle.',
    ['reclaimed_success'] = 'Vehicle reclaimed for $%s.'
}
