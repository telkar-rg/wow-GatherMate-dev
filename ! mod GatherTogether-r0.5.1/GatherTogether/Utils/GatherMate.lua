--[[-----------------------------------------------------------------

Title: GatherTogether utils for GatherMate 
Initial Creation Date: 2008/12/04

Author: lokicoyote
File Date: 2008-12-20T02:50:49Z
File Revision: 48
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local kAddon = "GatherTogether"
local kUtil = "GatherMate"

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
-- GetZoneFromGatherMateZone / GetGatherMateZoneFromZone
---------------------------------------------------------------------

	local kGatherMateZoneToZone = {}
	local kZoneToGatherMateZone = {}
	do
		-- See GatherMate/Constants.lua
		local kGatherMateZones = {
			  ["Arathi"] = 1
			, ["Ogrimmar"] = 2
			, ["EasternKingdoms"] = 3
			, ["Undercity"] = 4
			, ["Barrens"] = 5
			, ["Darnassis"] = 6
			, ["AzuremystIsle"] = 7
			, ["UngoroCrater"] = 8
			, ["BurningSteppes"] = 9
			, ["Wetlands"] = 10
			, ["Winterspring"] = 11
			, ["Dustwallow"] = 12
			, ["Darkshore"] = 13
			, ["LochModan"] = 14
			, ["BladesEdgeMountains"] = 15
			, ["Durotar"] = 16
			, ["Silithus"] = 17
			, ["ShattrathCity"] = 18
			, ["Ashenvale"] = 19
			, ["Azeroth"] = 20
			, ["Nagrand"] = 21
			, ["TerokkarForest"] = 22
			, ["EversongWoods"] = 23
			, ["SilvermoonCity"] = 24
			, ["Tanaris"] = 25
			, ["Stormwind"] = 26
			, ["SwampOfSorrows"] = 27
			, ["EasternPlaguelands"] = 28
			, ["BlastedLands"] = 29
			, ["Elwynn"] = 30
			, ["DeadwindPass"] = 31
			, ["DunMorogh"] = 32
			, ["TheExodar"] = 33
			, ["Felwood"] = 34
			, ["Silverpine"] = 35
			, ["ThunderBluff"] = 36
			, ["Hinterlands"] = 37
			, ["StonetalonMountains"] = 38
			, ["Mulgore"] = 39
			, ["Hellfire"] = 40
			, ["Ironforge"] = 41
			, ["ThousandNeedles"] = 42
			, ["Stranglethorn"] = 43
			, ["Badlands"] = 44
			, ["Teldrassil"] = 45
			, ["Moonglade"] = 46
			, ["ShadowmoonValley"] = 47
			, ["Tirisfal"] = 48
			, ["Aszhara"] = 49
			, ["Redridge"] = 50
			, ["BloodmystIsle"] = 51
			, ["WesternPlaguelands"] = 52
			, ["Alterac"] = 53
			, ["Westfall"] = 54
			, ["Duskwood"] = 55
			, ["Netherstorm"] = 56
			, ["Ghostlands"] = 57
			, ["Zangarmarsh"] = 58
			, ["Desolace"] = 59
			, ["Kalimdor"] = 60
			, ["SearingGorge"] = 61
			, ["Expansion01"] = 62
			, ["Feralas"] = 63
			, ["Hilsbrad"] = 64
			, ["Sunwell"] = 65
			, ["Northrend"] = 66
			, ["BoreanTundra"] = 67
			, ["Dragonblight"] = 68
			, ["GrizzlyHills"] = 69
			, ["HowlingFjord"] = 70
			, ["IcecrownGlacier"] = 71
			, ["SholazarBasin"] = 72
			, ["TheStormPeaks"] = 73
			, ["ZulDrak"] = 74
			, ["LakeWintergrasp"] = 75
			, ["ScarletEnclave"] = 76
			, ["CrystalsongForest"] = 77
			, ["LakeWintergrasp"] = 78
			, ["StrandoftheAncients"] = 79
			, ["Dalaran"] = 80
		}
		for name, id in pairs(kGatherMateZones) do
			local zone = addon.init.GetZoneByFileName(name) or 0
			if 0 < zone then
				kGatherMateZoneToZone[ id ] = zone
				kZoneToGatherMateZone[ zone ] = id
			else
				print("Unknown zone: " .. name)
			end
		end
	end

	function utils.GetZoneFromGatherMateZone(in_zoneID)
		return kGatherMateZoneToZone[ in_zoneID ]
	end

	function utils.GetGatherMateZoneFromZone(in_zone)
		return kZoneToGatherMateZone[ in_zone ]
	end
end

do
---------------------------------------------------------------------
-- GetTypeFromSharingType
---------------------------------------------------------------------

	local kSharingTypeToType = {}
	local kTypeToSharingType = {}
	do
		-- See GatherMate_Sharing/GatherMate_Sharing.lua
		local kSharingTypes = {
			  "Herb Gathering"
			, "Mining"
			, "Fishing"
			, "Gas Extraction"
			, "Treasure"
		}
		for i, name in ipairs(kSharingTypes) do
			local nodeType = addon.init.GetTypeByName(name)
			if nodeType then
				kSharingTypeToType[ i ] = nodeType
				kTypeToSharingType[ nodeType ] = i
			else
				print("Unknown type: " .. name)
			end
		end
	end

	function utils.GetTypeFromSharingType(in_type)
		return kSharingTypeToType[ in_type ]
	end

	function utils.GetSharingTypeFromType(in_type)
		return kTypeToSharingType[ in_type ]
	end
end

do
---------------------------------------------------------------------
-- GetTypeFromGatherMateName / GetGatherMateNameFromType
---------------------------------------------------------------------

	local kGatherMateNameToType = {}
	local kTypeToGatherMateName = {}
	do
		local kGatherMateNodeTypeExceptions = {
			["Gas Extraction"] = "Extract Gas"
		}
		for nodeType = 1, addon.GetNumTypes() do
			local name = addon.init.GetTypeName(nodeType)
			local gm_name = kGatherMateNodeTypeExceptions[ name ] or name
			kGatherMateNameToType[ gm_name ] = nodeType
			kTypeToGatherMateName[ nodeType ] = gm_name
		end
	end

	function utils.GetTypeFromGatherMateName(in_name)
		return kGatherMateNameToType[ in_name ]
	end

	function utils.GetGatherMateNameFromType(in_type)
		return kTypeToGatherMateName[ in_type ]
	end
end

do
---------------------------------------------------------------------
-- GetNodeFromGatherMateNodeAndType / GetGatherMateNodeFromNodeAndType
---------------------------------------------------------------------

	local function tableDefault(t, k)
		local empty = {}
		rawset(t, k, empty)
		return empty
	end

	local kGatherMateNodeAndTypeToNode = setmetatable({}, { __index = tableDefault })
	local kNodeAndTypeToGatherMateNode = setmetatable({}, { __index = tableDefault })
	do
		-- See GatherMate/Constants.lua
		local kGatherMateNodes = {
			  ["Floating Wreckage"] = 101
			, ["Patch of Elemental Water"] = 102
			, ["Floating Debris"] = 103
			, ["Oil Spill"] = 104
			, ["Firefin Snapper School"] = 105
			, ["Greater Sagefish School"] = 106
			, ["Oily Blackmouth School"] = 107
			, ["Sagefish School"] = 108
			, ["School of Deviate Fish"] = 109
			, ["Stonescale Eel Swarm"] = 110
			, ["Muddy Churning Water"] = 111
			, ["Highland Mixed School"] = 112
			, ["Pure Water"] = 113
			, ["Bluefish School"] = 114
			, ["Feltail School"] = 115
			, ["Brackish Mixed School"] = 115
			, ["Mudfish School"] = 116
			, ["School of Darter"] = 117
			, ["Sporefish School"] = 118
			, ["Steam Pump Flotsam"] = 119
			, ["School of Tastyfish"] = 120
			, ["Borean Man O' War School"] = 121
			, ["Deep Sea Monsterbelly School"] = 122
			, ["Dragonfin Angelfish School"] = 123
			, ["Fangtooth Herring School"] = 124
			, ["Floating Wreckage Pool"] = 125
			, ["Glacial Salmon School"] = 126
			, ["Glassfin Minnow School"] = 127
			, ["Imperial Manta Ray School"] = 128
			, ["Moonglow Cuttlefish School"] = 129
			, ["Musselback Sculpin School"] = 130
			, ["Nettlefish School"] = 131
			, ["Strange Pool"] = 132
			, ["Schooner Wreckage"] = 133
			, ["Waterlogged Wreckage"] = 134
			, ["Bloodsail Wreckage"] = 135
			, ["Lesser Sagefish School"] = 136
			, ["Lesser Oily Blackmouth School"] = 137
			, ["Sparse Oily Blackmouth School"] = 138
			, ["Abundant Oily Blackmouth School"] = 139
			, ["Teeming Oily Blackmouth School"] = 140
			, ["Lesser Firefin Snapper School"] = 141
			, ["Sparse Firefin Snapper School"] = 142
			, ["Abundant Firefin Snapper School"] = 143
			, ["Teeming Firefin Snapper School"] = 144
			, ["Lesser Floating Debris"] = 145
			, ["Sparse Schooner Wreckage"] = 146
			, ["Abundant Bloodsail Wreckage"] = 147
			, ["Teeming Floating Wreckage"] = 148
			, ["Copper Vein"] = 201
			, ["Tin Vein"] = 202
			, ["Iron Deposit"] = 203
			, ["Silver Vein"] = 204
			, ["Gold Vein"] = 205
			, ["Mithril Deposit"] = 206
			, ["Ooze Covered Mithril Deposit"] = 207
			, ["Truesilver Deposit"] = 208
			, ["Ooze Covered Silver Vein"] = 209
			, ["Ooze Covered Gold Vein"] = 210
			, ["Ooze Covered Truesilver Deposit"] = 211
			, ["Ooze Covered Rich Thorium Vein"] = 212
			, ["Ooze Covered Thorium Vein"] = 213
			, ["Small Thorium Vein"] = 214
			, ["Rich Thorium Vein"] = 215
			, ["Hakkari Thorium Vein"] = 216
			, ["Dark Iron Deposit"] = 217
			, ["Lesser Bloodstone Deposit"] = 218
			, ["Incendicite Mineral Vein"] = 219
			, ["Indurium Mineral Vein"] = 220
			, ["Fel Iron Deposit"] = 221
			, ["Adamantite Deposit"] = 222
			, ["Rich Adamantite Deposit"] = 223
			, ["Khorium Vein"] = 224
			, ["Large Obsidian Chunk"] = 225
			, ["Small Obsidian Chunk"] = 226
			, ["Nethercite Deposit"] = 227
			, ["Cobalt Node"] = 228
			, ["Rich Cobalt Node"] = 229
			, ["Titanium Node"] = 230
			, ["Saronite Node"] = 231
			, ["Rich Saronite Node"] = 232
			, ["Windy Cloud"] = 301
			, ["Swamp Gas"] = 302
			, ["Arcane Vortex"] = 303
			, ["Felmist"] = 304
			, ["Steam Cloud"] = 305
			, ["Cinder Cloud"] = 306
			, ["Arctic Cloud"] = 307
			, ["Peacebloom"] = 401
			, ["Silverleaf"] = 402
			, ["Earthroot"] = 403
			, ["Mageroyal"] = 404
			, ["Briarthorn"] = 405
			, ["Swiftthistle"] = 406
			, ["Stranglekelp"] = 407
			, ["Bruiseweed"] = 408
			, ["Wild Steelbloom"] = 409
			, ["Grave Moss"] = 410
			, ["Kingsblood"] = 411
			, ["Liferoot"] = 412
			, ["Fadeleaf"] = 413
			, ["Goldthorn"] = 414
			, ["Khadgar's Whisker"] = 415
			, ["Wintersbite"] = 416
			, ["Firebloom"] = 417
			, ["Purple Lotus"] = 418
			, ["Wildvine"] = 419
			, ["Arthas' Tears"] = 420
			, ["Sungrass"] = 421
			, ["Blindweed"] = 422
			, ["Ghost Mushroom"] = 423
			, ["Gromsblood"] = 424
			, ["Golden Sansam"] = 425
			, ["Dreamfoil"] = 426
			, ["Mountain Silversage"] = 427
			, ["Plaguebloom"] = 428
			, ["Icecap"] = 429
			, ["Bloodvine"] = 430
			, ["Black Lotus"] = 431
			, ["Felweed"] = 432
			, ["Dreaming Glory"] = 433
			, ["Terocone"] = 434
			, ["Ancient Lichen"] = 435
			, ["Bloodthistle"] = 436
			, ["Mana Thistle"] = 437
			, ["Netherbloom"] = 438
			, ["Nightmare Vine"] = 439
			, ["Ragveil"] = 440
			, ["Flame Cap"] = 441
			, ["Netherdust Bush"] = 442
			, ["Adder's Tongue"] = 443
			, ["Constrictor Grass"] = 444
			, ["Deadnettle"] = 445
			, ["Goldclover"] = 446
			, ["Icethorn"] = 447
			, ["Lichbloom"] = 448
			, ["Talandra's Rose"] = 449
			, ["Tiger Lily"] = 450
			, ["Firethorn"] = 451
			, ["Frozen Herb"] = 452
			, ["Frost Lotus"] = 453
			, ["Giant Clam"] = 501
			, ["Battered Chest"] = 502
			, ["Tattered Chest"] = 503
			, ["Solid Chest"] = 504
			, ["Large Iron Bound Chest"] = 505
			, ["Large Solid Chest"] = 506
			, ["Large Battered Chest"] = 507
			, ["Buccaneer's Strongbox"] = 508
			, ["Large Mithril Bound Chest"] = 509
			, ["Large Darkwood Chest"] = 510
			, ["Un'Goro Dirt Pile"] = 511
			, ["Bloodpetal Sprout"] = 512
			, ["Blood of Heroes"] = 513
			, ["Practice Lockbox"] = 514
			, ["Battered Footlocker"] = 515
			, ["Waterlogged Footlocker"] = 516
			, ["Dented Footlocker"] = 517
			, ["Mossy Footlocker"] = 518
			, ["Scarlet Footlocker"] = 519
			, ["Burial Chest"] = 520
			, ["Fel Iron Chest"] = 521
			, ["Heavy Fel Iron Chest"] = 522
			, ["Adamantite Bound Chest"] = 523
			, ["Felsteel Chest"] = 524
			, ["Glowcap"] = 525
			, ["Wicker Chest"] = 526
			, ["Primitive Chest"] = 527
			, ["Solid Fel Iron Chest"] = 528
			, ["Bound Fel Iron Chest"] = 529
			, ["Bound Adamantite Chest"] = 530
			, ["Netherwing Egg"] = 531
			, ["Everfrost Chip"] = 532
		}
		-- This assumes a basic agreement on nodeTypes
		for name, id in pairs(kGatherMateNodes) do
			local node = addon.init.GetNodeByName(name)
			local nodeType = addon.init.GetNodeTypeByName(name)
			if node and nodeType then
				kGatherMateNodeAndTypeToNode[ nodeType ][ id ] = node
				kNodeAndTypeToGatherMateNode[ nodeType ][ node ] = id
			else
				print("Unknown node: " .. name)
			end
		end
	end

	function utils.GetNodeFromGatherMateNodeAndType(in_type, in_node)
		return kGatherMateNodeAndTypeToNode[ in_type ][ in_node ]
	end

	function utils.GetGatherMateNodeFromNodeAndType(in_type, in_node)
		return kNodeAndTypeToGatherMateNode[ in_type ][ in_node ]
	end
end
