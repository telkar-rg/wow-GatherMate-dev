--[[-----------------------------------------------------------------

Title: GatherTogether known Zones
Initial Creation Date: 2008/12/04

Author: lokicoyote
File Date: 2008-12-19T00:47:49Z
File Revision: 36
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

local kNumZones
do
	local kZones = {}
	local kZoneContinents = {}
	do
		local kZoneFileNames = {
			  "Alterac"
			, "AlteracValley"
			, "Arathi"
			, "ArathiBasin"
			, "Ashenvale"
			, "Aszhara"
			, "Azeroth"
			, "AzuremystIsle"
			, "Badlands"
			, "Barrens"
			, "Blackrock"
			, "BladesEdgeMountains"
			, "BlastedLands"
			, "BloodmystIsle"
			, "BoreanTundra"
			, "BurningSteppes"
			, "Cosmic"
			, "CrystalsongForest" -- not CrystalSongForest?
			, "Dalaran"
			, "Darkshore"
			, "Darnassis"
			, "DarrowmereLake"
			, "DeadwindPass"
			, "Desolace"
			, "Dragonblight"
			, "DunMorogh"
			, "Durotar"
			, "Duskwood"
			, "Dustwallow"
			, "EasternKingdoms"
			, "EasternPlaguelands"
			, "Elwynn"
			, "EversongWoods"
			, "Expansion01"
			, "Felwood"
			, "Feralas"
			, "Ghostlands"
			, "GrizzlyHills"
			, "Hellfire"
			, "Hilsbrad"
			, "Hinterlands"
			, "HowlingFjord"
			, "IcecrownGlacier"
			, "Ironforge"
			, "Kalidar"
			, "Kalimdor"
			, "LakeWintergrasp"
			, "LochModan"
			, "Moonglade"
			, "Mulgore"
			, "Nagrand"
			, "Netherstorm"
			, "NetherstormArena"
			, "Northrend"
			, "Ogrimmar"
			, "Redridge"
			, "ScarletEnclave"
			, "SearingGorge"
			, "ShadowmoonValley"
			, "ShattrathCity"
			, "SholazarBasin"
			, "Silithus"
			, "SilvermoonCity"
			, "Silverpine"
			, "StonetalonMountains"
			, "Stormwind"
			, "StrandoftheAncients"
			, "Stranglethorn"
			, "Sunwell"
			, "SwampOfSorrows"
			, "Tanaris"
			, "Teldrassil"
			, "TerokkarForest"
			, "TheExodar"
			, "TheStormPeaks"
			, "ThousandNeedles" -- not Thousandneedles
			, "ThunderBluff"
			, "Tirisfal"
			, "Undercity"
			, "UngoroCrater"
			, "WarsongGulch"
			, "WesternPlaguelands"
			, "Westfall"
			, "Wetlands"
			, "Winterspring"
			, "World"
			, "Zangarmarsh"
			, "ZulDrak"
		}

		kNumZones = #kZoneFileNames

		for k, v in ipairs(kZoneFileNames) do
			kZones[ v ] = k
		end
		
		do
			local map_continents = { GetMapContinents() }
			for continent in ipairs(map_continents) do
				local zones = { GetMapZones(continent) }
				for zone, localized_name in ipairs(zones) do
					SetMapZoom(continent, zone)
					local file_name = GetMapInfo()
					local zone = kZones[ file_name ] or 0
					if 0 < zone then
						kZoneContinents[ zone ] = continent
					else
						print("Unknown zone: " .. file_name)
					end
				end
			end
		end

		function addon.init.GetZoneFileName(in_zone)
			return kZoneFileNames[ in_zone ]
		end
	end

	function addon.init.GetZoneByFileName(in_name)
		return kZones[ in_name ]
	end

	function addon.init.GetZoneContinent(in_zone)
		return kZoneContinents[ in_zone ]
	end
end

function addon.GetNumZones()
	return kNumZones
end

function addon.IsValidZone(in_zone)
	return 0 < (in_zone or 0) and in_zone <= kNumZones
end
