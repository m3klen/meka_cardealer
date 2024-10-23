fx_version 'cerulean'
lua54 'on' 
game 'gta5'
shared_script '@es_extended/imports.lua'
author 'Meka Store'
description 'Bilforhandler til FiveM'
dependencies {
    'es_extended',
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'locale.lua',
    'locales/*.lua',
    'config.lua',
    'server/main.lua'
}
client_scripts {
    'locale.lua',
    'locales/*.lua',
    'config.lua',
    'client/func.lua',
    'client/main.lua'
}

shared_script '@ox_lib/init.lua'

escrow_ignore {
    'config.lua',
    'locale.lua',
    'locales/*.lua'
}