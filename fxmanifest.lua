fx_version 'bodacious'
game 'gta5'

client_script {
    'client/cl_*.lua',
    'config.lua'
}

files{
    'html/*'
}

ui_page('html/index.html')


server_script 'server.lua'


client_script "@vista-coffeeroasters/acloader.lua"