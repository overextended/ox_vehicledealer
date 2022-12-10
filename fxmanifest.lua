--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'ox_vehicledealer'
version      '0.6.1'
description  'Vehicle Dealer'
license      'GPL-3.0-or-later'
author       'overextended'
repository   'https://github.com/overextended/ox_vehicledealer'

--[[ Manifest ]]--
dependencies {
    '/server:5104',
    '/onesync',
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared.lua',
}

client_scripts {
    '@ox_core/imports/client.lua',
    'client/main.lua',
    'client/import.lua',
    'client/showroom.lua',
    'client/vehicleYard.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@ox_core/imports/server.lua',
    'server/main.lua',
    'server/import.lua',
    'server/showroom.lua',
    'server/vehicleYard.lua',
}

ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/**/*',
    'locales/*.json',
    'data/**',
}

ox_property_data '/data/devin_weston_aircraft.lua'
ox_property_data '/data/mosley_auto_service.lua'
ox_property_data '/data/premium_deluxe_motorsport.lua'
ox_property_data '/data/puerto_del_sol_pegasus.lua'
ox_property_data '/data/terminal.lua'
