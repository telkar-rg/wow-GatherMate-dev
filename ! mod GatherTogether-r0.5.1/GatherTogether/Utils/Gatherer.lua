--[[-----------------------------------------------------------------

Title: GatherTogether utils for Gatherer 
Initial Creation Date: 2008/12/04

Author: lokicoyote
File Date: 2008-12-20T02:50:49Z
File Revision: 48
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local kAddon = "GatherTogether"
local kUtil = "Gatherer"

-- Cache often used global functions
local rawset = _G.rawset

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local addon = LibStub("AceAddon-3.0"):GetAddon(kAddon)
local utils = {}

addon.utils = addon.utils or {}
addon.utils[ kUtil ] = utils

do
	local kZoneContinent = {}
	do
		for i = 1, addon.GetNumZones() do
			kZoneContinent[ i ] = addon.init.GetZoneContinent(i)
		end
	end

	function utils.GetZoneContinent(in_zone)
		return kZoneContinent[ in_zone ]
	end
end

do
	local kGathererZoneToZone = {}
	local kZoneToGathererZone = {}
	do
		-- See Gatherer/GatherZoneTokens.lua
		local kGathererExceptions = {
			  Dustwallow = "DustwallowMarsh"
			, Elwynn = "ElwynnForest"
			, Hilsbrad = "HillsbradFoothills"
			, Redridge = "RedridgeMountains"
			, Silverpine = "SilverpineForest"
			, Stranglethorn = "StranglethornVale"
			, Sunwell = "QuelDanas"
			, Tirisfal = "TirisfalGlades"
			, Hellfire = "HellfirePeninsula"
			, ZulDrak = "Zuldrak"
		}

		for zone = 1, addon.GetNumZones() do
			local name = addon.init.GetZoneFileName(zone)
			if name then
				local gatherer_name = string.gsub(kGathererExceptions[ name ] or name, "([a-z])([A-Z])", "%1_%2"):gsub("^The_", ""):gsub("_City$", ""):upper()
				kGathererZoneToZone[ gatherer_name ] = zone
				kZoneToGathererZone[ zone ] = gatherer_name
			else
				print("Unknown zone: " .. zone)
			end
		end
	end

	function utils.GetZoneFromGathererZone(in_name)
		return kGathererZoneToZone[ in_name ]
	end

	function utils.GetGathererZoneFromZone(in_zone)
		return kZoneToGathererZone[ in_zone ]
	end
end

do
	local kTypeToGathererType = {}
	do
		local kGatherTypes = {
			  ["Herbalism"] = "HERB"
			, ["Mining"] = "MINE"
		}

		for i = 1, addon.GetNumTypes() do
			kTypeToGathererType[ i ] = kGatherTypes[ addon.init.GetTypeName(i) ] or "OPEN"
		end
	end

	function utils.GetGathererTypeFromType(in_type)
		return kTypeToGathererType[ in_type ]
	end
end

do
---------------------------------------------------------------------
-- GetNodeFromObjectID / GetObjectIDFromNode
---------------------------------------------------------------------

	local function tableDefault(t, k)
		local empty = {}
		rawset(t, k, empty)
		return empty
	end

	local kObjectIDToType = {}
	local kObjectIDToNode = {}
	local kNodeAndTypeToObjectID = setmetatable({}, { __index = tableDefault })
	do
		local kObjectIDs = {
			  ["Small Thorium Vein"] = 324
			, ["Incendicite Mineral Vein"] = 1610
			, ["Copper Vein"] = 1731
			, ["Tin Vein"] = 1732
			, ["Silver Vein"] = 1733
			, ["Gold Vein"] = 1734
			, ["Iron Deposit"] = 1735
			, ["Mithril Deposit"] = 2040
			, ["Truesilver Deposit"] = 2047
			, ["Lesser Bloodstone Deposit"] = 2653
			, ["Indurium Mineral Vein"] = 19903
			, ["Ooze Covered Silver Vein"] = 73940
			, ["Ooze Covered Gold Vein"] = 73941
			, ["Ooze Covered Truesilver Deposit"] = 123309
			, ["Ooze Covered Mithril Deposit"] = 123310
			, ["Ooze Covered Thorium Vein"] = 123848
			, ["Dark Iron Deposit"] = 165658
			, ["Rich Thorium Vein"] = 175404
			, ["Ooze Covered Rich Thorium Vein"] = 177388
			, ["Hakkari Thorium Vein"] = 180215
			, ["Fel Iron Deposit"] = 181555
			, ["Adamantite Deposit"] = 181556
			, ["Khorium Vein"] = 181557
			, ["Rich Adamantite Deposit"] = 181569
			, ["Arcane Container"] = 182197
			, ["Nethercite Deposit"] = 185877
			, ["Cobalt Node"] = 189978
			, ["Rich Cobalt Node"] = 189979
			, ["Saronite Node"] = 189980
			, ["Rich Saronite Node"] = 189981
			, ["Titanium Node"] = 191133
			, ["Silverleaf"] = 1617
			, ["Peacebloom"] = 1618
			, ["Earthroot"] = 1619
			, ["Mageroyal"] = 1620
			, ["Briarthorn"] = 1621
			, ["Bruiseweed"] = 1622
			, ["Wild Steelbloom"] = 1623
			, ["Kingsblood"] = 1624
			, ["Grave Moss"] = 1628
			, ["Liferoot"] = 2041
			, ["Fadeleaf"] = 2042
			, ["Khadgar's Whisker"] = 2043
			, ["Wintersbite"] = 2044
			, ["Stranglekelp"] = 2045
			, ["Goldthorn"] = 2046
			, ["Firebloom"] = 2866
			, ["Purple Lotus"] = 142140
			, ["Arthas' Tears"] = 142141
			, ["Sungrass"] = 142142
			, ["Blindweed"] = 142143
			, ["Ghost Mushroom"] = 142144
			, ["Gromsblood"] = 142145
			, ["Golden Sansam"] = 176583
			, ["Dreamfoil"] = 176584
			, ["Mountain Silversage"] = 176586
			, ["Plaguebloom"] = 176587
			, ["Icecap"] = 176588
			, ["Black Lotus"] = 176589
			, ["Bloodthistle"] = 181166
			, ["Felweed"] = 181270
			, ["Dreaming Glory"] = 181271
			, ["Ragveil"] = 181275
			, ["Flame Cap"] = 181276
			, ["Terocone"] = 181277
			, ["Ancient Lichen"] = 181278
			, ["Netherbloom"] = 181279
			, ["Nightmare Vine"] = 181280
			, ["Mana Thistle"] = 181281
			, ["Netherdust Bush"] = 185881
			, ["Goldclover"] = 189973
			, ["Tiger Lily"] = 190169
			, ["Talandra's Rose"] = 190170
			, ["Lichbloom"] = 190171
			, ["Icethorn"] = 190172
			, ["Frozen Herb"] = 190175
			, ["Adder's Tongue"] = 191019
			, ["Firethorn"] = 191303
			, ["Hidden Strongbox"] = 2039
			, ["Giant Clam"] = 2744
			, ["Battered Chest"] = 2843
			, ["Tattered Chest"] = 2844
			, ["Solid Chest"] = 2850
			, ["Water Barrel"] = 3658
			, ["Barrel of Melon Juice"] = 3659
			, ["Armor Crate"] = 3660
			, ["Weapon Crate"] = 3661
			, ["Food Crate"] = 3662
			, ["Barrel of Milk"] = 3705
			, ["Barrel of Sweet Nectar"] = 3706
			, ["Alliance Strongbox"] = 3714
			, ["Box of Assorted Parts"] = 19019
			, ["Scattered Crate"] = 28604
			, ["Large Iron Bound Chest"] = 74447
			, ["Large Solid Chest"] = 74448
			, ["Large Battered Chest"] = 75293
			, ["Buccaneer's Strongbox"] = 123330
			, ["Large Mithril Bound Chest"] = 131978
			, ["Large Darkwood Chest"] = 131979
			, ["Horde Supply Crate"] = 142191
			, ["Un'Goro Dirt Pile"] = 157936
			, ["Blue Power Crystal"] = 164658
			, ["Green Power Crystal"] = 164659
			, ["Red Power Crystal"] = 164660
			, ["Yellow Power Crystal"] = 164661
			, ["Bloodpetal Sprout"] = 164958
			, ["Blood of Heroes"] = 176213
			, ["Shellfish Trap"] = 176582
			, ["Practice Lockbox"] = 178244
			, ["Battered Footlocker"] = 179486
			, ["Waterlogged Footlocker"] = 179487
			, ["Dented Footlocker"] = 179492
			, ["Mossy Footlocker"] = 179493
			, ["Scarlet Footlocker"] = 179498
			, ["Burial Chest"] = 181665
			, ["Fel Iron Chest"] = 181798
			, ["Heavy Fel Iron Chest"] = 181800
			, ["Adamantite Bound Chest"] = 181802
			, ["Felsteel Chest"] = 181804
			, ["Glowcap"] = 182053
			, ["Wicker Chest"] = 184740
			, ["Primitive Chest"] = 184793
			, ["Solid Fel Iron Chest"] = 184930
			, ["Bound Fel Iron Chest"] = 184931
			, ["Bound Adamantite Chest"] = 184936
			, ["Solid Adamantite Chest"] = 184939
			, ["Netherwing Egg"] = 185915
			, ["Cleansed Night Dragon"] = 164881
			, ["Cleansed Songflower"] = 164882
			, ["Cleansed Windblossom"] = 164884
			, ["Cleansed Whipper Root"] = 174622
		}

		for name, object in pairs(kObjectIDs) do
			local node = addon.init.GetNodeByName(name)
			local nodeType = addon.init.GetNodeTypeByName(name)
			if node and nodeType then
				kObjectIDToType[ object ] = nodeType
				kObjectIDToNode[ object ] = node
				kNodeAndTypeToObjectID[ nodeType ][ node ] = object
			else
				print("Unknown node: " .. node)
			end
		end
	end

	function utils.GetTypeFromObjectID(in_objectID)
		return kObjectIDToType[ in_objectID ]
	end

	function utils.GetNodeFromObjectID(in_objectID)
		return kObjectIDToNode[ in_objectID ]
	end

	function utils.GetObjectIDFromNodeAndType(in_type, in_node)
		return kNodeAndTypeToObjectID[ in_type ][ in_node ]
	end
end
