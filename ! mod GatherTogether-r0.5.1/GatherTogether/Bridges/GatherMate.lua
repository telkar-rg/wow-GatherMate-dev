--[[-----------------------------------------------------------------

Title: GatherTogether bridge for GatherMate 
Initial Creation Date: 2008/12/04

Author: lokicoyote
File Date: 2008-12-15T23:53:29Z
File Revision: 25
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local kAddon = "GatherTogether"
local kBridge = "GatherMate"

-- Cache often used global functions
local pcall, tonumber = _G.pcall, _G.tonumber
local strjoin, strsplit = _G.strjoin, _G.strsplit
local floor = _G.math.floor

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local bridge = LibStub("AceAddon-3.0"):GetAddon(kAddon):GetModule("Bridge"):NewModule(kBridge, "AceConsole-3.0", "AceComm-3.0")

---------------------------------------------------------------------
-- Constant values
---------------------------------------------------------------------

local kCommGatherMate_Sharing = "GMSD"

---------------------------------------------------------------------
-- AceAddon IMPLMENTED functions
---------------------------------------------------------------------

function bridge:OnEnable()
	-- Internal messages
	self:RegisterCallback("OnNodeAdded", "onNodeAdded")
	self:RegisterCallback("OnNodeDeleted", "onNodeDeleted")
	-- Comm sent by GatherMate
	self:RegisterComm(kCommGatherMate_Sharing, "onGatherMate_SharingMessage")
end

function bridge:OnDisable()
	self:UnregisterAllCallbacks()
end

do
---------------------------------------------------------------------
-- GatherTogether Handlers
---------------------------------------------------------------------

	local getZone = bridge.utils.GetGatherMateZoneFromZone
	local getNodeType = bridge.utils.GetSharingTypeFromType
	local getNode = bridge.utils.GetGatherMateNodeFromNodeAndType

	-- See GatherMate/GatherMate.lua : getID
	local function getCoord(in_x, in_y)
		return floor(in_x * 10000 + 0.5) * 10000 + floor(in_y * 10000 + 0.5)
	end

	function bridge:onNodeAdded(_, in_source, in_zone, in_x, in_y, in_nodeType, in_node)
		if not self:IsProcessing(kBridge) then
			local zone = getZone(in_zone)
			local nodeType = getNodeType(in_nodeType)
			local coord = getCoord(in_x, in_y)
			local node = getNode(in_nodeType, in_node)
			if not zone then
				--[===[@alpha@
				self:Print("Unknown zone:", in_zone)
				--@end-alpha@]===]
			elseif not nodeType then
				--[===[@alpha@
				self:Print("Unknown nodeType:", in_nodeType)
				--@end-alpha@]===]
			elseif not node then
				--[===[@alpha@
				self:Print("Unknown node:", in_nodeType, in_node)
				--@end-alpha@]===]
			else
				self:Broadcast(kCommGatherMate_Sharing, strjoin(":", "A", zone, nodeType, coord, node))
			end
		end
	end

	function bridge:onNodeDeleted(_, in_source, in_zone, in_x, in_y, in_nodeType)
		if not self:IsProcessing(kBridge) then
			local zone = getZone(in_zone)
			local nodeType = getNodeType(in_nodeType)
			local coord = getCoord(in_x, in_y)
			if not zone then
				--[===[@alpha@
				self:Print("Unknown zone:", in_zone)
				--@end-alpha@]===]
			elseif not nodeType then
				--[===[@alpha@
				self:Print("Unknown nodeType:", in_nodeType)
				--@end-alpha@]===]
			else
				self:Broadcast(kCommGatherMate_Sharing, strjoin(":", "D", zone, nodeType, coord))
			end
		end
	end
end

do
---------------------------------------------------------------------
-- GatherMate_Sharing Handler
---------------------------------------------------------------------

	local decodeGatherMate_Sharing -- forward declaration
	do
		-- utils does a lookup based on GetName
		local getZone = bridge.utils.GetZoneFromGatherMateZone
		local getNodeType = bridge.utils.GetTypeFromSharingType
		local getNode = bridge.utils.GetNodeFromGatherMateNodeAndType

		-- See GatherMate/GatherMate.lua : getXY
		local function getXY(in_coord)
			return floor(in_coord / 10000) / 10000, (in_coord % 10000) / 10000
		end

		-- Decode values coming from GatherMate_Sharing
		function decodeGatherMate_Sharing(self, in_sender, in_cmd, in_zone, in_nodeType, in_coord, in_node)
			local zone = getZone(tonumber(in_zone))
			local x, y = getXY(tonumber(in_coord))
			local nodeType = getNodeType(tonumber(in_nodeType))

			if "A" == in_cmd then
				local node = getNode(nodeType, tonumber(in_node))
				local result = self:AddNode(in_sender, zone, x, y, nodeType, node)
				if not self.IsResultOk(result) then
					-- TODO: Try adding new types
					-- TODO: Try adding new node types
					-- TODO: Use a loop?
				end
			elseif "D" == in_cmd then
				self:DeleteNode(in_sender, zone, x, y, nodeType)
				-- We can't delete something that doesn't exist, so ignore result
			end
		end
	end

	-- See GatherMate_Sharing/GatherMate_Sharing.lua
	function bridge:onGatherMate_SharingMessage(in_prefix, in_message, in_distribution, in_sender)
		if in_prefix ~= kCommGatherMate_Sharing then return end
		if in_sender == self.var.me then return end

		local result, msg = true

		if self:BeginProcessing(kBridge) then
			result, msg = pcall(decodeGatherMate_Sharing, self, in_sender, strsplit(":", in_message))
			self:EndProcessing()
		end
		--[===[@alpha@
		if not result then
			self:Print("Error:", in_message, ":", msg)
		end
		--@end-alpha@]===]
	end
end
