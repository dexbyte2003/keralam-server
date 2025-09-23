fx_version 'cerulean'
game 'gta5'

-- Manifest Metadata
author 'Dex Byte'
version '1.0.0'
description 'Custom Bullet Trace'

files {
    'stream/*.ypt'
}

data_file 'DLC_ITYP_REQUEST' 'stream/your_particle.ypt'

client_script 'client.lua'
