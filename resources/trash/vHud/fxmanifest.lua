fx_version "cerulean"
lua54 'yes'
game 'gta5'

author 'vipex [Discord: vipex.v]'
description 'Remake of the original v-hud.'

ui_page 'web/build/index.html'

shared_scripts {
	"config.lua",
	"shared/utils.lua",
}

client_scripts {
	"client/core.lua",
	"client/utils.lua",
	"client/nui_callbacks.lua",
	"client/bridge/**/*",
	"client/events.lua",
	"client/commands.lua",
}

server_scripts {
	-- "@vrp/lib/utils.lua", -- Enable if you are using vRP
	"server/core.lua",
	"server/versionChecker.lua"
}

files {
	'web/build/index.html',
	'web/build/**/*',
}
