--[[-----------------------------------------------------------------

Title: GatherTogether bridge for GatherTogether 
Initial Creation Date: 2008/12/07

Author: lokicoyote
File Date: 2008-12-15T23:53:29Z
File Revision: 25
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local kAddon = "GatherTogether"
local kBridge = "GatherTogether"

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

local kCommGatherTogetherSharing = "GatherTogether"

---------------------------------------------------------------------
-- AceAddon IMPLMENTED functions
---------------------------------------------------------------------

function bridge:OnEnable()
	-- Internal messages
	self:RegisterCallback("OnNodeAdded", "onNodeAdded")
	self:RegisterCallback("OnNodeDeleted", "onNodeDeleted")
	-- Comm sent by GatherMate
	self:RegisterComm(kCommGatherTogetherSharing, "onGatherTogetherSharingMessage")
end

function bridge:OnDisable()
	self:UnregisterAllCallbacks()
end

---------------------------------------------------------------------
-- GatherTogether Handlers
---------------------------------------------------------------------

function bridge:onNodeAdded(_, in_source, in_zone, in_x, in_y, in_nodeType, in_node)
	if not self:IsProcessing(kBridge) then
		self:Broadcast(kCommGatherTogetherSharing, strjoin(":", "A", in_zone, in_x, in_y, in_nodeType, in_node))
	end
end

function bridge:onNodeDeleted(_, in_source, in_zone, in_x, in_y, in_nodeType)
	if not self:IsProcessing(kBridge) then
		self:Broadcast(kCommGatherTogetherSharing, strjoin(":", "D", in_zone, in_x, in_y, in_nodeType))
	end
end

do
---------------------------------------------------------------------
-- GatherMate_Sharing Handler
---------------------------------------------------------------------

	local decodeGatherMate_Sharing -- forward declaration
	do
		-- Decode values coming from ourself
		function decodeGatherMate_Sharing(self, in_sender, in_cmd, in_zone, in_x, in_y, in_nodeType, in_node)
			local zone = tonumber(in_zone)
			local x = tonumber(in_x)
			local y = tonumber(in_y)
			local nodeType = tonumber(in_nodeType)
			if "A" == in_cmd then
				local node = tonumber(in_node)
				local result = self:AddNode(in_sender, zone, x, y, nodeType, node)
				if not self.IsResultOk(result) then
					-- TODO: Error handling
				end
			elseif "D" == in_cmd then
				self:DeleteNode(in_sender, zone, x, y, nodeType)
			end
		end
	end

	-- See GatherMate_Sharing/GatherMate_Sharing.lua
	function bridge:onGatherTogetherSharingMessage(in_prefix, in_message, in_distribution, in_sender)
		if in_prefix ~= kCommGatherTogetherSharing then return end
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
