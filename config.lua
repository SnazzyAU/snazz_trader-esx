Config = {}
Config.Locale = 'en'

-- Variables
local second = 1
local minute = 60
local hour = 3600

Config.Trader = {

	NPCLocations = {
		{376.6, 3569.3, 33.3, 100.0} -- First 3 sets of numbers are X, Y, Z. The last number is the heading
	},

	NPCModel = 'a_m_m_farmer_01', -- Choose an NPC from https://docs.fivem.net/docs/game-references/ped-models/

	NPCSpawnRate = 10 * second, -- How often the NPC Trader spawns

	NPCDuration = 20 * second, -- How long the NPC Trader is visible for

	NPCItems = {
		{label = "Bread", item = "bread", price = 1000, isWeapon = false},
		{label = "Water", item = "water", price = 300, isWeapon = false},
		{label = "Assault Rifle", item = "WEAPON_ASSAULTRIFLE", price = 300, isWeapon = true}
	},

	SellItems = {
		{label = "Bread", item = "bread", price = 1000, isWeapon = false},
		{label = "Water", item = "water", price = 300, isWeapon = false},
		{label = "Assault Rifle", item = "WEAPON_ASSAULTRIFLE", price = 300, isWeapon = true}
	}
}

-- Money Type ('cash' = cash, 'bank' = bank, 'dirty' = dirty money)
Config.MoneyType = 'bank'

-- Discord Logs (to add your webhook, please go to server/discord.lua -> line 18)
Config.Discord = false

-- Debug mode, only turn on when asked to by official support
Config.DebugMode = false