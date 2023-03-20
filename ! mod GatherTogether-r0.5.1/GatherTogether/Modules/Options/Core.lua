--[[-----------------------------------------------------------------

GatherTogether Options defintions

This file adds the setupOptions function to the addon which gets
called during OnInitialization.

Author: lokicoyote
File Date: 2008-12-15T23:53:29Z
File Revision: 25
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

local kAddon = "GatherTogether"
local kModule = "Options"

-- Cache often used global functions
local ipairs, next, pairs, setmetatable, type = _G.ipairs, _G.next, _G.pairs, _G.setmetatable, _G.type

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local addon = LibStub("AceAddon-3.0"):GetAddon(kAddon):NewModule(kModule, "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(kAddon, true)

---------------------------------------------------------------------
-- Local constants
---------------------------------------------------------------------

local kSlashCommand = "gt"

---------------------------------------------------------------------
-- getBaseOptions functions
---------------------------------------------------------------------

local kBaseOptions -- forward declaration
local kBlacklistOptions -- forward declaration
local kAdvancedOptions -- forward declaration
do
	local function setOption(info, ...)
		info.handler.addon[ "Set" .. info.arg ](info.handler.addon, ...)
	end

	local function getOption(info, ...)
		return info.handler.addon[ "Get" .. info.arg ](info.handler.addon, ...)
	end

	local function setOptionMessageState(info, ...)
		info.handler.addon:SetMessageState(info.arg, ...)
	end
	
	local function getOptionMessageState(info, ...)
		return info.handler.addon:GetMessageState(info.arg, ...)
	end

	local function getBroadcastMethods(info)
		local methods = info.handler.cache.methods
		if not methods then
			methods = {}
			for _, v in ipairs(info.handler.addon:GetBroadcastMethods()) do
				methods[ v ] = L[ v ]
			end
			info.handler.cache.methods = methods
		end
		return methods
	end

	local function setOptionBroadcastTarget(info, ...)
		info.handler.addon:SetBroadcastTarget(info.arg, ...)
	end

	local function getOptionBroadcastTarget(info, ...)
		return info.handler.addon:GetBroadcastTarget(info.arg, ...)
	end

	kBaseOptions = {
		type = "group"
		, name = L[ kAddon ]
		, set = setOption
		, get = getOption
		, args = {
			enabled = {
				type = "toggle"
				, order = 1
				, name = L["enabled"]
				, desc = L["enabled-desc"]
				, width = "full"
				, set = function(info, in_state) info.handler.addon[ in_state and "Enable" or "Disable" ](info.handler.addon) end
				, get = function(info) return info.handler.addon:IsEnabled() end
			}, add = {
				type = "toggle"
				, order = 2
				, name = L["add"]
				, desc = L["add-desc"]
				, width = "half"
				, set = setOptionMessageState
				, get = getOptionMessageState
				, arg = "add"
			}, delete = {
				type = "toggle"
				, order = 3
				, name = L["delete"]
				, desc = L["delete-desc"]
				, width = "half"
				, set = setOptionMessageState
				, get = getOptionMessageState
				, arg = "delete"
			}, broadcast = {
				type = "group"
				, order = 10
				, guiInline = true
				, name = L["broadcast"]
				, desc = L["broadcast-desc"]
				, childGroups = "tab"
				, args = {
					list_gui = {
						type = "group"
						, order = 20
						, cmdHidden = true
						, name = L["broadcast.list"]
						, desc = L["broadcast.list-desc"]
						, args = {
							enabled = {
								type = "multiselect"
								, name = L["broadcast.enabled"]
								, desc = L["broadcast.enabled-desc"]
								, values = getBroadcastMethods
								, arg = "BroadcastEnabled"
								, width = "half"
							}, priority = {
								type = "input"
								, name = L["broadcast.priority"]
								, desc = L["broadcast.priority-desc"]
								, arg = "BroadcastPriority"
								--, control = "PriorityList"
								, width = "half"
								, multiline = true
							}
						}
					}, list = {
						type = "input"
						, order = 21
						, guiHidden = true
						, name = L["broadcast.list"]
						, desc = L["broadcast.list-desc"]
						, usage = L["broadcast.list-usage"]
						, arg = "BroadcastPriority"
					}, targets = {
						type = "group"
						, order = 30
						, name = L["broadcast.targets"]
						, desc = L["broadcast.targets-desc"]
						, set = setOptionBroadcastTarget
						, get = getOptionBroadcastTarget
						, args = {
							whisper = {
								type = "input"
								, order = 10
								, name = L["broadcast.targets.whisper"]
								, desc = L["broadcast.targets.whisper-desc"]
								, arg = "whisper"
							}
						}
					}
				}
			}
		}
	}

	local function setOptionBlacklist(info, ...)
		info.handler.addon:SetBlacklist(info.arg, ...)
	end

	local function getOptionBlacklist(info, ...)
		return info.handler.addon:GetBlacklist(info.arg, ...)
	end

	kBlacklistOptions = {
		type = "group"
		, name = L["blacklist"]
		, desc = L["blacklist-desc"]
		, set = setOptionBlacklist
		, get = getOptionBlacklist
		, args = {
			add = {
				type = "input"
				, multiline = true
				, name = L["blacklist.add"]
				, desc = L["blacklist.add-desc"]
				, usage = L["blacklist.add-usage"]
				, arg = "add"
			}, delete = {
				type = "input"
				, multiline = true
				, name = L["blacklist.delete"]
				, desc = L["blacklist.delete-desc"]
				, usage = L["blacklist.delete-usage"]
				, arg = "delete"
			}
		}
	}

	kAdvancedOptions = {
		type = "group"
		, name = L["advanced"]
		, desc = L["advanced-desc"]
		, set = setOption
		, get = getOption
		, args = {
			duplicate = {
				type = "group"
				, guiInline = true
				, name = L["advanced.duplicate"]
				, desc = L["advanced.duplicate-desc"]
				, args = {
					window = {
						type = "range"
						, name = L["advanced.duplicate.window"]
						, desc = L["advanced.duplicate.window-desc"]
						, arg = "DuplicateWindow"
						, min = 5
						, max = 200
						, step = 0.05
					}, buffer_length = {
						type = "range"
						, name = L["advanced.duplicate.buffer_length"]
						, desc = L["advanced.duplicate.buffer_length-desc"]
						, arg = "DuplicateBufferLength"
						, min = 10
						, max = 200
						, step = 1
					}, buffer_cycles = {
						type = "range"
						, name = L["advanced.duplicate.buffer_cycles"]
						, desc = L["advanced.duplicate.buffer_cycles-desc"]
						, arg = "DuplicateBufferCycles"
						, min = 1
						, max = 200
						, step = 1
					}
				}
			}
		}
	}
end

-- Description: Function to return the top level Ace3 config table for the command line
-- Expected result: Returns the top level Ace3 config table
-- Input: None
-- Output: Ace3 config table
local function getBaseOptions(self)
	local options = self.cache.base_options
	if not options then
		options = setmetatable({ handler = self }, { __index = kBaseOptions })
		self.cache.base_options = options
	end
	return options
end

local function getFullOptions(self)
	local options = self.cache.options
	if not options then
		options = setmetatable({ plugins = {} }, { __index = getBaseOptions(self) })
		-- Add plugins
		options.plugins[ "blacklist" ] = {
			blacklist = setmetatable({ handler = self }, { __index = kBlacklistOptions })
		}
		options.plugins[ "advanced" ] = {
			advanced = setmetatable({ handler = self }, { __index = kAdvancedOptions })
		}
		local AceDBOptions = LibStub:GetLibrary("AceDBOptions-3.0", true)
		if AceDBOptions then
			options.plugins[ "profile" ] = {
				profile = AceDBOptions:GetOptionsTable(self.addon.db)
			}
		end
		for name, mod in self.addon:IterateModules() do
			if type(mod.GetOptions) == "function" then
				options.plugins[ name ] = mod:GetOptions()
			end
		end
		self.cache.options = options
	end
	return options
end

local chatCommand -- forward declaration
do
	local AceConfigCmd, HasAceConfigDialog
	if LibStub:GetLibrary("AceConfig-3.0", true) then
		AceConfigCmd = LibStub:GetLibrary("AceConfigCmd-3.0", true)
		HasAceConfigDialog = LibStub:GetLibrary("AceConfigDialog-3.0", true) and true
	end

	local function chatCommandLineOnly(self, in_input)
		AceConfigCmd:HandleCommand(kSlashCommand, kAddon, in_input)
	end

	local function chatCommandGuiOnly(self, in_input)
		InterfaceOptionsFrame_OpenToCategory(self.options)
	end

	if HasAceConfigDialog then
		if AceConfigCmd then
			function addon:chatCommand(in_input)
				if in_input and in_input:trim() ~= "" then
					chatCommandLineOnly(self, in_input)
				else
					chatCommandGuiOnly(self, in_input)
				end
			end
		else
			addon.chatCommand = chatCommandGuiOnly
		end
	else
		if AceConfigCmd then
			addon.chatCommand = chatCommandLineOnly
		else
			function addon:chatCommand()
				error("Unable to process slash commands")
			end
		end
	end
end

---------------------------------------------------------------------
-- AceAddon IMPLEMENTED functions
---------------------------------------------------------------------

function addon:OnInitialize()
	self.cache = setmetatable({}, { __mode = "v" })

	local AceConfig = LibStub:GetLibrary("AceConfig-3.0", true)
	if not L or not AceConfig then
		return
	end
	
	self:RegisterChatCommand(kSlashCommand, "chatCommand")
	AceConfig:RegisterOptionsTable(kAddon, function(in_uiType) return ("cmd" == in_uiType and getFullOptions or getBaseOptions)(self) end, type(L["Slash-Commands"]) == "table" and L["Slash-Commands"])

	for k in pairs(getFullOptions(self).plugins) do
		AceConfig:RegisterOptionsTable(kAddon .. " " .. L[ k ], function() return select(2, next(getFullOptions(self).plugins[ k ])) end)
	end

	local AceConfigDialog = LibStub:GetLibrary("AceConfigDialog-3.0", true)
	if AceConfigDialog then
		self.options = AceConfigDialog:AddToBlizOptions(kAddon, L[ kAddon ])
		AceConfigDialog:AddToBlizOptions(kAddon .. " " .. L[ "blacklist" ], L[ "blacklist" ], L[ kAddon ])
		AceConfigDialog:AddToBlizOptions(kAddon .. " " .. L[ "advanced" ], L[ "advanced" ], L[ kAddon ])
		for name, mod in self.addon:IterateModules() do
			if type(mod.GetOptions) == "function" then
				AceConfigDialog:AddToBlizOptions(kAddon .. " " .. L[ name ], L[ name ], L[ kAddon ])
			end
		end
		AceConfigDialog:AddToBlizOptions(kAddon .. " " .. L[ "profile" ], L[ "profile" ], L[ kAddon ])
	end
end
