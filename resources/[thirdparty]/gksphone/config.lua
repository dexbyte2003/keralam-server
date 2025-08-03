Config = {}
Config.CoreName = "QBCore"
Config.Core = "QBCore:GetObject"
Config.CoreNotify = "QBCore:Notify"
Config.OpenPhone = 'm'   --## Phone open key ## https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
Config.Locale       = 'en'
Config.Phones       = {"phone", "sphone", "iphone"}
Config.Fahrenheit   = false



Config.BillingCommissions = { -- This is a percentage (0.10) == 10% ( Must be active to receive commission - If the player is not in the game, she/he cannot receive a commission.)
    mechanic = 0.10
}



-- Discord WebHook - start --
Config.Carseller = '-'
Config.JobNotif = '-'
Config.TwitterWeb = '-' -- # 'https://discord.com/api/webhooks/1216018804589723689/TOLrFEcBZnUyCFB8AxA81HbvIIBUZmr6YSkNtO56VhdJtNRPTyKX6RmiQ2t13osOJscj'
Config.YellowWeb = '-' -- # 'https://discord.com/api/webhooks/1216084085760327871/r6EtOcoOLZdsaGL5T8p104Xo1AXZQKXD2f7bKikRDM64MnRNSF1pRniFSYbhyhGlg45d'
Config.InstagramWeb = '-' -- # 'https://discord.com/api/webhooks/1216085501056913550/CpEG1Erq6gukTmvTWb8jx7Tmhtnhx1fXa623oPFUsLcdoa5LZHHUeK90bhj-0QclQnVA'
Config.Crypto = '-'
Config.BankTrasnfer = '-'
Config.BankLimit = 5000 -- # Minimum money transfer for discord webhook

-- Discord WebHook - end --



-- Phone Settings - Start --

Config.UseMumbleVoIP    = false -- Use Frazzle's Mumble-VoIP Resource (Recomended!) https://github.com/FrazzIe/mumble-voip
Config.PMAVoice         = true
Config.UseTokoVoIP      = false
Config.SaltyChat        = false

Config.CallPhone        = true  -- If the player is not in the game or there is no item on it, it will give a warning.
Config.BlockNumber      = true   -- Number blocking

-- Phone Settings - Finish --

Config.ValePrice        = 1500    -- Vale Price
Config.TaxiPrice        = 100     -- Taxi Price ( 100$/KM )


