fx_version 'cerulean'
game 'gta5'

author 'Xander1998, ice-mineman, Venado'
description 'A dashcam camera view for FiveM police vehicles'
version '1.0.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/vue.min.js',
    'nui/script.js',
    'nui/style.css',
    'nui/images/seal.png'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}