--[[-----------------------------------------------------------------

GatherTogether_GathererSupport

Initial Creation Date: 2008/12/04
Description: Gatherer support module for GatherTogether

Author: lokicoyote
File Date: 2008-12-20T23:48:10Z
File Revision: 53
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local function hasGatherer()
	return "table" == type(Gatherer) and "table" == type(Gatherer.Api) and "function" == type(Gatherer.Api.AddGather) and "table" == type(Gatherer.ZoneTokens) and "function" == type(Gatherer.ZoneTokens.GetZoneIndex)
end

if not hasGatherer() then
	return
end

assert(LibStub)

local kAddon = "GatherTogether"
local kModule = "Gatherer"

-- Cache often used global functions
local pcall, tonumber = _G.pcall, _G.tonumber
local strsplit = _G.strsplit

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local addon = LibStub("AceAddon-3.0"):GetAddon(kAddon):GetModule("Support"):NewModule(kModule, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0")

local kCommGathererAddNode = "GathX"

---------------------------------------------------------------------
-- AceAddon IMPLEMENTED functions
---------------------------------------------------------------------

function addon:OnEnable()
	if not hasGatherer() then
		Disable()
		return
	end

	self:GetBridges():DeactivateBridge(kModule)

	self.var.Gatherer_Api_AddGather = Gatherer.Api.AddGather

	self:RegisterCallback("OnNodeAdded", "onNodeAdded")
	-- Callbacks sent by Gatherer (only sends CHAT_MSG_ADDON...)
	self:RegisterComm(kCommGathererAddNode, "gathererMessage")
end

function addon:OnDisable()
	self:UnregisterAllCallbacks()
	-- Embeds handle unregistering messages
	self:GetBridges():ActivateBridge(kModule)
end

do
---------------------------------------------------------------------
-- GatherTogether Handlers
---------------------------------------------------------------------

	local getObjectID = addon.utils.GetObjectIDFromNodeAndType
	local getGatherType = addon.utils.GetGathererTypeFromType
	local getContinent = addon.utils.GetZoneContinent
	local getZone = addon.utils.GetGathererZoneFromZone

	function addon:onNodeAdded(_, in_source, in_zone, in_x, in_y, in_nodeType, in_node, in_loot, in_note)
		if in_source and not self:IsProcessing(kModule) then
			local objectID = getObjectID(in_nodeType, in_node)
			local gatherType = getGatherType(in_nodeType)
			local continent = getContinent(in_zone)
			local zone = Gatherer.ZoneTokens.GetZoneIndex(continent, getZone(in_zone))
			if not objectID then
				--[===[@alpha@
				self:Print("Unknown node:", in_nodeType, in_node)
				--@end-alpha@]===]
			elseif not gatherType then
				--[===[@alpha@
				self:Print("Unknown gatherType:", in_nodeType)
				--@end-alpha@]===]
			elseif not continent then
				--[===[@alpha@
				self:Print("Unknown continent for", in_zone)
				--@end-alpha@]===]
			elseif not zone then
				--[===[@alpha@
				self:Print("Unknown zone:", in_zone)
				--@end-alpha@]===]
			else
				-- TODO: Do something with in_loot and in_note
				self.var.Gatherer_Api_AddGather(objectID, gatherType, "", in_source, 0, nil, true, continent, zone, in_x, in_y)
			end
		end
	end
end

do
---------------------------------------------------------------------
-- Gatherer Handlers
---------------------------------------------------------------------

	local decodeGatherer -- forward declaration
	do
		local getZone = addon.utils.GetZoneFromGathererZone
		local getNodeType = addon.utils.GetTypeFromObjectID
		local getNode = addon.utils.GetNodeFromObjectID

		function decodeGatherer(self, in_objectID, in_continent, in_zone, in_x, in_y, in_loot)
			local zone = getZone(in_zone)
			local nodeType = getNodeType(tonumber(in_objectID))
			local node = getNode(tonumber(in_objectID))
			-- TODO: Decode in_loot
			local result = self:AddNode(nil, zone, tonumber(in_x), tonumber(in_y), nodeType, node)
			if not self.IsResultOk(result) then
				-- TODO: Add new types
				-- TODO: Add new node types
			end
		end
	end

	function addon:gathererMessage(in_prefix, in_message, in_distribution, in_sender)
		if in_prefix ~= kCommGathererAddNode then return end
		if in_sender ~= self.var.me then return end -- We only want the events from ourselves

		local result, msg = true

		if self:BeginProcessing(kModule) then
			result, msg = pcall(decodeGatherer, self, strsplit(";", in_message))
			self:EndProcessing()
		end
		--[===[@alpha@
		if not result then
			print("Error:", in_message, ":", msg)
		end
		--@end-alpha@]===]
	end
end
