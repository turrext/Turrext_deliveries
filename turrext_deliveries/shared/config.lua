Config = {}
-- ESX or QB
Config.Framework = "QB"
-- OX or QB
Config.Inventory = "QB"
Config.RenderDistance = 300.0
Config.Debug = false
Config.ShowPedLoc = true
Config.InstantRespawnAfterPedDeath = true
Config.GlobalPoliceChange = 50
Config.EnableQSPhone = false
Config.RivalGangInterrogateChance = 50
Config.RivalGangInterrogateTimer = 10 * 1000
Config.Zones = {
    [1] = {
        Id = 1,
        Blip = {
            Pos   = {x = -1480.96, y = -344.8, z = 44.16},
            Size  = {x = 1.0, y = 1.0, z = 1.0},
            Color = 39,
            Type  = 51,
            Blipname = "Blip Xe",
            Rotate = false,
            Showblip = true,
            Drawradius = true,
        },
        Radius = 120.0,
        Peds = {
			SpawnCoords = {
				[1] = {
					Pos = {x = -1483.44, y = -339.36, z = 44.16},
					Heading = 128.96,
					Model = "mp_m_freemode_01",
					Actions = {
						ApproachPlayer = false,
						FreezePed = true,
						Wandering = false,
						Invincible = true,
						IgnoreEvents = true,
						ExpireTimer = 60, -- When will the ped be removed after it's task has completed or its been alive too long.
						PoliceNotifyChance = 10, -- % Chance Ped will Notify Police / 100
					}
				},

			}
        }
    },
    --[[[2] = {
        Id = 2,
        ZoneTerritory = "",
        Blip = {
            Pos   = {x = 325.64, y = 209.4, z = 119.64},
            Size  = {x = 1.0, y = 1.0, z = 1.0},
            Color = 39,
            Type  = 51,
            Blipname = "Blip Be",
            Rotate = false,
            Showblip = true,
            Drawradius = true,
        },
        Radius = 180.0,
        Peds = {
			SpawnCoords = {
				[1] = {
					Pos = {x = 299.56, y = 259.0, z = 105.68},
					Heading = 63.96,
					Model = "mp_m_freemode_01",
					Actions = {
						ApproachPlayer = true,
						FreezePed = false,
						Wandering = true,
						Invincible = false,
						IgnoreEvents = true,
						ExpireTimer = 60, -- When will the ped be removed after it's task has completed or its been alive too long.
						PoliceNotifyChance = 10, -- % Chance Ped will Notify Police / 100
					}
				},
				[2] = {
					Pos = {x = 419.12, y = 222.24, z = 103.16},
					Heading = 343.44,
					Model = "mp_m_freemode_01",
					Actions = {
						ApproachPlayer = true,
						FreezePed = false,
						Wandering = false,
						Invincible = false,
						IgnoreEvents = false,
						ExpireTimer = 60, -- When will the ped be removed after it's task has completed or its been alive too long.
						PoliceNotifyChance = 10, -- % Chance Ped will Notify Police / 100
					}
				},

			}
        }
    }]]--
}
Config.GlobalShipmentDropTimer = 20 * 1000 -- Shipment will drop in 30 minutes
Config.GlobalShipmentExpireTimer = 60 * 1000 -- 1 Hours for shipment to expire.
Config.ShowShipmentBlipAnyone = true
Config.ShipmentCoords = {
    --[1] = {x = 1102.16, y = 1714.56, z = 131.76},
    [1] = {x = -1575.72, y = -3012.2, z = 13.96}
}
Config.Account = "bank"
Config.Items = {
    [1] = {
        name = "lockpick",
        price = 500,
        maxAmount = 50,
        label = "Repair Kit",
        type = "item"
    },
    [2] = {
        name = "lockpick",
        price = 50,
        maxAmount = 50,
        label = "Pistol Ammo",
        type = "item"
    },
    [3] = {
        name = "weapon_pistol",
        price = 1500,
        maxAmount = 2,
        label = "Pistol Weapon",
        type = "weapon"
    }
}