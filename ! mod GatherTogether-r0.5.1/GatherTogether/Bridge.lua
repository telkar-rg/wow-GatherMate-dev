--[[-----------------------------------------------------------------

Title: GatherTogether Bridge Template
Initial Creation Date: 2008/12/04

Author: lokicoyote
File Date: 2008-12-23T21:29:51Z
File Revision: 65
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local kAddon = "GatherTogether"
local kModule = "Bridge"

-- Cache often used global functions
local rawset, setmetatable = _G.rawset, _G.setmetatable
local StaticPopupDialogs, StaticPopup_Show = _G.StaticPopupDialogs, _G.StaticPopup_Show

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local bridge = LibStub("AceAddon-3.0"):GetAddon(kAddon):NewModule(kModule)
local L = LibStub("AceLocale-3.0"):GetLocale(kAddon, true)

local kPopupConfirmDisable = tostring(bridge) .. "ConfirmDisable"

if L then
	StaticPopupDialogs[ kPopupConfirmDisable ] = {
		text = L["popup.bridge.ConfirmDisable"](L[ kAddon ])
		, button1 = L["Yes"]
		, button2 = L["No"]
		, whileDead = 1
		, timeout = 0
		, showAlert = 1
	
		, OnAccept = function() bridge.addon:Disable() end
	}
end

---------------------------------------------------------------------
-- Module prototype
---------------------------------------------------------------------

local bridge_prototype = {}
do
	local bridge_base = {
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

	for _, key in ipairs(bridge_base) do
		bridge_prototype[ key ] = bridge.addon[ key ]
	end

	local bridge_var -- forward declaration
	do
		local bridge_addon = {
			-- variables
			  db = true
			, var = true
			-- Register callbacks
			, RegisterCallback = true
			, UnregisterAllCallbacks = true
		}

		function bridge_var(t, k)
			local var
			if bridge_addon[ k ] then
				var = bridge.addon[ k ]
			end
			
			if var then
				-- Only add these if they have been added to the addon
				rawset(t, k, var)
			end
			return var
		end
	end

	setmetatable(bridge_prototype, { __index = bridge_var })
end

---------------------------------------------------------------------
-- AceAddon IMPLEMENTED function
---------------------------------------------------------------------

-- Needs to run inline instead of at OnInitialize
bridge:SetDefaultModulePrototype(bridge_prototype)
bridge.deactivated = {}

function bridge:OnModuleCreated(in_module)
	in_module.utils = self.addon.utils[ in_module:GetName() ]
	self.options = nil
	if self.module_list then
		self.module_list = strjoin(",", self.module_list, in_module:GetName())
	else
		self.module_list = in_module:GetName()
	end
end

---------------------------------------------------------------------
-- GatherTogether module functions
---------------------------------------------------------------------

function bridge:GetDefaults()
	return { bridges = { ["*"] = { enabled = true } }, deactivated = "" }
end

if L then
	local kModOptions = {
		type = "group"
		, disabled = function(info) return bridge:IsDeactivated(info.handler:GetName()) end
		, args = {
			enable = {
				type = "toggle"
				, name = L["bridges.enable"]
				, desc = L["bridges.enable-desc"]
				, set = function(info, in_state) bridge:SetBridgeEnabled(info.handler:GetName(), in_state) end
				, get = function(info) return bridge:GetBridgeEnabled(info.handler:GetName()) end
			}, deactivated = {
				type = "description"
				, order = function(info) return bridge:IsDeactivated(info.handler:GetName()) and 0 or -1 end
				, name = function(info) return bridge:IsDeactivated(info.handler:GetName()) and L["bridges.deactivated"] or "" end
			}
		}
	}

	function bridge:GetOptions()
		local options = self.options
		if not options then
			local args = {
				description = {
					type = "description"
					, order = 0
					, name = L["bridges.description"]
				}
			}
			options = {
				bridge = {
					type = "group"
					, handler = self
					, name = L["bridges"]
					, desc = L["bridges-desc"]
					, childGroups = "select"
					, args = args
				}
			}
			for name, mod in self:IterateModules() do
				local plugins = {}
				args[ name ] = setmetatable({
						name = L[ "bridges.options." .. name ]
						, desc = L[ "bridges.options." .. name .. "-desc"]
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

function bridge:LoadProfile()
	for name, mod in self:IterateModules() do
		self:SetBridgeEnabled(name, self:GetBridgeEnabled(name))
		if mod.LoadProfile then
			mod:LoadProfile()
		end
	end
end

---------------------------------------------------------------------
-- Setter / Getter functions
---------------------------------------------------------------------

function bridge:SetBridgeEnabled(in_name, in_state)
	local mod = self:GetModule(in_name)
	if mod then
		mod[ (not self:IsDeactivated(in_name) and in_state) and "Enable" or "Disable" ](mod)
		self.addon:GetModuleConfig(kModule).bridges[ in_name ].enabled = in_state or false
	end
end

function bridge:GetBridgeEnabled(in_name)
	return self.addon:GetModuleConfig(kModule).bridges[ in_name ].enabled
end

---------------------------------------------------------------------
-- Other functions
---------------------------------------------------------------------

function bridge:ActivateBridge(in_name)
	self.deactivated[ in_name ] = nil
	self:SetBridgeEnabled(in_name, self:GetBridgeEnabled(in_name))
end

function bridge:IsDeactivated(in_name)
	return self.deactivated[ in_name ]
end

function bridge:DeactivateBridge(in_name)
	local mod = self:GetModule(in_name)
	if mod then
		self.deactivated[ in_name ] = true
		mod:Disable()

		self:CheckActiveBridges()
	end
end

function bridge:HasActiveBridges()
	for name in self:IterateModules() do
		if not self:IsDeactivated(name) then
			return true
		end
	end
	return false
end

function bridge:CheckActiveBridges()
	if not self:HasActiveBridges() then
		if StaticPopupDialogs[ kPopupConfirmDisable ] then
			if self.addon:GetModuleConfig(kModule).deactivated ~= (self.module_list or "") then
				self.addon:GetModuleConfig(kModule).deactivated = self.module_list or ""
				StaticPopup_Show(kPopupConfirmDisable)
			end
		end
	end
end
