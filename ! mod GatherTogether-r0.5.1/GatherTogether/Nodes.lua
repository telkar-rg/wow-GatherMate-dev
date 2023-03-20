--[[-----------------------------------------------------------------

Title: GatherTogether known Nodes
Initial Creation Date: 2008/12/02

Author: lokicoyote
File Date: 2008-12-21T03:48:23Z
File Revision: 55
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local kAddon = "GatherTogether"

-- Cache often used global functions

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local addon = LibStub("AceAddon-3.0"):GetAddon(kAddon)

addon.init = addon.init or {}

---------------------------------------------------------------------
-- Constant values
---------------------------------------------------------------------

local kNumTypes
local kNumNodeTypes = {}
do
	local kTypes = {}
	local kTypeNames = {}
	local kNodes = {}
	local kNodeTypes = {}
	do
		local kGatherNodes = {
			["Fishing"] = {
				  "Abundant Bloodsail Wreckage"
				, "Abundant Firefin Snapper School"
				, "Abundant Oily Blackmouth School"
				, "Barrelhead Goby School"
				, "Bloodsail Wreckage"
				, "Bluefish School"
				, "Borean Man O' War School"
				, "Brackish Mixed School"
				, "Deep Sea Monsterbelly School"
				, "Dragonfin Angelfish School"
				, "Fangtooth Herring School"
				, "Feltail School"
				, "Firefin Snapper School"
				, "Floating Debris"
				, "Floating Wreckage"
				, "Floating Wreckage Pool"
				, "Glacial Salmon School"
				, "Glassfin Minnow School"
				, "Greater Sagefish School"
				, "Highland Mixed School"
				, "Imperial Manta Ray School"
				, "Lesser Firefin Snapper School"
				, "Lesser Floating Debris"
				, "Lesser Oily Blackmouth School"
				, "Lesser Sagefish School"
				, "Moonglow Cuttlefish School"
				, "Muddy Churning Water"
				, "Mudfish School"
				, "Musselback Sculpin School"
				, "Nettlefish School"
				, "Oil Spill"
				, "Oily Blackmouth School"
				, "Patch of Elemental Water"
				, "Pure Water"
				, "Rockfin Grouper School"
				, "Sagefish School"
				, "School of Darter"
				, "School of Deviate Fish"
				, "School of Tastyfish"
				, "Schooner Wreckage"
				, "Sparse Firefin Snapper School"
				, "Sparse Oily Blackmouth School"
				, "Sparse Schooner Wreckage"
				, "Sporefish School"
				, "Steam Pump Flotsam"
				, "Stonescale Eel Swarm"
				, "Strange Pool"
				, "Teeming Firefin Snapper School"
				, "Teeming Floating Wreckage"
				, "Teeming Oily Blackmouth School"
				, "Waterlogged Wreckage"
			}, ["Gas Extraction"] = {
				  "Arcane Vortex"
				, "Arctic Cloud"
				, "Cinder Cloud"
				, "Felmist"
				, "Steam Cloud"
				, "Swamp Gas"
				, "Windy Cloud"
			}, ["Herb Gathering"] = {
				  "Adder's Tongue"
				, "Ancient Lichen"
				, "Arthas' Tears"
				, "Black Lotus"
				, "Blindweed"
				, "Bloodthistle"
				, "Bloodvine"
				, "Briarthorn"
				, "Bruiseweed"
				, "Constrictor Grass"
				, "Deadnettle"
				, "Dreamfoil"
				, "Dreaming Glory"
				, "Earthroot"
				, "Fadeleaf"
				, "Felweed"
				, "Fel Lotus"
				, "Firebloom"
				, "Firethorn"
				, "Flame Cap"
				, "Frost Lotus"
				, "Frozen Herb"
				, "Ghost Mushroom"
				, "Goldclover"
				, "Golden Sansam"
				, "Goldthorn"
				, "Grave Moss"
				, "Gromsblood"
				, "Icecap"
				, "Icethorn"
				, "Khadgar's Whisker"
				, "Kingsblood"
				, "Lichbloom"
				, "Liferoot"
				, "Mageroyal"
				, "Mana Thistle"
				, "Mountain Silversage"
				, "Netherbloom"
				, "Netherdust Bush"
				, "Nightmare Vine"
				, "Peacebloom"
				, "Plaguebloom"
				, "Purple Lotus"
				, "Ragveil"
				, "Silverleaf"
				, "Stranglekelp"
				, "Sungrass"
				, "Swiftthistle"
				, "Talandra's Rose"
				, "Terocone"
				, "Tiger Lily"
				, "Wild Steelbloom"
				, "Wildvine"
				, "Wintersbite"
			}, ["Mining"] = {
				  "Adamantite Deposit"
				, "Adamantite Vein" -- from MetaMap
				, "Arcane Container" -- from Gatherer?
				, "Ancient Gem Vein" -- Hyjal Summit
				, "Black Blood of Yogg-Saron" -- ? Dragonblight
				, "Cobalt Node"
				, "Copper Vein"
				, "Dark Iron Deposit"
				, "Enchanted Earth" -- Quest in Storm Peaks
				, "Fel Iron Deposit"
				, "Gold Vein"
				, "Hakkari Thorium Vein"
				, "Incendicite Mineral Vein"
				, "Indurium Mineral Vein"
				, "Iron Deposit"
				, "Khorium Vein"
				, "Large Obsidian Chunk" -- AQ 40
				, "Lesser Bloodstone Deposit"
				, "Mithril Deposit"
				, "Nethercite Deposit"
				, "Nethervine Crystal" -- Quest in Shadowmoon valley
				, "Ooze Covered Gold Vein"
				, "Ooze Covered Mithril Deposit"
				, "Ooze Covered Rich Thorium Vein"
				, "Ooze Covered Silver Vein"
				, "Ooze Covered Thorium Vein"
				, "Ooze Covered Truesilver Deposit"
				, "Rich Adamantite Deposit"
				, "Rich Cobalt Node"
				, "Rich Saronite Node"
				, "Rich Thorium Vein"
				, "Saronite Node"
				, "Silver Vein"
				, "Small Obsidian Chunk" -- AQ 40
				, "Small Thorium Vein"
				, "Strange Ore" -- ? Dragonblight
				, "Tin Vein"
				, "Titanium Node"
				, "Truesilver Deposit"
			}, ["Treasure"] = {
				  "Adamantite Bound Chest"
				, "Alliance Chest" -- from MetaMap
				, "Alliance Strongbox"
				, "Armor Crate"
				, "Barrel of Melon Juice"
				, "Barrel of Milk"
				, "Barrel of Sweet Nectar"
				, "Battered Chest"
				, "Battered Footlocker"
				, "Blood of Heroes"
				, "Bloodpetal Sprout"
				, "Blue Power Crystal"
				, "Bound Adamantite Chest"
				, "Bound Fel Iron Chest"
				, "Box of Assorted Parts"
				, "Buccaneer's Strongbox"
				, "Burial Chest"
				, "Cleansed Night Dragon"
				, "Cleansed Songflower"
				, "Cleansed Whipper Root"
				, "Cleansed Windblossom"
				, "Dented Footlocker"
				, "Everfrost Chip"
				, "Fel Iron Chest"
				, "Felsteel Chest"
				, "Food Crate"
				, "Giant Clam"
				, "Glowcap"
				, "Green Power Crystal"
				, "Heavy Fel Iron Chest"
				, "Hidden Strongbox"
				, "Horde Chest" -- from MetaMap
				, "Horde Supply Crate"
				, "Large Battered Chest"
				, "Large Darkwood Chest"
				, "Large Iron Bound Chest"
				, "Large Mithril Bound Chest"
				, "Large Solid Chest"
				, "Locked Chest"
				, "Mossy Footlocker"
				, "Netherwing Egg"
				, "Practice Lockbox"
				, "Primitive Chest"
				, "Red Power Crystal"
				, "Rusty Chest"
				, "Scarlet Footlocker"
				, "Scattered Crate"
				, "Shellfish Trap"
				, "Solid Adamantite Chest"
				, "Solid Chest"
				, "Solid Fel Iron Chest"
				, "Tattered Chest"
				, "Un'Goro Dirt Pile"
				, "Water Barrel"
				, "Waterlogged Footlocker"
				, "Weapon Crate"
				, "Wicker Chest"
				, "Yellow Power Crystal"
			}
		}

		do
			local t = 0
			for type_name, gather in pairs(kGatherNodes) do
				t = t + 1
				kTypes[ type_name ] = t
				kTypeNames[ t ] = type_name

				for id, name in ipairs(gather) do
					kNodes[ name ] = id
					kNodeTypes[ name ] = t
					n = id
				end
				kNumNodeTypes[ t ] = #gather
			end

			kNumTypes = t
		end
	end

	-- initialization
	function addon.init.GetTypeByName(in_name)
		return kTypes[ in_name ]
	end

	-- initialization
	function addon.init.GetTypeName(in_type)
		return kTypeNames[ in_type ]
	end

	-- initialization
	function addon.init.GetNodeByName(in_name)
		return kNodes[ in_name ]
	end

	-- initialization
	function addon.init.GetNodeTypeByName(in_name)
		return kNodeTypes[ in_name ]
	end
end

function addon.GetNumTypes()
	return kNumTypes
end

function addon.IsValidType(in_type)
	return 0 < (in_type or 0) and in_type <= kNumTypes
end

function addon.IsValidNode(in_type, in_node)
	if addon.IsValidType(in_type) then
		if 0 < (in_node or 0) and in_node <= kNumNodeTypes[ in_type ] then
			return true
		end
	end
	return false
end

function addon:NewNode(in_type, in_name, in_objectID, in_loot)
	if not addon.IsValidType(in_type) then return 0 end
	
	local node = kNumNodeTypes[ in_type ] + 1
	kNumNodeTypes[ in_type ] = node
	-- FIXME Determine missing information
	self.var.events:Fire("OnNewNode", node, in_name, in_objectID)
	return node
end
