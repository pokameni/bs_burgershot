Config                            = {}
Config.DrawDistance               = 100.0

Config.EnablePlayerManagement     = true
Config.EnableSocietyOwnedVehicles = false
Config.EnableVaultManagement      = true
Config.EnableHelicopters          = false
Config.EnableMoneyWash            = false
Config.MaxInService               = -1
Config.Locale                     = 'en'

Config.MissCraft                  = 0 -- %


Config.AuthorizedVehicles = {
    { name = 'taco2',  label = 'Burger Truck'},
}

Config.Blips = {
    
    Blip = { -- 
      Pos     = { x = -1196.45, y = -892.64, z = 13.50 },
      Sprite  = 536,
      Display = 4,
      Scale   = 0.9,
      Colour  = 49,
    },

}

Config.Zones = {

    Cloakrooms = { -- -1192.2960, -898.0771, 13.9953, 41.3717
        Pos   = { x = -1192.2960, y = -898.0771, z = 13.053 },
        Size  = { x = 1.5, y = 1.5, z = 1.0 },
        Color = { r = 255, g = 0, b = 0 },
        Type  = 27,
    },

    Vaults = { -- -1202.6753, -895.4263, 13.9953, 117.7572
        Pos   = { x = -1202.6753, y = -895.4263, z = 13.09 },
        Size  = { x = 1.3, y = 1.3, z = 1.0 },
        Color = { r = 30, g = 144, b = 255 },
        Type  = 27,
    },

    Fridge = { -- -1204.3993, -893.7333, 13.9953, 123.8335
        Pos   = { x = -1204.3993, y = -893.7333, z = 13.0953 },
        Size  = { x = 1.6, y = 1.6, z = 1.0 },
        Color = { r = 255, g = 0, b = 0 },
        Type  = 27,
    },
	
	Cook = {
        Pos   = { x = -1198.55, y = -901.77, z = 13.0 },
        Size  = { x = 1.6, y = 1.6, z = 1.0 },
        Color = { r = 0, g = 200, b = 220 },
        Type  = 27,
    },
	
	Vehicles = {
        Pos          = { x = -1172.37, y = -899.39, z = 12.9 },
        SpawnPoint   = { x = -1170.55, y = -892.59, z = 13.94 },
        Size         = { x = 1.8, y = 1.8, z = 1.0 },
        Color        = { r = 255, g = 255, b = 0 },
        Type         = 27,
        Heading      = 30.00,
    },

    VehicleDeleters = {
        Pos   = { x = -1164.48, y = -891.76, z = 13.15 },
        Size  = { x = 3.0, y = 3.0, z = 0.2 },
        Color = { r = 255, g = 255, b = 0 },
        Type  = 27,
    },
    
    BossActions = {
        Pos   = { x = -1193.9242, y = -899.2497, z = 13.09 },
        Size  = { x = 1.5, y = 1.5, z = 1.0 },
        Color = { r = 0, g = 100, b = 0 },
        Type  = 1,
    },
}


-- CHECK SKINCHANGER CLIENT MAIN.LUA for matching elements

Config.Uniforms = {
  barman_outfit = {
    male = {
        ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
        ['torso_1'] = 281,   ['torso_2'] = 1,
		['bproof_1'] = 0,  ['bproof_2'] = 0,
        ['decals_1'] = 0,   ['decals_2'] = 0,
        ['arms'] = 4,
        ['pants_1'] = 22,   ['pants_2'] = 0,
        ['shoes_1'] = 7,   ['shoes_2'] = 12,
		['helmet_1'] = -1,  ['helmet_2'] = 0,
		['chain_1'] = 0,    ['chain_2'] = 0,
		['ears_1'] = 2,     ['ears_2'] = 0,
		['mask_1'] = 0,  ['mask_2'] = 0,
        ['chain_1'] = 0,  ['chain_2'] = 0
    },
    female = {
        ['tshirt_1'] =2,   ['tshirt_2'] = 0,
        ['torso_1'] = 294,    ['torso_2'] = 2,
        ['decals_1'] = 0,   ['decals_2'] = 0,
        ['arms'] = 1,
        ['pants_1'] = 22,   ['pants_2'] = 0,
		['bproof_1'] = 0,  ['bproof_2'] = 0,
        ['shoes_1'] = 7,    ['shoes_2'] = 12,
		['helmet_1'] = -1,  ['helmet_2'] = 0,
		['chain_1'] = 0,    ['chain_2'] = 0,
		['ears_1'] = 2,     ['ears_2'] = 0,
		['mask_1'] = 0,  ['mask_2'] = 0,
        ['chain_1'] = 0,    ['chain_2'] = 0
    }
  }
}
