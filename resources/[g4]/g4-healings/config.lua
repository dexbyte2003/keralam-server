Config = {}

-- Items Configuration
-- Item Name: The key must match the item name in your inventory (ox_inventory/data/items.lua)
-- type: 'health' to increase HP, 'armor' to increase Kevlar
-- amount: How much to increase (0-100)
-- duration: Time in milliseconds for the progress bar
-- label: Text shown on the progress bar
-- anim: Animation settings (dict and clip are required)
-- prop: (Optional) Object for the player to hold during the animation

Config.Items = {
    ['health-portion'] = {
        type = 'health',
        amount = 100,
        duration = 3000,
        label = 'Angels are healing you...',
        anim = {
            dict = 'mp_suicide',
            clip = 'pill',
            flag = 49,
        }
    },
    -- ['medkit'] = {
    --     type = 'health',
    --     amount = 50,
    --     duration = 5000,
    --     label = 'Using Medical Kit...',
    --     anim = {
    --         dict = 'anim@amb@business@weed@weed_inspecting_lo_med_hi@',
    --         clip = 'weed_stand_checkitem_lookat_hi_producer',
    --         flag = 49,
    --     },
    --     prop = {
    --         model = `prop_ld_health_pack`,
    --         bone = 18905,
    --         pos = vec3(0.1, 0.02, 0.05),
    --         rot = vec3(10.0, 0.0, 0.0),
    --     }
    -- },
    ['armour-portion'] = {
        type = 'armor',
        amount = 100,
        duration = 4000,
        label = 'God is protecting you...',
        anim = {
            dict = 'clothingshirt',
            clip = 'try_shirt_positive_d',
            flag = 49,
        }
    },
}
