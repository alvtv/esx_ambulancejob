Config                            = {}

Config.DrawDistance               = 100.0

Config.Marker                     = { type = 27, x = 1.5, y = 1.5, z = 0.5, r = 255, g = 0, b = 0, a = 100, rotate = true }

Config.AntiCombatLog              = false -- enable anti-combat logging?

Config.Locale                     = 'en'

local second = 1000
local minute = 30 * second

Config.EarlyRespawnTimer          = 1 * minute  -- Time til respawn is available
Config.BleedoutTimer              = 5 * minute -- Time til the player bleeds out --10

Config.EnablePlayerManagement     = true

Config.RemoveWeaponsAfterRPDeath  = true
Config.RemoveCashAfterRPDeath     = false
Config.RemoveItemsAfterRPDeath    = false

-- Let the player pay for respawning early, only if he can afford it.
Config.EarlyRespawnFine           = true
Config.EarlyRespawnFineAmount     = 2500

Config.RespawnPoint = { coords = vector3(-11.48, -1829.61, 25.39), heading = 139.79 }

Config.RespawnPoint2 = { coords = vector3(218.37, -2592.77, 6.18), heading = 91.76 }

Config.Hospitals = {

	CentralLosSantos = {

		Blip = {
			coords = vector3(1833.04, 3683.22, 305.23),
			sprite = 0,
			scale  = 0,
			color  = 0
		},

		AmbulanceActions = {
			vector3(311.99, -597.01, 43.28)
		},

		Pharmacies = {
			vector3(1838.98, 3682.29, 33.28)
		},

		Vehicles = {
			{
				Spawner = vector3(297.35, -605.33, 43.33),
				InsideShop = vector3(994.5925, -3002.594, -40.646),
				Marker = { type = 36, x = 1.0, y = 1.0, z = 1.0, r = 255, g = 0, b = 0, a = 100, rotate = true },
				SpawnPoints = {
					{ coords = vector3(293.98,-613.18,43.39), heading = 76.21, radius = 4.0 }
				}
			}
		},

		Helicopters = {
			{
				Spawner = vector3(1859.11, 3657.18, 33.96),
				InsideShop = vector3(1866.13, 3649.89, 35.66),
				Marker = { type = 34, x = 1.0, y = 1.0, z = 1.0, r = 255, g = 0, b = 0, a = 100, rotate = true },
				SpawnPoints = {
					{ coords = vector3(1866.13, 3649.89, 35.66), heading = 210.7, radius = 4.0 }
				}
			}
		},

		FastTravels = {

			{
				From = vector3(1207.7, -1474.67, 34.86),
				To = { coords = vector3(1201.42, -1484.83, 0.21), heading = 0.0 },
				Marker = { type = 0, x = 1.0, y = 1.0, z = 0.5, r = 255, g = 0, b = 0, a = 100, rotate = false }
			},
			
		},

		FastTravelsPrompt = {
			{
				From = vector3(237.4, -1373.8, 26.0),
				To = { coords = vector3(251.9, -1363.3, 38.5), heading = 0.0 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false },
				Prompt = _U('fast_travel')
			},

			{
				From = vector3(256.5, -1357.7, 36.0),
				To = { coords = vector3(235.4, -1372.8, 26.3), heading = 0.0 },
				Marker = { type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false },
				Prompt = _U('fast_travel')
			}
		}

	}
}

Config.AuthorizedVehicles = {

	ambulance = {
		{ model = 'ambulance', label = 'Ambulance', price = 1},
		{ model = 'dodgeEMS', label = 'EMS DODGE', price = 1},
	},

	doctor = {
		{ model = 'ambulance', label = 'Ambulance', price = 1},
		{ model = 'dodgeEMS', label = 'EMS DODGE', price = 1},
	},

	chief_doctor = {
		{ model = 'ambulance', label = 'Ambulance', price = 1},
		{ model = 'dodgeEMS', label = 'EMS DODGE', price = 1},
	},

	boss = {
		{ model = 'ambulance', label = 'Ambulance', price = 1},
		{ model = 'dodgeEMS', label = 'EMS DODGE', price = 1},
	}

}

Config.AuthorizedHelicopters = {

	ambulance = {},

	doctor = {
		{ model = 'polmav', label = 'Maverick', price = 1 }
	},

	chief_doctor = {
		{ model = 'polmav', label = 'Maverick', price = 1 }
	},

	boss = {
		{ model = 'polmav', label = 'Maverick', price = 1},
		{ model = 'seasparrow', label = 'Sea Sparrow', price = 1 }
	}

}
