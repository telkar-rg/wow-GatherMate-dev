--[[-----------------------------------------------------------------

GatherTogether_MetaMap

Initial Creation Date: 2008/12/18
Description: MetaMap support module for GatherTogether

Author: lokicoyote
File Date: 2008-12-23T20:41:26Z
File Revision: 64
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

assert(LibStub)

local function hasMetaMap()
	return "function" == type(TRK_AddNode) and "table" == type(TRK_TrackerTable) and "table" == type(MetaMap_ZoneTable) and "function" == type(MetaMap_GetZoneTableEntry)
end

if not hasMetaMap() then
	return
end

local kAddon = "GatherTogether"
local kModule = "MetaMap"

-- Cache often used global functions
local pairs, pcall, rawset, tonumber = _G.pairs, _G.pcall, _G.rawset, _G.tonumber

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local addon = LibStub("AceAddon-3.0"):GetAddon(kAddon):GetModule("Support"):NewModule(kModule, "AceConsole-3.0", "AceHook-3.0")

---------------------------------------------------------------------
-- AceAddon IMPLEMENTED functions
---------------------------------------------------------------------

function addon:OnEnable()
	if not hasMetaMap() then
		Disable()
		return
	end

	-- self:GetBridges():DeactivateBridge(kModule)

	self:RegisterCallback("OnNodeAdded", "onNodeAdded")
	self:Hook("TRK_AddNode", "onTRK_AddNode")
end

function addon:OnDisable()
	self:UnregisterAllCallbacks()
	-- Embeds handle unregistering messages
	-- self:GetBridges():ActivateBridge(kModule)
end

do
---------------------------------------------------------------------
-- GatherTogether Handlers
---------------------------------------------------------------------

	local getZone = addon.utils.GetMetaMapZoneFromZone
	local getNode = addon.utils.GetMetaMapNodeFromNodeAndType

	local getZoneName = function(in_id) return MetaMap_ZoneTable[ in_id ][ MetaMap_Locale ] end
	local getNodeName = function(in_id) return TRK_TrackerTable[ in_id ][ MetaMap_Locale ] end
	
	function addon:onNodeAdded(_, in_source, in_zone, in_x, in_y, in_nodeType, in_node)
		if in_source and not self:IsProcessing(kModule) then
			local zone = getZoneName(getZone(in_zone))
			local node = getNodeName(getNode(in_nodeType, in_node))
			-- TODO Use the loot (when implemented to update the count)
			TRK_AddNode(zone, node, in_source or self.var.me, in_x, in_y, 0, true) -- We skip counting since we didn't collect it
		end
	end
end

do
---------------------------------------------------------------------
-- TRK_AddNode Hook
---------------------------------------------------------------------

	local decodeAddFromMetaMap -- forward declaration
	do
		local getZone = addon.utils.GetZoneFromMetaMapZone
		local getNodeType = addon.utils.GetTypeFromMetaMapNode
		local getNode = addon.utils.GetNodeFromMetaMapNodeAndType

		local getZoneID -- forward declaration
		do
			local kMetaMapZoneToID = setmetatable({}, {
					__index = function(t, k)
						local _, id = MetaMap_GetZoneTableEntry(k)
						rawset(t, k, id)
						return id
					end
				})

			function getZoneID(in_name)
				return kMetaMapZoneToID[ in_name ]
			end
		end

		local getNodeID -- forward declaration
		do
			local kMetaMapNameToID = {}
			for id, v in pairs(TRK_TrackerTable) do
				if v.en then
					kMetaMapNameToID[ v.en ] = id
					kMetaMapNameToID[ v.de or v.en ] = id
					kMetaMapNameToID[ v.fr or v.en ] = id
				end
			end

			setmetatable(kMetaMapNameToID, {
					__index = function(t, k)
						for id, v in pairs(TRK_TrackerTable) do
							if k == v[ MetaMap_Locale ] then
								rawset(t, k, id)
								return id
							end
						end
					end
				})

			function getNodeID(in_name)
				return kMetaMapNameToID[ in_name ]
			end
		end

		function decodeAddFromMetaMap(self, in_zone, in_name, in_creator, in_x, in_y, in_count, in_skipCount)
			local zone = getZone(getZoneID(in_zone))
			local id = getNodeID(in_name)
			local nodeType = getNodeType(id)
			local node = getNode(nodeType, id)
			-- TODO: Use in_count and in_skipCount to build loot information
			local result = self:AddNode(in_creator, zone, in_x, in_y, nodeType, node)
			if not self.IsResultOk(result) then
				-- TODO: Error handling
			end
		end
	end

	function addon:onTRK_AddNode(...)
		local result, msg = true

		if self:BeginProcessing(kModule) then
			result, msg = pcall(decodeAddFromMetaMap, self, ...)
			self:EndProcessing()
		end
		--[===[@alpha@
		if not result then
			self:Print("NodeAdded:", msg)
		end
		--@end-alpha@]===]
	end
end
