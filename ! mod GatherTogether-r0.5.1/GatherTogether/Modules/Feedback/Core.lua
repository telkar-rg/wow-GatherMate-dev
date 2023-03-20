--[[-----------------------------------------------------------------

Title: GatherTogether Feedback module
Initial Creation Date: 2008/12/07

Author: lokicoyote
File Date: 2008-12-21T07:48:26Z
File Revision: 56
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local kAddon = "GatherTogether"
local kModule = "Feedback"

-- Cache often used global functions

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local addon = LibStub("AceAddon-3.0"):GetAddon(kAddon):NewModule(kModule, "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(kAddon, true)

---------------------------------------------------------------------
-- Constant values
---------------------------------------------------------------------

---------------------------------------------------------------------
-- AceAddon IMPLMENTED functions
---------------------------------------------------------------------

function addon:OnEnable()
	-- Internal messages
	self.addon.RegisterCallback(self, "OnNodeAdded", "onNodeAdded")
	self.addon.RegisterCallback(self, "OnNodeDeleted", "onNodeDeleted")
end

function addon:OnDisable()
	self.addon.UnregisterAllCallbacks(self)
end

---------------------------------------------------------------------
-- GatherTogether Handlers
---------------------------------------------------------------------

function addon:onNodeAdded(_, in_source, in_zone, in_x, in_y, in_nodeType, in_node)
	self:Print(L["Added T / N to Z (X, Y) by W"](in_nodeType, in_node, in_zone, in_x, in_y, in_source))
end

function addon:onNodeDeleted(_, in_source, in_zone, in_x, in_y, in_nodeType)
	self:Print(L["Deleted T / N from Z (X, Y) by W"](in_nodeType, in_node, in_zone, in_x, in_y, in_source))
end

function addon:GetDefaults()
	return { ["enabled"] = true }
end

if L then
	local kOptions = {
		type = "group"
		, name = L[ kModule ]
		, desc = L[ kModule .. "-desc" ]
		, args = {
			enable = {
				type = "toggle"
				, name = L["enabled"]
				, desc = L["enabled-desc"]
				, set = function(info, in_state) info.handler:SetEnabled(in_state) end
				, get = function(info) return info.handler:GetEnabled() end
			}
		}
	}

	function addon:GetOptions()
		local options = self.options
		if not options then
			options = { feedback = setmetatable({ handler = self }, { __index = kOptions }) }
			self.options = options
		end
		return options
	end
end

function addon:LoadProfile()
	self:SetEnabled(self:GetEnabled())
end

---------------------------------------------------------------------
-- Setter / Getter functions
---------------------------------------------------------------------

function addon:SetEnabled(in_state)
	self[ in_state and "Enable" or "Disable" ](self)
	self.addon:GetModuleConfig(kModule).enabled = in_state
end

function addon:GetEnabled()
	return self.addon:GetModuleConfig(kModule).enabled
end
