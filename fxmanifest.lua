fx_version 'cerulean'
game 'gta5'

description 'Vehicle Target con configurazione generica per job'
version '1.0.0'
author 'ndo.ga - https://discord.gg/HQQYQGbyn3'

shared_script '@es_extended/imports.lua'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'config.lua',
    'server.lua'
}

dependencies {
    'ox_target',
    'ox_lib'
}
