fx_version 'cerulean'
game 'gta5'

author 'Antigravity'
description 'Premium QBCore and QBox dynamically managed Garage System'
version '1.0.0'

shared_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/admin.lua'
}

server_scripts {
    'server/main.lua',
    'server/admin.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
