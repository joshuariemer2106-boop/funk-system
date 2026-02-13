fx_version 'cerulean'
game 'gta5'

name 'funk-system'
author 'codex'
description 'Ein einfaches FiveM Funksystem mit Channel-Management und Berechtigungen'
version '1.0.0'

lua54 'yes'

shared_scripts {
  'config.lua'
}

client_scripts {
  'client/main.lua'
}

server_scripts {
  'server/main.lua'
}
