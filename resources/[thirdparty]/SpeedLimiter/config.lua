Config = {}
-- Set Config.kmh to false if you want to use mph
Config.kmh = true

-- Set Config.maxSpeed to false if you want to use same speed for all vehicles
-- Set the max speed for all vehicles on Config.maxSpeed
Config.useCategories = false
Config.maxSpeed = 1000

Config.Categories = {
   -- COMPACTS
   {category = 0, maxSpeed = 500},
   -- SEDANS
   {category = 1, maxSpeed = 500},
   -- SUV'S
   {category = 2, maxSpeed = 500},
   -- COUPES
   {category = 3, maxSpeed = 500},
   -- MUSCLE
   {category = 4, maxSpeed = 1000},
   -- SPORT CLASSIC
   {category = 5, maxSpeed = 1000},
   -- SPORT
   {category = 6, maxSpeed = 1000},
   -- SUPER
   {category = 7, maxSpeed = 1000},
   -- MOTORCYCLES
   {category = 8, maxSpeed = 1000},
   -- OFFROAD
   {category = 9, maxSpeed = 1000},
   -- INDUSTRIAL
   {category = 10, maxSpeed = 1000},
   -- UTILITY
   {category = 11, maxSpeed = 1000},
   -- VANS
   {category = 12, maxSpeed = 500},
   -- BICYCLES
   {category = 13, maxSpeed = 500},
   -- BOATS
   {category = 14, maxSpeed = 500},

   --#region PLANES AND HELIS
   -- YOU MUST NOT LOCK THIS ONES OR YOU WON'T BE ABLE TO FLY THEM!!!
   {category = 15, maxSpeed = nil},
   {category = 16, maxSpeed = nil},
   --#endregion

   -- SERVICE
   {category = 17, maxSpeed = 1000},
   -- EMERGENCY
   {category = 18, maxSpeed = 1000},
   -- MILITARY
   {category = 19, maxSpeed = 1000}
}

-- DO NOT MODIFY
Config.kmhValue = 3.6
Config.mphValue = 2.23694