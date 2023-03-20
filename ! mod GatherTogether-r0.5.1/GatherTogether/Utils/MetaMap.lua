--[[-----------------------------------------------------------------

Title: GatherTogether utils for MetaMap 
Initial Creation Date: 2008/12/17

Author: lokicoyote
File Date: 2008-12-22T19:51:44Z
File Revision: 58
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local kAddon = "GatherTogether"
local kUtil = "MetaMap"

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
---------------------------------------------------------------------
-- GetZoneFromMetaMapZone / GetMetaMapZoneFromZone
---------------------------------------------------------------------

	local kMetaMapZoneToZone = {}
	local kZoneToMetaMapZone = {}
	do
		-- See MetaMap/MetaMap.lua
		local kMetaMapZones = {
--- Kalimdor
			  ["Ashenvale"] = 1
			, ["Aszhara"] = 2
			, ["Darkshore"] = 3
			, ["Darnassis"] = 4
			, ["Desolace"] = 5
			, ["Durotar"] = 6
			, ["Dustwallow"] = 7
			, ["Felwood"] = 8
			, ["Feralas"] = 9
			, ["Moonglade"] = 10
			, ["Mulgore"] = 11
			, ["Ogrimmar"] = 12
			, ["Silithus"] = 13
			, ["StonetalonMountains"] = 14
			, ["Tanaris"] = 15
			, ["Teldrassil"] = 16
			, ["Barrens"] = 17
			, ["ThousandNeedles"] = 18
			, ["ThunderBluff"] = 19
			, ["UngoroCrater"] = 20
			, ["Winterspring"] = 21
			, ["EversongWoods"] = 22
			, ["Ghostlands"] = 23
			, ["SilvermoonCity"] = 24
--- Eastern Kingdoms
			, ["Alterac"] = 30
			, ["Arathi"] = 31
			, ["Badlands"] = 32
			, ["BlastedLands"] = 33
			, ["BurningSteppes"] = 34
			, ["DeadwindPass"] = 35
			, ["DunMorogh"] = 36
			, ["Duskwood"] = 37
			, ["EasternPlaguelands"] = 38
			, ["Elwynn"] = 39
			, ["Hilsbrad"] = 40
			, ["Ironforge"] = 41
			, ["LochModan"] = 42
			, ["Redridge"] = 43
			, ["SearingGorge"] = 44
			, ["Silverpine"] = 45
			, ["Stormwind"] = 46
			, ["Stranglethorn"] = 47
			, ["SwampOfSorrows"] = 48
			, ["Hinterlands"] = 49
			, ["Tirisfal"] = 50
			, ["Undercity"] = 51
			, ["WesternPlaguelands"] = 52
			, ["Westfall"] = 53
			, ["Wetlands"] = 54
			, ["AzuremystIsle"] = 55
			, ["BloodmystIsle"] = 56
			, ["TheExodar"] = 57
--- Outlands
			, ["Hellfire"] = 60
			, ["BladesEdgeMountains"] = 61
			, ["Nagrand"] = 62
			, ["Netherstorm"] = 63
			, ["ShadowmoonValley"] = 64
			, ["ShattrathCity"] = 65
			, ["TerokkarForest"] = 66
			, ["Zangarmarsh"] = 67
--- BattleGrounds
			, ["WarsongGulch"] = 70
			, ["AlteracValley"] = 71
			, ["ArathiBasin"] = 72
			, ["NetherstormArena"] = 73 -- Eye of the Storm
--- Northrend
			, ["TheStormPeaks"] = 200
			, ["Dragonblight"] = 201
			, ["BoreanTundra"] = 202
			, ["GrizzlyHills"] = 203
			, ["HowlingFjord"] = 204
			, ["CrystalsongForest"] = 205
			, ["SholazarBasin"] = 206
			, ["ZulDrak"] = 207
			, ["IcecrownGlacier"] = 208
			, ["LakeWintergrasp"] = 209
			, ["Dalaran"] = 210
		}
		for name, id in pairs(kMetaMapZones) do
			local zone = addon.init.GetZoneByFileName(name) or 0
			if 0 < zone then
				kMetaMapZoneToZone[ id ] = zone
				kZoneToMetaMapZone[ zone ] = id
			else
				print("Unknown zone: " .. name)
			end
		end
	end

	function utils.GetZoneFromMetaMapZone(in_zoneID)
		return kMetaMapZoneToZone[ in_zoneID ]
	end

	function utils.GetMetaMapZoneFromZone(in_zone)
		return kZoneToMetaMapZone[ in_zone ]
	end
end

do
---------------------------------------------------------------------
-- GetNodeFromMetaMapNodeAndType / GetMetaMapNodeFromNodeAndType
---------------------------------------------------------------------

	local function tableDefault(t, k)
		local empty = {}
		rawset(t, k, empty)
		return empty
	end

	local kMetaMapNodeToType = {}
	local kMetaMapNodeAndTypeToNode = setmetatable({}, { __index = tableDefault })
	local kNodeAndTypeToMetaMapNode = setmetatable({}, { __index = tableDefault })
	do
		-- See MetaMapTRK/MetaMapTRK.lua
		local kMetaMapNodes = {
			  ["Silverleaf"] = 1 -- TRK_HRB_NAME
			, ["Peacebloom"] = 2 -- TRK_HRB_NAME
			, ["Earthroot"] = 3 -- TRK_HRB_NAME
			, ["Mageroyal"] = 4 -- TRK_HRB_NAME
			, ["Swiftthistle"] = 5 -- TRK_HRB_NAME
			, ["Briarthorn"] = 6 -- TRK_HRB_NAME
			, ["Stranglekelp"] = 7 -- TRK_HRB_NAME
			, ["Bruiseweed"] = 8 -- TRK_HRB_NAME
			, ["Wild Steelbloom"] = 9 -- TRK_HRB_NAME
			, ["Grave Moss"] = 10 -- TRK_HRB_NAME
			, ["Kingsblood"] = 11 -- TRK_HRB_NAME
			, ["Liferoot"] = 12 -- TRK_HRB_NAME
			, ["Fadeleaf"] = 13 -- TRK_HRB_NAME
			, ["Goldthorn"] = 14 -- TRK_HRB_NAME
			, ["Khadgar's Whisker"] = 15 -- TRK_HRB_NAME
			, ["Wintersbite"] = 16 -- TRK_HRB_NAME
			, ["Firebloom"] = 17 -- TRK_HRB_NAME
			, ["Purple Lotus"] = 18 -- TRK_HRB_NAME
			, ["Wildvine"] = 19 -- TRK_HRB_NAME
			, ["Arthas' Tears"] = 20 -- TRK_HRB_NAME
			, ["Sungrass"] = 21 -- TRK_HRB_NAME
			, ["Blindweed"] = 22 -- TRK_HRB_NAME
			, ["Ghost Mushroom"] = 23 -- TRK_HRB_NAME
			, ["Gromsblood"] = 24 -- TRK_HRB_NAME
			, ["Golden Sansam"] = 25 -- TRK_HRB_NAME
			, ["Dreamfoil"] = 26 -- TRK_HRB_NAME
			, ["Mountain Silversage"] = 27 -- TRK_HRB_NAME
			, ["Plaguebloom"] = 28 -- TRK_HRB_NAME
			, ["Icecap"] = 29 -- TRK_HRB_NAME
			, ["Black Lotus"] = 30 -- TRK_HRB_NAME
			, ["Felweed"] = 31 -- TRK_HRB_NAME
			, ["Dreaming Glory"] = 32 -- TRK_HRB_NAME
			, ["Terocone"] = 33 -- TRK_HRB_NAME
			, ["Ragveil"] = 34 -- TRK_HRB_NAME
			, ["Netherbloom"] = 35 -- TRK_HRB_NAME
			, ["Flame Cap"] = 36 -- TRK_HRB_NAME
			, ["Fel Lotus"] = 37 -- TRK_HRB_NAME
			, ["Mana Thistle"] = 38 -- TRK_HRB_NAME
			, ["Nightmare Vine"] = 39 -- TRK_HRB_NAME
			, ["Ancient Lichen"] = 40 -- TRK_HRB_NAME
	--- Ores
			, ["Copper Vein"] = 50 -- TRK_ORE_NAME
			, ["Tin Vein"] = 51 -- TRK_ORE_NAME
			, ["Silver Vein"] = 52 -- TRK_ORE_NAME
			, ["Iron Deposit"] = 53 -- TRK_ORE_NAME
			, ["Gold Vein"] = 54 -- TRK_ORE_NAME
			, ["Mithril Deposit"] = 55 -- TRK_ORE_NAME
			, ["Truesilver Deposit"] = 56 -- TRK_ORE_NAME
			, ["Dark Iron Deposit"] = 57 -- TRK_ORE_NAME
			, ["Small Thorium Vein"] = 58 -- TRK_ORE_NAME
			, ["Rich Thorium Vein"] = 59 -- TRK_ORE_NAME
			, ["Fel Iron Deposit"] = 60 -- TRK_ORE_NAME
			, ["Adamantite Vein"] = 61 -- TRK_ORE_NAME
			, ["Rich Adamantite Deposit"] = 62 -- TRK_ORE_NAME
			, ["Khorium Vein"] = 63 -- TRK_ORE_NAME
			, ["Adamantite Deposit"] = 64 -- TRK_ORE_NAME
			, ["Lesser Bloodstone Deposit"] = 65 -- TRK_ORE_NAME
			, ["Hakkari Thorium Vein"] = 66 -- TRK_ORE_NAME
	--- Treasure
			, ["Alliance Chest"] = 80 -- TRK_TRS_NAME
			, ["Horde Chest"] = 81 -- TRK_TRS_NAME
			, ["Battered Chest"] = 82 -- TRK_TRS_NAME
			, ["Locked Chest"] = 83 -- TRK_TRS_NAME
			, ["Rusty Chest"] = 84 -- TRK_TRS_NAME
			, ["Solid Chest"] = 85 -- TRK_TRS_NAME
			, ["Armor Crate"] = 86 -- TRK_TRS_NAME
			, ["Food Crate"] = 87 -- TRK_TRS_NAME
			, ["Horde Supply Crate"] = 88 -- TRK_TRS_NAME
			, ["Box of Assorted Parts"] = 89 -- TRK_TRS_NAME
			, ["Hidden Strongbox"] = 90 -- TRK_TRS_NAME
			, ["Weapon Crate"] = 91 -- TRK_TRS_NAME
			, ["Battered Footlocker"] = 92 -- TRK_TRS_NAME
			, ["Blood of Heroes"] = 93 -- TRK_TRS_NAME
			, ["Shellfish Trap"] = 94 -- TRK_TRS_NAME
			, ["Giant Clam"] = 95 -- TRK_TRS_NAME
			, ["Red Power Crystal"] = 96 -- TRK_TRS_NAME
			, ["Blue Power Crystal"] = 97 -- TRK_TRS_NAME
			, ["Green Power Crystal"] = 98 -- TRK_TRS_NAME
			, ["Yellow Power Crystal"] = 99 -- TRK_TRS_NAME
			, ["Un'Goro Dirt Pile"] = 100 -- TRK_TRS_NAME
			, ["Bloodpetal Sprout"] = 101 -- TRK_TRS_NAME
		}
		-- This assumes a basic agreement on nodeTypes
		for name, id in pairs(kMetaMapNodes) do
			local node = addon.init.GetNodeByName(name)
			local nodeType = addon.init.GetNodeTypeByName(name)
			if node and nodeType then
				kMetaMapNodeToType[ id ] = nodeType
				kMetaMapNodeAndTypeToNode[ nodeType ][ id ] = node
				kNodeAndTypeToMetaMapNode[ nodeType ][ node ] = id
			else
				print("Unknown node: " .. name)
			end
		end
	end

	function utils.GetTypeFromMetaMapNode(in_node)
		return kMetaMapNodeToType[ in_node ]
	end

	function utils.GetNodeFromMetaMapNodeAndType(in_type, in_node)
		return kMetaMapNodeAndTypeToNode[ in_type ][ in_node ]
	end

	function utils.GetMetaMapNodeFromNodeAndType(in_type, in_node)
		return kNodeAndTypeToMetaMapNode[ in_type ][ in_node ]
	end
end
