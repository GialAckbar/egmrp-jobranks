-- Wie lange soll der Abstand sein bis XPs vergeben werden? (Standard: 30)
Jobranks.Config.TimeBetweenTick = 30

-- Wie viel XP pro Tick? (Standard: 50)
Jobranks.Config.XPGainPerTick = 50

Jobranks.Config.Jobs["Jobrank1"] = {
	Ranks = {
		[1] = {
			Name = "Stufe 1",
			Exp = 100, -- Wie viel XP um nächste Stufe zu erreichen
			Health = 100,
			Armor = 50,
			Weapons = { "weapon_357" }
		},
		[2] = {
			Name = "Stufe 2",
			Exp = 200,
			Health = 200,
			Armor = 60,
			Weapons = { "weapon_pistol" }
		},
		[3] = {
			Name = "Stufe 3",
			Exp = 200,
			Health = 300,
			Armor = 60,
			Weapons = { "weapon_bugbait" }
		},
		[4] = {
			Name = "Stufe 4",
			Exp = 200,
			Health = 400,
			Armor = 60,
			Weapons = { "weapon_crossbow" }
		},
		[5] = {
			Name = "Stufe 5",
			Exp = 2000,
			Health = 500,
			Armor = 60,
			Weapons = { "weapon_crowbar", "weapon_rpg" }
		},
		[6] = {
			Name = "Stufe 6",
			Exp = 200,
			Health = 600,
			Armor = 60,
			Weapons = { "weapon_frag", "weapon_ar2", "weapon_rpg" }
		},
	},
}

Jobranks.Config.Jobs["Jobrank2"] = {
	Ranks = {
		[1] = {
			Name = "Stufe 1",
			Exp = 100,
			Health = 100,
			Armor = 50,
			Weapons = {}
		}
	},
}