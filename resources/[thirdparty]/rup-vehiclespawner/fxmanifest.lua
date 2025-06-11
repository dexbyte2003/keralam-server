fx_version 'cerulean'
lua54 'yes'
game 'gta5'

author 'Ruptz'
description 'Vehicle Spawner'
version '1.0.2'

ui_page 'web/index.html'

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
	'server/*.lua',
}

files {
	'web/*',
	'web/**/*.png'
}
