--[[
BY RX Scripts © rxscripts.xyz
--]]

fx_version 'cerulean'
games { 'gta5' }

author 'Rejox | rxscripts.xyz'
description 'Report System'
version '1.2.0'

shared_script {
  'config/config.lua',
  'init.lua',
  'locales/*.lua',
}

client_scripts {
  'client/utils.lua',
  'client/functions.lua',
  'client/opensource.lua',
  'client/staffpanel.lua',
  'client/reportpanel.lua',
  'client/main.lua',
}
server_scripts {
  'config/sv_config.lua',
  'server/utils.lua',
  'server/functions.lua',
  'server/opensource.lua',
  'server/main.lua',
}

ui_page 'web/dist/index.html'

files {
  'web/dist/index.html',
  'web/dist/assets/*.*',
}

lua54 'yes'

escrow_ignore {
  'locales/*.lua',
  'server/opensource.lua',
  'client/opensource.lua',
  'config/*.lua',
  'fxmanifest.lua'
}
dependency '/assetpacks'