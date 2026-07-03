fx_version 'cerulean'
game 'gta5'

author 'G4 Media'
description 'Configurable Healing and Armor System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client.lua'
server_script 'server.lua'


dependencies {
    'ox_lib',
    'ox_inventory'
}
