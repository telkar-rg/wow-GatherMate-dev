--[[-----------------------------------------------------------------

GatherTogether_GatherMate

Initial Creation Date: 2008/12/04
Description: GatherMate support module for GatherTogether

Author: lokicoyote
File Date: 2008-12-23T20:41:26Z
File Revision: 64
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

assert(LibStub)

local function hasGatherMate()
	return LibStub("AceAddon-3.0"):GetAddon("GatherMate", true) and true
end

if not hasGatherMate() then
	return
end

local kAddon = "GatherTogether"
local kModule = "GatherMate"

-- Cache often used global functions
local pcall, tonumber = _G.pcall, _G.tonumber

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local addon = LibStub("AceAddon-3.0"):GetAddon(kAddon):GetModule("Support"):NewModule(kModule, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local GatherMate = LibStub("AceAddon-3.0"):GetAddon("GatherMate", true)

---------------------------------------------------------------------
-- AceAddon IMPLEMENTED functions
---------------------------------------------------------------------

function addon:OnEnable()
	if not hasGatherMate() or not GatherMate:IsEnabled() then
		Disable()
		return
	end

	self:GetBridges():DeactivateBridge(kModule)

	self:RegisterCallback("OnNodeAdded", "onNodeAdded")
	self:RegisterCallback("OnNodeDeleted", "onNodeDeleted")
	-- Callbacks sent by GatherMate
	self:RegisterMessage("GatherMateNodeAdded", "onGatherMateNodeAdded")
	self:RegisterMessage("GatherMateNodeDeleted", "onGatherMateNodeDeleted")
	-- Hook to prevent resending incoming nodes
	local GatherMate_Sharing = GatherMate:GetModule("Sharing", true)
	if GatherMate_Sharing then
		self.GatherMate_SharingOnMessage = GatherMate_Sharing.OnMessage
		self:RawHook(GatherMate_Sharing, "OnMessage", "onGatherMate_SharingOnMessage")
	end
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

	local getZone = addon.utils.GetGatherMateZoneFromZone
	local getNodeType = addon.utils.GetGatherMateNameFromType
	local getNode = addon.utils.GetGatherMateNodeFromNodeAndType
	
	function addon:onNodeAdded(_, in_source, in_zone, in_x, in_y, in_nodeType, in_node)
		if in_source and not self:IsProcessing(kModule) then
			local zone = getZone(in_zone)
			local nodeType = getNodeType(in_nodeType)
			local node = getNode(in_nodeType, in_node)
			if not zone then
				--[===[@alpha@
				self:Print("Unknown zone:", in_zone)
				--@end-alpha@]===]
			elseif not nodeType then
				--[===[@alpha@
				self:Print("Unknown type:", in_nodeType)
				--@end-alpha@]===]
			elseif not node then
				--[===[@alpha@
				self:Print("Unknown node:", in_nodeType, in_node)
				--@end-alpha@]===]
			else
				GatherMate:InjectNode(zone, GatherMate:getID(in_x, in_y), nodeType, node)
			end
		end
	end

	function addon:onNodeDeleted(_, in_source, in_zone, in_x, in_y, in_nodeType)
		if in_source and not self:IsProcessing(kModule) then
			local zone = getZone(in_zone)
			local nodeType = getNodeType(in_nodeType)
			-- We can't delete anything that we don't know about
			if zone and nodeType then
				GatherMate:DeleteNode(zoneID, GatherMate:getID(in_x, in_y), nodeType)
			end
		end
	end
end

do
---------------------------------------------------------------------
-- GatherMate Handlers
---------------------------------------------------------------------

	local decodeAddFromGatherMate -- forward declaration
	local decodeDeleteFromGatherMate -- forward declaration
	do
		local getZone = addon.utils.GetZoneFromGatherMateZone
		local getNodeType = addon.utils.GetTypeFromGatherMateName
		local getNode = addon.utils.GetNodeFromGatherMateNodeAndType

		-- v1.0.10 added GatherMate.GetZoneID
		local getZoneID = GatherMate.GetZoneID or function(self, in_zone) return self.zoneData[ in_zone ][ 3 ] end

		function decodeAddFromGatherMate(self, in_zone, in_nodeType, in_coords, in_node)
			local zone = getZone(getZoneID(GatherMate, in_zone))
			local nodeType = getNodeType(in_nodeType)
			local x, y = GatherMate:getXY(in_coords)
			local node = getNode(nodeType, GatherMate:GetIDForNode(in_nodeType, in_node))
			-- TODO: Wait for looting to finish and send out the loot too
			local result = self:AddNode(nil, zone, x, y, nodeType, node)
			if not self.IsResultOk(result) then
				-- TODO: Error handling
			end
		end

		function decodeDeleteFromGatherMate(self, in_zone, in_nodeType, in_coords, in_node)
			local zone = getZone(getZoneID(GatherMate, in_zone))
			local nodeType = getNodeType(in_nodeType)
			local x, y = GatherMate:getXY(in_coords)
			local node = getNode(nodeType, GatherMate:GetIDForNode(in_nodeType, in_node))
			-- Nothing to do if we failed to delete the node
			self:DeleteNode(nil, zone, x, y, nodeType, node)
		end
	end

	function addon:onGatherMateNodeAdded(_, ...)
		if self.GatherMate_Sharing then return end

		local result, msg = true

		if self:BeginProcessing(kModule) then
			result, msg = pcall(decodeAddFromGatherMate, self, ...)
			self:EndProcessing()
		end
		--[===[@alpha@
		if not result then
			self:Print("NodeAdded:", msg)
		end
		--@end-alpha@]===]
	end

	function addon:onGatherMateNodeDeleted(_, ...)
		if self.GatherMate_Sharing then return end

		local result, msg = true

		if self:BeginProcessing(kModule) then
			result, msg = pcall(decodeDeleteFromGatherMate, self, ...)
			self:EndProcessing()
		end
		--[===[@alpha@
		if not result then
			self:Print("NodeDeleted:", msg)
		end
		--@end-alpha@]===]
	end
end

---------------------------------------------------------------------
-- GatherMate_Sharing Hook
---------------------------------------------------------------------

function addon:onGatherMate_SharingOnMessage(...)
	self.GatherMate_Sharing = true
	self.GatherMate_SharingOnMessage(...)
	self.GatherMate_Sharing = false
end
