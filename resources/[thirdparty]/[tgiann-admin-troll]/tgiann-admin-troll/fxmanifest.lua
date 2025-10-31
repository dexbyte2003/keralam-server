name 'fivem-tgiann-admin-troll'
author 'TGIANN'
version '1.3.2'
repository 'https://github.com/tgiann/fivem-tgiann-admin-troll.git'
fx_version 'cerulean'
game 'gta5'
ui_page 'dist/web/index.html'
node_version '22'

files {
	'locales/*.json',
	'dist/web/assets/index.css',
	'dist/web/assets/index.js',
	'dist/web/index.html',
	'dist/web/vite.svg',
	'static/config.json',
	'locales/en.json',
}

dependencies {
	'/server:13068',
	'/onesync',
	'tgiann-admin-troll-assets',
}

client_scripts {
	'dist/client.js',
}

server_scripts {
	'dist/server.js',
}
