--[[
BY RX Scripts © rxscripts.xyz
--]]

Config = {}

Config.Locale = 'en'
Config.ToggleNotifications = true -- Allow toggling of report notifications like new opened, chat of claimed tickets (default = disabled)
Config.MaxReports = 5 -- Max reports a player can have open at once
Config.HideAdminName = false -- Hide admin name for players in chat

Config.Commands = {
    reportPanel = 'report', -- /report | Report a player, bug or other, and see your reports
    staffPanel = 'reports', -- /reports | Open the reports staff panel
    toggleNotifications = 'reportnotify', -- /reportnotify | Toggle incoming report notifications
}

Config.Categories = {
    'Report Player',
    'Report Bug',
    'Report Other'
}

--[[
    YOU CAN USE ACE PERMISSIONS TO ALLOW CERTAIN PLAYERS/GROUPS TO ACCESS THE REPORTS PANEL
    EXAMPLE:
        add_ace group.admin reports allow
        add_ace identifier.fivem:1432744 reports allow #Rejox

    OR YOU CAN USE THE STAFF GROUPS BELOW
--]]
Config.StaffGroups = {
    'superadmin',
    'admin',
    'god',
    'mod',
}

--[[
    ONLY CHANGE THIS PART IF YOU HAVE RENAMED SCRIPTS SUCH AS FRAMEWORK, TARGET, INVENTORY ETC
    RENAME THE SCRIPT NAME TO THE NEW NAME
--]]
---@type table Only change these if you have changed the name of a resource
Resources = {
    FM = { name = 'fmLib', export = 'new' },
}
IgnoreScriptFoundLogs = false
