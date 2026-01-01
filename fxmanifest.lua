fx_version 'cerulean'
game 'gta5'

description 'V6 City Hall'
repository 'https://github.com/Qbox-project/qbx_cityhall'
version '1.0.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'config/shared.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
    'client/fraud.lua',
}

server_scripts {
    'server/main.lua',
    'server/fraud.lua',
}

files {
    'config/client.lua',
    'config/shared.lua',
    'locales/*.json',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
