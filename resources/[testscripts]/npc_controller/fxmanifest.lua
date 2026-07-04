fx_version 'cerulean'
game 'gta5'

author 'Adithyan'
description 'Advanced Standalone NPC Spawner with Modern NUI'
version '1.0.0'

-- Enable Lua 5.4
lua54 'yes'

-- UI
ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/app.js',
    'nui/assets/**/*'
}

-- Client scripts
client_scripts {
    'config.lua',
    'client/utils.lua',
    'client/spawn.lua',
    'client/behavior.lua',
    'client/combat.lua',
    'client/main.lua'
}

-- Server scripts
server_scripts {
    'server/main.lua'
}

-- Resource settings
dependency '/gameBuild:2802'
