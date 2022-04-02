fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Snazzy'
version '1.1.0'

shared_script 'config.lua'
server_script 'server/**.lua'
client_script 'client/client.lua'

escrow_ignore {
    'config.lua',
    'client/**.lua',
    'server/discord.lua'
  }