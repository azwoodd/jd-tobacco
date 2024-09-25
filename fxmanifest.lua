name "JD-Tobacco-Job"
author "JDSTUDIOS"
version "v1.1"
description "Tobacco Job Script By JD"
fx_version "cerulean"
game "gta5"

client_scripts {
	'client.lua',
}

server_scripts {
    'server.lua'
}

shared_scripts {
    'config.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
}

lua54 'yes'

escrow_ignore {
	'*.lua*',
	'client/*.lua*',
	'server/*.lua*',
}
dependency '/assetpacks'