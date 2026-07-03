Config = {}

-- UI & Command Configurations
Config.VoterCommand = 'predictions'      -- Command to open the prediction voter menu
Config.AdminCommand = 'predictionadmin' -- Command to open the admin prediction panel

-- Bet Options
Config.MinBet = 10                       -- Minimum amount a player can bet on a prediction
Config.MaxBet = 1000000000                 -- Maximum amount a player can bet on a prediction

-- Currency Type
Config.Currency = 'cash'                 -- 'cash' or 'bank' (cash is default)

-- Save Interval (Performance)
-- To support 500+ players, we keep prediction state in memory.
-- The script will auto-save to predictions.json on resource stop or every X milliseconds if changes are made.
Config.SaveInterval = 30000              -- Save interval in milliseconds (30 seconds)
Config.MaxHistoryItems = 30              -- Maximum number of predictions in history to persist in the JSON file to prevent bloat

-- Admin Permissions Setup
Config.AdminGroups = {
    ['admin'] = true,
    ['god'] = true,
    ['superadmin'] = true
}

-- You can manually add identifiers here (e.g., license:xxxx or discord:xxxx) that will always have admin access
Config.AdminIdentifiers = {
    -- "license:1234567890abcdef...",
}

-- Notification Type
Config.NotificationType = 'auto'         -- 'auto' (detects qb/qbox), 'qb', 'qbox', 'chat'
