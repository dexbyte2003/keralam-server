
Customize = {}

Customize.Framework = "QBCore" -- ESX or QBCore or OLDQBCore

Customize.GetVehFuel = function(Veh)
    return GetVehicleFuelLevel(Veh)-- exports["LegacyFuel"]:GetFuel(Veh)
end

Customize.SetVehFuel = function(Veh, Fuel)
    return GetVehicleFuelLevel(Veh) -- exports['LegacyFuel']:SetFuel(Veh, data.Table.fuel)
end

Customize.Carkeys = function(Plate)
    TriggerEvent('vehiclekeys:client:SetOwner', Plate) --   qb-core
end

Customize.PriceType = 'cash' -- cash - bank
Customize.GaragesPrice = 100
Customize.ImpoundGaragesPrice = 600

Customize.Garages = {
    {
        Blips = {
            Position = vector3(213.56, -809.54, 31.01),
            Label = "Car",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 18,
        },
        Npc = {  Hash = "s_m_y_barman_01", Pos = vector3(213.56, -809.54, 31.01), Heading = 340.67 },
        Type = 'car', --car, air, sea
        UIName = 'Pilbox Garage',
        Camera = {
            vehSpawn = vector4(236.95, -783.71, 30.63, 179.64),
            location = { posX = 233.37, posY = -789.9, posZ = 30.6, rotX = 0.0, rotY = 0.0, rotZ = -32.0, fov = 50.0 },
        },
        VehPutPos = vector3(213.936, -792.53, 30.3523),
        VehSpawnPos = vector4(209.64, -791.39, 30.5, 248.63),
    },
    {
        Blips = {
            Position = vector3(463.75, -982.43, 43.69),
            Label = "Air",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 18,
        },
        Npc = {  Hash = "s_m_y_barman_01", Pos = vector3(463.75, -982.43, 43.69), Heading = 89.74 },
        Type = 'air', --car, air, sea
        UIName = 'Test Pilbox Hill',
        Camera = {
            vehSpawn = vector4(-75.3122, -818.490, 326.17, 201.5),
            location = { posX = -58.0, posY = -828.5, posZ = 335.17, rotX = -25.0, rotY = 0.0, rotZ = 60.2, fov = 40.0 },
        },
        VehPutPos = vector3(449.76, -981.27, 43.69),
        VehSpawnPos = vector4(449.85, -981.23, 43.69, 93.23),
    },
    {
        Blips = {
            Position = vector3(-869.43, -1491.55, 5.17),
            Label = "Sea",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 18,
        },
        Npc = {  Hash = "s_m_y_barman_01", Pos = vector3(-869.43, -1491.55, 5.17), Heading = 112.87 },
        Type = 'sea', --car, air, sea
        UIName = 'Test Pilbox Hill',
        Camera = {
            vehSpawn = vector4(-855.5, -1484.77, -0.47, 111.13),
            location = { posX = -868.0, posY = -1495.0, posZ = 6.31, rotX = -25.0, rotY = 0.0, rotZ = -40.0, fov = 40.0 },
        },
        VehPutPos = vector3(-858.29, -1475.77, 0.5),
        VehSpawnPos = vector4(-799.54, -1502.98, -0.08, 114.38),
    },
    {
        Blips = {
            Position = vector3(274.29, -334.15, 44.92),
            Label = "Motel Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(274.29, -334.15, 44.92), Heading = 0.0 },
        Type = 'car',
        UIName = 'Motel Parking',
        VehPutPos = vector3(274.29, -334.15, 44.92),
        VehSpawnPos = vector4(265.96, -332.3, 44.51, 250.68),
    },
    {
        Blips = {
            Position = vector3(883.96, -4.71, 78.76),
            Label = "Casino Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(883.96, -4.71, 78.76), Heading = 0.0 },
        Type = 'car',
        UIName = 'Casino Parking',
        VehPutPos = vector3(883.96, -4.71, 78.76),
        VehSpawnPos = vector4(895.39, -4.75, 78.35, 146.85),
    },
    {
        Blips = {
            Position = vector3(-330.01, -780.33, 33.96),
            Label = "San Andreas Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-330.01, -780.33, 33.96), Heading = 0.0 },
        Type = 'car',
        UIName = 'San Andreas Parking',
        VehPutPos = vector3(-330.01, -780.33, 33.96),
        VehSpawnPos = vector4(-341.57, -767.45, 33.56, 92.61),
    },
    {
        Blips = {
            Position = vector3(-1160.86, -741.41, 19.63),
            Label = "Spanish Ave Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-1160.86, -741.41, 19.63), Heading = 0.0 },
        Type = 'car',
        UIName = 'Spanish Ave Parking',
        VehPutPos = vector3(-1160.86, -741.41, 19.63),
        VehSpawnPos = vector4(-1145.2, -745.42, 19.26, 108.22),
    },
    {
        Blips = {
            Position = vector3(69.84, 12.6, 68.96),
            Label = "Caears 24 Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(69.84, 12.6, 68.96), Heading = 0.0 },
        Type = 'car',
        UIName = 'Caears 24 Parking',
        VehPutPos = vector3(69.84, 12.6, 68.96),
        VehSpawnPos = vector4(60.8, 17.54, 68.82, 339.7),
    },
    {
        Blips = {
            Position = vector3(-453.7, -786.78, 30.56),
            Label = "Caears 24 Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-453.7, -786.78, 30.56), Heading = 0.0 },
        Type = 'car',
        UIName = 'Caears 24 Parking',
        VehPutPos = vector3(-453.7, -786.78, 30.56),
        VehSpawnPos = vector4(-472.39, -787.71, 30.14, 180.52),
    },
    {
        Blips = {
            Position = vector3(364.37, 297.83, 103.49),
            Label = "Laguna Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(364.37, 297.83, 103.49), Heading = 0.0 },
        Type = 'car',
        UIName = 'Laguna Parking',
        VehPutPos = vector3(364.37, 297.83, 103.49),
        VehSpawnPos = vector4(375.09, 294.66, 102.86, 164.04),
    },
    {
        Blips = {
            Position = vector3(-773.12, -2033.04, 8.88),
            Label = "Airport Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-773.12, -2033.04, 8.88), Heading = 0.0 },
        Type = 'car',
        UIName = 'Airport Parking',
        VehPutPos = vector3(-773.12, -2033.04, 8.88),
        VehSpawnPos = vector4(-779.77, -2040.18, 8.47, 315.34),
    },
    {
        Blips = {
            Position = vector3(-1185.32, -1500.64, 4.38),
            Label = "Beach Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-1185.32, -1500.64, 4.38), Heading = 0.0 },
        Type = 'car',
        UIName = 'Beach Parking',
        VehPutPos = vector3(-1185.32, -1500.64, 4.38),
        VehSpawnPos = vector4(-1188.14, -1487.95, 3.97, 124.06),
    },
    {
        Blips = {
            Position = vector3(1137.77, 2663.54, 37.9),
            Label = "The Motor Hotel Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(1137.77, 2663.54, 37.9), Heading = 0.0 },
        Type = 'car',
        UIName = 'The Motor Hotel Parking',
        VehPutPos = vector3(1137.77, 2663.54, 37.9),
        VehSpawnPos = vector4(1127.7, 2647.84, 37.58, 1.41),
    },
    {
        Blips = {
            Position = vector3(883.99, 3649.67, 32.87),
            Label = "Liqour Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(883.99, 3649.67, 32.87), Heading = 0.0 },
        Type = 'car',
        UIName = 'Liqour Parking',
        VehPutPos = vector3(883.99, 3649.67, 32.87),
        VehSpawnPos = vector4(898.38, 3649.41, 32.36, 90.75),
    },
    {
        Blips = {
            Position = vector3(1737.03, 3718.88, 34.05),
            Label = "Shore Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(1737.03, 3718.88, 34.05), Heading = 0.0 },
        Type = 'car',
        UIName = 'Shore Parking',
        VehPutPos = vector3(1737.03, 3718.88, 34.05),
        VehSpawnPos = vector4(1725.4, 3716.78, 34.15, 20.54),
    },
    {
        Blips = {
            Position = vector3(76.88, 6397.3, 31.23),
            Label = "Bell Farms Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(76.88, 6397.3, 31.23), Heading = 0.0 },
        Type = 'car',
        UIName = 'Bell Farms Parking',
        VehPutPos = vector3(76.88, 6397.3, 31.23),
        VehSpawnPos = vector4(62.15, 6403.41, 30.81, 211.38),
    },
    {
        Blips = {
            Position = vector3(165.75, -3227.2, 5.89),
            Label = "Dumbo Private Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(165.75, -3227.2, 5.89), Heading = 0.0 },
        Type = 'car',
        UIName = 'Dumbo Private Parking',
        VehPutPos = vector3(165.75, -3227.2, 5.89),
        VehSpawnPos = vector4(168.34, -3236.1, 5.43, 272.05),
    },
    {
        Blips = {
            Position = vector3(213.2, -796.05, 30.86),
            Label = "Pillbox Garage Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(213.2, -796.05, 30.86), Heading = 0.0 },
        Type = 'car',
        UIName = 'Pillbox Garage Parking',
        VehPutPos = vector3(213.2, -796.05, 30.86),
        VehSpawnPos = vector4(222.02, -804.19, 30.26, 248.19),
    },
    {
        Blips = {
            Position = vector3(2552.68, 4671.8, 33.95),
            Label = "Grapeseed Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(2552.68, 4671.8, 33.95), Heading = 0.0 },
        Type = 'car',
        UIName = 'Grapeseed Parking',
        VehPutPos = vector3(2552.68, 4671.8, 33.95),
        VehSpawnPos = vector4(2550.17, 4681.96, 33.81, 17.05),
    },
    {
        Blips = {
            Position = vector3(401.76, -1632.57, 29.29),
            Label = "Depot Lot",
            Sprite = 68,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(401.76, -1632.57, 29.29), Heading = 0.0 },
        Type = 'car',
        UIName = 'Depot Lot',
        VehPutPos = vector3(401.76, -1632.57, 29.29),
        VehSpawnPos = vector4(396.55, -1643.93, 28.88, 321.91),
    },
    {
        Blips = {
            Position = vector3(-979.06, -2995.48, 13.95),
            Label = "Airport Hangar",
            Sprite = 360,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-979.06, -2995.48, 13.95), Heading = 0.0 },
        Type = 'air',
        UIName = 'Airport Hangar',
        VehPutPos = vector3(-979.06, -2995.48, 13.95),
        VehSpawnPos = vector4(-998.37, -2985.01, 13.95, 61.09),
    },
    {
        Blips = {
            Position = vector3(-722.15, -1472.79, 5.0),
            Label = "Higgins Helitours",
            Sprite = 360,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-722.15, -1472.79, 5.0), Heading = 0.0 },
        Type = 'air',
        UIName = 'Higgins Helitours',
        VehPutPos = vector3(-722.15, -1472.79, 5.0),
        VehSpawnPos = vector4(-745.22, -1468.72, 5.39, 319.84),
    },
    {
        Blips = {
            Position = vector3(1737.89, 3288.13, 41.14),
            Label = "Sandy Shores Hangar",
            Sprite = 360,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(1737.89, 3288.13, 41.14), Heading = 0.0 },
        Type = 'air',
        UIName = 'Sandy Shores Hangar',
        VehPutPos = vector3(1737.89, 3288.13, 41.14),
        VehSpawnPos = vector4(1742.83, 3266.83, 41.24, 102.64),
    },
    {
        Blips = {
            Position = vector3(-1828.25, 2975.44, 32.81),
            Label = "Fort Zancudo Hangar",
            Sprite = 360,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-1828.25, 2975.44, 32.81), Heading = 0.0 },
        Type = 'air',
        UIName = 'Fort Zancudo Hangar',
        VehPutPos = vector3(-1828.25, 2975.44, 32.81),
        VehSpawnPos = vector4(-1828.25, 2975.44, 32.81, 57.24),
    },
    {
        Blips = {
            Position = vector3(-1270.01, -3377.53, 14.33),
            Label = "Air Depot",
            Sprite = 359,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-1270.01, -3377.53, 14.33), Heading = 0.0 },
        Type = 'air',
        UIName = 'Air Depot',
        VehPutPos = vector3(-1270.01, -3377.53, 14.33),
        VehSpawnPos = vector4(-1270.01, -3377.53, 14.33, 329.25),
    },
    {
        Blips = {
            Position = vector3(-785.95, -1497.84, -0.09),
            Label = "LSYMC Boathouse",
            Sprite = 356,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-785.95, -1497.84, -0.09), Heading = 0.0 },
        Type = 'sea',
        UIName = 'LSYMC Boathouse',
        VehPutPos = vector3(-785.95, -1497.84, -0.09),
        VehSpawnPos = vector4(-796.64, -1502.6, -0.09, 111.49),
    },
    {
        Blips = {
            Position = vector3(-278.21, 6638.13, 7.55),
            Label = "Paleto Boathouse",
            Sprite = 356,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-278.21, 6638.13, 7.55), Heading = 0.0 },
        Type = 'sea',
        UIName = 'Paleto Boathouse',
        VehPutPos = vector3(-278.21, 6638.13, 7.55),
        VehSpawnPos = vector4(-289.2, 6637.96, 1.01, 45.5),
    },
    {
        Blips = {
            Position = vector3(1298.56, 4212.42, 33.25),
            Label = "Millars Boathouse",
            Sprite = 356,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(1298.56, 4212.42, 33.25), Heading = 0.0 },
        Type = 'sea',
        UIName = 'Millars Boathouse',
        VehPutPos = vector3(1298.56, 4212.42, 33.25),
        VehSpawnPos = vector4(1297.82, 4209.61, 30.12, 253.5),
    },
    {
        Blips = {
            Position = vector3(-742.95, -1407.58, 5.5),
            Label = "LSYMC Depot",
            Sprite = 356,
            Display = 4,
            Scale = 0.5,
            Color = 3,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-742.95, -1407.58, 5.5), Heading = 0.0 },
        Type = 'sea',
        UIName = 'LSYMC Depot',
        VehPutPos = vector3(-742.95, -1407.58, 5.5),
        VehSpawnPos = vector4(-729.77, -1355.49, 1.19, 142.5),
    },
    {
        Blips = {
            Position = vector3(2334.42, 3118.62, 48.2),
            Label = "Big Rig Depot",
            Sprite = 68,
            Display = 4,
            Scale = 0.5,
            Color = 2,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(2334.42, 3118.62, 48.2), Heading = 0.0 },
        Type = 'rig',
        UIName = 'Big Rig Depot',
        VehPutPos = vector3(2334.42, 3118.62, 48.2),
        VehSpawnPos = vector4(2324.57, 3117.79, 48.21, 4.05),
    },
    {
        Blips = {
            Position = vector3(161.23, -3188.73, 5.97),
            Label = "Dumbo Big Rig Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 2,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(161.23, -3188.73, 5.97), Heading = 0.0 },
        Type = 'rig',
        UIName = 'Dumbo Big Rig Parking',
        VehPutPos = vector3(161.23, -3188.73, 5.97),
        VehSpawnPos = vector4(167.0, -3203.89, 5.94, 271.27),
    },
    {
        Blips = {
            Position = vector3(137.67, 6632.99, 31.67),
            Label = "Pop's Big Rig Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 2,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(137.67, 6632.99, 31.67), Heading = 0.0 },
        Type = 'rig',
        UIName = 'Pop\'s Big Rig Parking',
        VehPutPos = vector3(137.67, 6632.99, 31.67),
        VehSpawnPos = vector4(127.69, 6605.84, 31.93, 223.67),
    },
    {
        Blips = {
            Position = vector3(-2529.37, 2342.67, 33.06),
            Label = "Ron's Big Rig Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 2,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-2529.37, 2342.67, 33.06), Heading = 0.0 },
        Type = 'rig',
        UIName = 'Ron\'s Big Rig Parking',
        VehPutPos = vector3(-2529.37, 2342.67, 33.06),
        VehSpawnPos = vector4(-2521.61, 2326.45, 33.13, 88.7),
    },
    {
        Blips = {
            Position = vector3(2561.67, 476.68, 108.49),
            Label = "Ron's Big Rig Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 2,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(2561.67, 476.68, 108.49), Heading = 0.0 },
        Type = 'rig',
        UIName = 'Ron\'s Big Rig Parking',
        VehPutPos = vector3(2561.67, 476.68, 108.49),
        VehSpawnPos = vector4(2561.67, 476.68, 108.49, 177.86),
    },
    {
        Blips = {
            Position = vector3(-41.24, -2550.63, 6.01),
            Label = "Ron's Big Rig Parking",
            Sprite = 357,
            Display = 4,
            Scale = 0.5,
            Color = 2,
        },
        Npc = { Hash = "s_m_y_barman_01", Pos = vector3(-41.24, -2550.63, 6.01), Heading = 0.0 },
        Type = 'rig',
        UIName = 'Ron\'s Big Rig Parking',
        VehPutPos = vector3(-41.24, -2550.63, 6.01),
        VehSpawnPos = vector4(-39.39, -2527.81, 6.08, 326.18),
    }
}

function GetFramework() 
    local Get = nil
    if Customize.Framework == "ESX" then
        while Get == nil do
            TriggerEvent('esx:getSharedObject', function(Set) Get = Set end)
            Citizen.Wait(0)
        end
    end
    if Customize.Framework == "NewESX" then
        Get = exports['es_extended']:getSharedObject()
    end
    if Customize.Framework == "QBCore" then
        Get = exports["qb-core"]:GetCoreObject()
    end
    if Customize.Framework == "OLDQBCore" then
        while Get == nil do
            TriggerEvent('QBCore:GetObject', function(Set) Get = Set end)
            Citizen.Wait(200)
        end
    end
    return Get
end
