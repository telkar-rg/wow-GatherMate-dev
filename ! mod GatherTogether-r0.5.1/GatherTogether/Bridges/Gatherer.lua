--[[-----------------------------------------------------------------

Title: GatherMate bridge for Gatherer
Initial Creation Date: 2008/12/02

Author: lokicoyote
File Date: 2008-12-23T12:13:04Z
File Revision: 63
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local kAddon = "GatherTogether"
local kBridge = "Gatherer"

-- Cache often used global functions
local pcall, tonumber = _G.pcall, _G.tonumber
local strjoin, strsplit = _G.strjoin, _G.strsplit

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local bridge = LibStub("AceAddon-3.0"):GetAddon(kAddon):GetModule("Bridge"):NewModule(kBridge, "AceConsole-3.0", "AceComm-3.0")

---------------------------------------------------------------------
-- Constant values
---------------------------------------------------------------------

local kCommGathererNode = "GathX"
local kCommGathererGeneral = "Gatherer"

local kGathererVersion = "3.1.8"

---------------------------------------------------------------------
-- AceAddon IMPLEMENTED functions
---------------------------------------------------------------------

function bridge:OnInitialize()
	self.accepting = {}
end

function bridge:OnEnable()
	-- Internal messages
	self:RegisterCallback("OnNodeAdded", "onNodeAdded")
	-- Comm sent by Gatherer
	self:RegisterComm(kCommGathererNode, "onGathererNodeMessage")
	self:RegisterComm(kCommGathererGeneral, "onGathererGeneralMessage")
end

function bridge:OnDisable()
	self:UnregisterAllCallbacks()
end

do
---------------------------------------------------------------------
-- GatherTogether Handlers
---------------------------------------------------------------------

	-- utils does a lookup based on GetName
	local getObjectID = bridge.utils.GetObjectIDFromNodeAndType
	local getContinent = bridge.utils.GetZoneContinent
	local getZone = bridge.utils.GetGathererZoneFromZone

	function bridge:onNodeAdded(_, in_source, in_zone, in_x, in_y, in_nodeType, in_node, in_loot, in_note)
		if not self:IsProcessing(kBridge) then
			local objectID = getObjectID(in_nodeType, in_node)
			local continent = getContinent(in_zone)
			local zone = getZone(in_zone)
			if not objectID then
				--[===[@alpha@
				self:Print("Unknown object:", in_node)
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
				-- TODO: Use in_loot
				self:Broadcast(kCommGathererNode, strjoin(";", objectID, continent, zone, in_x, in_y, 0))
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
		-- utils does a lookup based on GetName
		local getZone = bridge.utils.GetZoneFromGathererZone
		local getNodeType = bridge.utils.GetTypeFromObjectID
		local getNode = bridge.utils.GetNodeFromObjectID

		function decodeGatherer(self, in_sender, in_objectID, in_continent, in_zone, in_x, in_y, in_loot)
			local zone = getZone(in_zone)
			local nodeType = getNodeType(tonumber(in_objectID))
			local node = getNode(tonumber(in_objectID))
			-- TODO: Decode in_loot
			local result = self:AddNode(in_sender, zone, tonumber(in_x), tonumber(in_y), nodeType, node)
			if not self.IsResultOk(result) then
				-- TODO: Try adding new types
				-- TODO: Try adding new node types
				-- TODO: Use a loop?
			end
		end
	end

	-- See http://svn.norganna.org/gatherer/trunk/Gatherer/GatherCommm.lua
	function bridge:onGathererNodeMessage(in_prefix, in_message, in_distribution, in_sender)
		if in_prefix ~= kCommGathererNode then return end
		if in_sender == self.var.me then return end

		local result, msg = true

		if self:BeginProcessing(kBridge) then
			result, msg = pcall(decodeGatherer, self, in_sender, strsplit(";", in_message))
			self:EndProcessing()
		end
		--[===[@alpha@
		if not result then
			self:Print("Error:", in_message, ":", msg)
		end
		--@end-alpha@]===]
	end
end

-- This allows us to receive sends from Gatherer, but without UI
function bridge:onGathererGeneralMessage(in_prefix, in_message, in_distribution, in_sender)
	if in_prefix ~= kCommGathererGeneral then return end
	if in_sender == self.var.me then return end

	--[===[@alpha@
	self:Print(in_message, "(from", in_sender, "via", in_distribution, ")")
	--@end-alpha@]===]

	local cmd, a, b, c, d = strsplit(":", in_message)

	if cmd == "VER" then
		self:SendCommMessage(kCommGathererGeneral, "VER:" .. kGathererVersion, in_distribution)
	elseif cmd == "SENDNOTES" then
		-- NOTE: We are not implementing an interface currently.
		-- Otherwise check if we want to receive just now, else
		-- respond with CLOSED
		if a == "OFFER" then -- someone has offered some nodes
			if 0 < b then
				-- NOTE: We are not implementing an interface currently.
				-- If using an interface:
				-- * return BUSY if an offer has already been made
				-- * return PROMPT and later ACCEPT, REJECT or TIMEOUT and finally ACCEPTED
				self:SendCommMessage(kCommGathererGeneral, "SENDNOTES:ACCEPT", "WHISPER", in_sender)
				self.accepting[ in_sender:lower() ] = true
				self:SendCommMessage(kCommGathererGeneral, "SENDNOTES:ACCEPTED", "WHISPER", in_sender)
			end
		elseif a == "DONE" then -- transfer done
			if self.accepting[ in_sender:lower() ] then
				self.accepting[ in_sender:lower() ] = nil
				self:SendCommMessage(kCommGathererGeneral, "SENDNOTES:COMPLETE", "WHISPER", in_sender)
			end
		elseif a == "PAUSE" then -- transfer has been paused
			if self.accepting[ in_sender:lower() ] then -- but we want MOAR
				self:SendCommMessage(kCommGathererGeneral, "SENDNOTES:CONTINUE", "WHISPER", in_sender)
			end
		--elseif a == "CONTINUE" then -- transfer has been continued
		--elseif a == "ABORTED" then -- transfer has been aborted
		--elseif a == "COMPLETE" then -- transfer has been completed
		else
			--[===[@alpha@
			self:Print("Unknown command", a)
			--@end-alpha@]===]
		end
		
		--if a == "PROMPT" or a == "ACCEPT" or a == "REJECT" or a == "BUSY" or a == "TIMEOUT" then
			-- TODO: the interface know what happened
		--end
	end
end
