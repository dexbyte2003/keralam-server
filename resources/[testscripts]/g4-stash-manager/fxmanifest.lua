fx_version 'cerulean'
game 'gta5'

name 'g4-stash-manager'
author 'G4 Developments'
version '1.0.0'
description 'Dynamically create and manage stashes and shops via ox_lib and ox_inventory'

dependency 'ox_lib'
dependency 'ox_inventory'

client_scripts {
    '@ox_lib/init.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@ox_lib/init.lua',
    'server/main.lua'
}

dependency '/assetpacks'