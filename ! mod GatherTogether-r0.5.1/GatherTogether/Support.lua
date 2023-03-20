--[[-----------------------------------------------------------------

Title: GatherTogether Support Template
Initial Creation Date: 2008/12/05

Author: lokicoyote
File Date: 2008-12-23T21:30:08Z
File Revision: 66
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local kAddon = "GatherTogether"
local kModule = "Support"

-- Cache often used global functions
local rawset, setmetatable = _G.rawset, _G.setmetatable

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local support = LibStub("AceAddon-3.0"):GetAddon(kAddon):NewModule("Support")
local L = LibStub("AceLocale-3.0"):GetLocale(kAddon, true)

---------------------------------------------------------------------
-- Module prototype
---------------------------------------------------------------------

local support_prototype = {}
do
	local supoort_base = {
		  "kResults"
		, "kResultsIndex"
		-- Add / Delete
		, "IsResultOk"
		, "ComputeNodeKey"
		, "AddNode"
		, "DeleteNode"
		-- Send all
		, "Broadcast"
		-- Ensure that we don't reenter
		, "BeginProcessing"
		, "IsProcessing"
		, "EndProcessing"
	}

	for _, key in ipairs(supoort_base) do
		support_prototype[ key ] = support.addon[ key ]
	end

	local support_var -- forward declaration
	do
		local support_addon = {
			-- variables
			  db = true
			, var = true
			-- Register callbacks
			, RegisterCallback = true
			, UnregisterAllCallbacks = true
		}

		function support_var(t, k)
			local var
			if support_addon[ k ] then
				var = support.addon[ k ]
			end
			
			if var then
				-- Only add these if they have been added to the addon
				rawset(t, k, var)
			end
			return var
		end
	end

	setmetatable(support_prototype, { __index = support_var })
end

function support_prototype:GetBridges(in_name)
	return support.addon:GetModule("Bridge")
end

---------------------------------------------------------------------
-- AceAddon IMPLEMENTED functions
---------------------------------------------------------------------

-- Needs to run inline instead of at OnInitialize
support:SetDefaultModulePrototype(support_prototype)

function support:OnModuleCreated(in_module)
	in_module.utils = self.addon.utils[ in_module:GetName() ]
	self.options = nil
end

---------------------------------------------------------------------
-- GatherTogether module functions
---------------------------------------------------------------------

function support:GetDefaults()
	return { supports = { ["*"] = { enabled = true } } }
end

if L then
	local kModOptions = {
		type = "group"
		, args = {
			enable = {
				type = "toggle"
				, name = L["supports.enable"]
				, desc = L["supports.enable-desc"]
				, set = function(info, in_state) support:SetSupportEnabled(info.handler:GetName(), in_state) end
				, get = function(info) return support:GetSupportEnabled(info.handler:GetName()) end
			}
		}
	}

	function support:GetOptions()
		local options = self.options
		if not options then
			local args = {
				description = {
					type = "description"
					, order = 0
					, name = L["supports.description"]
				}
			}
			options = {
				support = {
					type = "group"
					, handler = self
					, name = L["supports"]
					, desc = L["supports-desc"]
					, childGroups = "select"
					, args = args
				}
			}
			for name, mod in self:IterateModules() do
				local plugins = {}
				args[ name ] = setmetatable({
						name = L[ "supports.options." .. name ]
						, desc = L[ "supports.options." .. name .. "-desc"]
						, handler = mod
						, plugins = plugins
					}, { __index = kModOptions })
				if mod.GetOptions then
					args[ name ].plugins = mod:GetOptions()
				end
			end
			self.options = options
		end
		return options
	end
end

function support:LoadProfile()
	for name, mod in self:IterateModules() do
		self:SetSupportEnabled(name, self:GetSupportEnabled(name))
		if mod.LoadProfile then
			mod:LoadProfile()
		end
	end
end

---------------------------------------------------------------------
-- Setter / Getter functions
---------------------------------------------------------------------

function support:SetSupportEnabled(in_name, in_state)
	local mod = self:GetModule(in_name)
	if mod then
		mod[ in_state and "Enable" or "Disable" ](mod)
		self.addon:GetModuleConfig(kModule).supports[ in_name ].enabled = in_state or false
	end
end

function support:GetSupportEnabled(in_name)
	return self.addon:GetModuleConfig(kModule).supports[ in_name ].enabled
end

