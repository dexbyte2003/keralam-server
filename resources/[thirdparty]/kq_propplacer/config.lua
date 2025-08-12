Config = {}

-- Enabling this will add additional prints and display of the resource within the pot
Config.debug = false

Config.sql = {
    driver = 'oxmysql', -- oxmysql or ghmattimysql or mysql
    -- If you're using an older version of oxmysql set this to false
    newOxMysql = true,
}
