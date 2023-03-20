--[[-----------------------------------------------------------------

Title: GatherMate_SharingGatherer
Initial Creation Date: 2008/12/02

Author: lokicoyote
File Date: 2008-12-22T19:52:43Z
File Revision: 59
Project Revision: 66
Project Version: r0.5.1

--]]-----------------------------------------------------------------

assert(LibStub)

local kAddon = "GatherTogether"

GatherTogether = LibStub("AceAddon-3.0"):NewAddon(kAddon, "AceConsole-3.0")

-- Cache often used global functions
local pairs = _G.pairs
local floor = _G.math.floor
local GetFriendInfo = _G.GetFriendInfo
local GetNumFriends = _G.GetNumFriends
local GetNumPartyMembers = _G.GetNumPartyMembers
local GetNumRaidMembers = _G.GetNumRaidMembers
local IsInGuild = _G.IsInGuild

---------------------------------------------------------------------
-- Library constants
---------------------------------------------------------------------

local addon = LibStub("AceAddon-3.0"):GetAddon(kAddon)

local kFlagAdd = 0
local kFlagDelete = 1

local kResultsIndex = {
	  [-2] = "Disabled"
	, [-1] = "Duplicate"
	, [0] = "Ok"
	, "BlacklistedSource"
	, "InvalidZone"
	, "InvalidType"
	, "InvalidNode"
	, "InvalidCoord"
}

local kResults = {}
for k, v in ipairs(kResultsIndex) do
	kResults[ v ] = k
end

do
	local function ignore(t, k)
		--[===[@alpha@
		error("Tried to access " .. (k or "nil"), 2)
		--@end-alpha@]===]
		return nil
	end

	addon.kResults = setmetatable({}, { __index = kResults, __newindex = ignore })
	addon.kResultsIndex = setmetatable({}, { __index = kResultsIndex, __newindex = ignore })
end

local kResultDuplicate = kResults[ "Duplicate" ]
local kResultOk = kResults[ "Ok" ]

function addon.IsResultOk(in_result)
	return not (0 < (in_result or 0))
end

---------------------------------------------------------------------
-- AceAddon IMPLEMENTED functions
---------------------------------------------------------------------

do
	local function getDefaults(self)
		local defaults = self.var.defaults
		if not defaults then
			local modules = {}
			defaults = {
				profile = {
					add = {
						nodes = true
						, blacklist = {}
					}, delete = {
						nodes = true
						, blacklist = {}
					}, broadcast = {
						enabled = {
							"guild"
						}, targets = {
							["*"] = ""
						}
					}, duplicate = {
						window = 60
						, buffer_length = 100
						, buffer_cycles = 100
					}, modules = modules
				}
			}
			for name, mod in self:IterateModules() do
				if mod.GetDefaults then
					modules[ name ] = mod:GetDefaults()
				end
			end
			self.var.defaults = defaults
		end
		return defaults
	end

	function addon:OnInitialize()
		--self:setupFrames()
	
		-- Compute the constants for computing keys for last checking
		local bits_zone = math.ceil(math.log(self.GetNumZones()) / math.log(2))
		local bits_type = math.ceil(math.log(self.GetNumTypes()) / math.log(2))
		-- lsb used for a flag to indicate add / delete, increase as appropriate
		local bits_flag = 1
		local bits_coord_scale = floor((31 - bits_zone - bits_type - bits_flag) / 2) - 2

		--self.cache = setmetatable({}, { __mode = "v" })
		self.var = {
			events = LibStub("CallbackHandler-1.0"):New(self)
			, me = UnitName("player")
			, processing = false
			, last = {} -- This is a ring buffer
			, last_index = 0
			, last_updates = {}
			, last_updates_ref = setmetatable({}, { __index = function(t, k) rawset(t, k, 0) return 0 end })
			, last_updates_cycles = 0
			, mult_zone = 2^(31 - bits_zone) -- Highest bitst used for zone
			, mult_type = 2^(31 - bits_zone - bits_type) -- Next highest bits used for type
			, coord_scale = 2^bits_coord_scale
			, mult_x = 2^(bits_flag + bits_coord_scale + 2) -- range [0,3] (not [0, 1))
			, mult_y = 2^(bits_flag)
		}

		-- Setup Database
		self.db = LibStub("AceDB-3.0"):New(kAddon .. "DB")
		self.db:RegisterDefaults(getDefaults(self))

		self.db.RegisterCallback(self, "OnNewProfile", "LoadProfile")
		self.db.RegisterCallback(self, "OnProfileReset", "LoadProfile")
		self.db.RegisterCallback(self, "OnProfileChanged", "LoadProfile")
		self.db.RegisterCallback(self, "OnProfileCopied", "LoadProfile")

		-- Release the init functions for gc
		self.init = nil

		self:LoadProfile()
	end
end

function addon:OnModuleCreated(in_module)
	in_module.addon = self
end

---------------------------------------------------------------------
-- AceDB Handlers
---------------------------------------------------------------------

function addon:LoadProfile()
	local modes = { "add", "delete" }
	for _, mode in ipairs(modes) do
		self:SetMessageState(mode, self:GetMessageState(mode))
		self:SetBlacklist(mode, self:GetBlacklist(mode))
	end

	for _, method in ipairs(self:GetBroadcastMethods()) do
		self:SetBroadcastEnabled(method, self:GetBroadcastEnabled(method))
		self:SetBroadcastTarget(method, self:GetBroadcastTarget(method))
	end

	self:SetBroadcastPriority(self:GetBroadcastPriority())

	self:SetDuplicateWindow(self:GetDuplicateWindow())
	self:SetDuplicateBufferLength(self:GetDuplicateBufferLength())
	self:SetDuplicateBufferCycles(self:GetDuplicateBufferCycles())

	for name, mod in self:IterateModules() do
		if mod.LoadProfile then
			--[===[@alpha@
			self:Print("LoadProfile for " .. name)
			--@end-alpha@]===]
			mod:LoadProfile()
		end
	end
end

---------------------------------------------------------------------
-- Node functions
---------------------------------------------------------------------

function addon:ComputeNodeKey(in_flag, in_zone, in_x, in_y, in_nodeType)
	local var = self.var
	--[===[@alpha@
	assert(not in_zone or 0 < in_zone and in_zone <= addon.GetNumZones())
	assert(not in_nodeType or 0 < in_nodeType and in_nodeType <= addon.GetNumTypes())
	assert(not in_x or -1 <= in_x and in_x < 2) -- Allow for overflow coordinates
	assert(not in_y or -1 <= in_y and in_y < 2) -- Allow for overflow coordinates
	assert(0 <= in_flag and in_flag < 2)
	--@end-alpha@]===]
	local base = ((in_zone or 0) * var.mult_zone
			+ (in_nodeType or 0) * var.mult_type
			+ floor(((in_x or 2) + 1) * var.coord_scale) * var.mult_x
			+ floor(((in_y or 2) + 1) * var.coord_scale) * var.mult_y
			)
	return base + in_flag, base + (1 - in_flag)
end

do
	local function rebuildLastUpdateTables(self)
		--[===[@alpha@
		local start = GetTime()
		--@end-alpha@]===]
		local last = {}
		local last_updates = {}
		local last_updates_ref = setmetatable({}, getmetatable(self.var.last_updates_ref))
		local old_last_updates = self.var.last_updates
		for k, v in pairs(self.var.last) do
			last[ k ] = v
			last_updates[ v ] = old_last_updates[ v ]
			last_updates_ref[ v ] = last_updates_ref[ v ] + 1
		end
		self.var.last = last
		self.var.last_updates = last_updates
		self.var.last_updates_ref = last_updates_ref
		--[===[@alpha@
		self:Print("Rebuilt ring buffer tables in", (GetTime() - start), "seconds")
		--@end-alpha@]===]
	end

	local function checkRecent(self, ...)
		local key, inv_key = self:ComputeNodeKey(...)
		local var = self.var
		local updated = var.last_updates[ key ]
		local now = GetTime()
		local duplicate = self.db.profile.duplicate
		if updated then
			-- Check if it was updated within the duplicate window, if so its too recently seen
			if duplicate.window > now - updated then
				return false
			end
		end

		-- Retire the oldest ring buffer entry
		local last_index = var.last_index
		local retired = var.last[ last_index ]
		if retired then
			local ref = var.last_updates_ref[ retired ] - 1
			if 0 >= ref then
				ref = nil
				self.var.last_updates[ retired ] = nil
			end
			self.var.last_updates_ref[ retired ] = ref
		end

		-- Store the new entry
		var.last_updates[ key ] = now
		var.last_updates_ref[ key ] = var.last_updates_ref[ key ] + 1
		-- Store the new value in the ring buffer
		var.last[ last_index ] = key

		-- Invalidate any inverse keys, e.g. adds invalidate deletes, and deletes invalidate adds
		if var.last_updates[ inv_key ] then
			var.last_updates[ inv_key ] = 0 -- now should usually be > duplicate.window
		end

		-- Advance the last_index by 1
		last_index = last_index + 1
		if duplicate.buffer_length < last_index then
			last_index = 1
			-- Check whether we should rebuild the tables
			local last_updates_cycles = var.last_updates_cycles + 1
			if duplicate.buffer_cycles < last_updates_cycles then
				rebuildLastUpdateTables(self)
				last_updates_cycles = 0
			end
			var.last_updates_cycles = last_updates_cycles
		end
		var.last_index = last_index
		return true
	end

	local function checkNode(in_zone, in_x, in_y, in_nodeType, in_node)
		if not addon.IsValidZone(in_zone) then
			return kResults[ "InvalidZone" ]
		end
		if not addon.IsValidType(in_nodeType) then
			return kResults[ "InvalidType" ]
		end
		if not addon.IsValidNode(in_nodeType, in_node) then
			return kResults[ "InvalidNode" ]
		end
		if not (in_x and in_y) then
			return kResults[ "InvalidCoord" ]
		end

		return kResultOk
	end

	function addon:AddNode(in_source, ...) -- in_zone, in_x, in_y, in_nodeType, in_node, in_loot, in_note
		if in_source == self.var.me then in_source = nil end
		local retval = kResultOk
		local add = self.db.profile.add

		if not add.nodes then
			retval = kResults[ "Disabled" ]
		elseif in_source and add.blacklist[ in_source ] then
			retval = kResults[ "BlacklistedSource" ]
		elseif not checkRecent(self, kFlagAdd, ...) then
			retval = kResultDuplicate
		else
			retval = checkNode(...)
			if retval == kResultOk then
				self.var.events:Fire("OnNodeAdded", in_source, ...)
			end
		end
		--[===[@alpha@
		if retval ~= kResultOk then
			self:Print("Got", kResultsIndex[ retval ], "for", ...)
		end
		--@end-alpha@]===]
		return retval
	end

	function addon:DeleteNode(in_source, ...) -- in_zone, in_x, in_y, in_nodeType
		if in_source == self.var.me then in_source = nil end
		local retval = kResultOk
		local delete = self.db.profile.delete

		if not delete.nodes then
			retval = kResults[ "Disabled" ]
		elseif in_source and delete.blacklist[ in_source ] then
			retval = kResults[ "BlacklistedSource" ]
		elseif not checkRecent(self, kFlagDelete, ...) then
			retval = kResultDuplicate
		else
			retval = checkNode(...)
			if retval == kResultOk then
				self.var.events:Fire("OnNodeDeleted", in_source, ...)
			end
		end
		--[===[@alpha@
		if retval ~= kResultOk then
			self:Print("Got", kResultsIndex[ retval ], "for", ...)
		end
		--@end-alpha@]===]
		return retval
	end
end

---------------------------------------------------------------------
-- Broadcast functions
---------------------------------------------------------------------

do
	local kBroadcast = {
		guild = function(self, in_prefix, in_message)
			if not IsInGuild() then return false end
			self:SendCommMessage(in_prefix, in_message, "GUILD")
			return true
		end
		, raid = function(self, in_prefix, in_message)
			if not (0 < GetNumRaidMembers()) then return false end
			self:SendCommMessage(in_prefix, in_message, "RAID")
			return true
		end
		, party = function(self, in_prefix, in_message)
			if not (0 < GetNumPartyMembers()) then return false end
			self:SendCommMessage(in_prefix, in_message, "PARTY")
			return true
		end
		, whisper = function(self, in_prefix, in_message, in_target)
			if not in_target or "" == in_target then return false end
			self:SendCommMessage(in_prefix, in_message, "WHISPER", in_target)
			return true
		end
		, friends = function(self, in_prefix, in_message, in_target)
			for i = 1, GetNumFriends() do
				local name, level = GetFriendInfo(i)
				if 0 < level then
					self:SendCommMessage(in_prefix, in_message, "WHISPER", name)
				end
			end
			return true
		end
	}

	do
		local kBroadcastMethods = {}
		for k in pairs(kBroadcast) do
			tinsert(kBroadcastMethods, k)
		end

		function addon:GetBroadcastMethods()
			return kBroadcastMethods
		end
	end

	function addon:Broadcast(in_prefix, in_message)
		local targets = self.db.profile.broadcast.targets
		for _, v in ipairs(self.db.profile.broadcast.enabled) do
			local broadcast = kBroadcast[ v ]
			if broadcast and broadcast(self, in_prefix, in_message, targets[ v ]) then
				return
			end
		end
		--[===[@alpha@
		self:Print("No broadcast methods found")
		--@end-alpha@]===]
	end
end

---------------------------------------------------------------------
-- Processing functions
---------------------------------------------------------------------

function addon:BeginProcessing(in_mode)
	if self.var.processing then return false end

	self.var.processing = in_mode or true
	return true
end

function addon:IsProcessing(in_mode)
	return in_mode == self.var.processing
end

function addon:EndProcessing()
	self.var.processing = false
end

---------------------------------------------------------------------
-- Getter / Setter functions
---------------------------------------------------------------------

function addon:GetModuleConfig(in_name)
	return self.db.profile.modules[ in_name ]
end

function addon:SetMessageState(in_mode, in_accept)
	self.db.profile[ in_mode ].nodes = in_accept
end

function addon:GetMessageState(in_mode)
	return self.db.profile[ in_mode ].nodes
end

function addon:SetBlacklist(in_mode, in_list)
	local blacklist = self.db.profile[ in_mode ].blacklist
	if type(in_list) == "table" then
		-- Remove entries not in the input
		for k in pairs(blacklist) do
			if not in_list[ k ] then
				blacklist[ k ] = nil
			end
		end
		-- Add entries that are part of the input
		for k, v in pairs(in_list) do
			blacklist[ type(k) == "number" and v or k ] = true
		end
	elseif type(in_list) == "string" then
		-- Mark the entries found in the input
		for v in in_list:gmatch("[^\n, ]+") do
			if blacklist[ v ] then
				blacklist[ v ] = false
			end
		end
		-- Clear out the unvisited entries
		for k, v in pairs(blacklist) do
			blacklist[ k ] = not v or nil
		end
	end
end

function addon:GetBlacklist(in_mode)
	return table.concat(self.db.profile[ in_mode ].blacklist, "\n")
end

function addon:SetBroadcastEnabled(in_mode, in_state)
	local enabled_or_index = self:GetBroadcastEnabled(in_mode)
	if in_state and not enabled_or_index then
		table.insert(self.db.profile.broadcast.enabled, in_mode)
	elseif not in_state and enabled_or_index then
		table.remove(self.db.profile.broadcast.enabled, enabled_or_index)
	end
end

function addon:GetBroadcastEnabled(in_mode)
	for i, v in ipairs(self.db.profile.broadcast.enabled) do
		if in_mode == v then
			return i
		end
	end
	return false
end

function addon:SetBroadcastTarget(in_mode, in_target)
	self.db.profile.broadcast.targets[ in_mode ] = in_target
end

function addon:GetBroadcastTarget(in_mode)
	return self.db.profile.broadcast.targets[ in_mode ] or ""
end

function addon:SetBroadcastPriority(in_list)
	local enabled = self.db.profile.broadcast.enabled
	local count = #enabled
	if type(in_list) == "table" then
		count = #in_list
		for i, v in ipairs(in_list) do
			enabled[ i ] = v
		end
	elseif type(in_list) == "string" then
		local i = 0
		for v in in_list:gmatch("[^\n, ]+") do
			i = i + 1
			enabled[ i ] = v
		end
		count = i
	end
	-- Remove any left over entries
	for j = count + 1, #enabled do
		enabled[ j ] = nil
	end
end

function addon:GetBroadcastPriority()
	return table.concat(self.db.profile.broadcast.enabled, "\n")
end

function addon:SetDuplicateWindow(in_sec)
	if type(in_sec) == "number" and 5 <= in_sec then
		self.db.profile.duplicate.window = in_sec
	end
end

function addon:GetDuplicateWindow()
	return self.db.profile.duplicate.window
end

function addon:SetDuplicateBufferLength(in_length)
	if type(in_length) == "number" and 10 <= in_length then
		self.db.profile.duplicate.buffer_length = in_length
	end
end

function addon:GetDuplicateBufferLength()
	return self.db.profile.duplicate.buffer_length
end

function addon:SetDuplicateBufferCycles(in_cycles)
	if type(in_cycles) == "number" and 1 <= in_cycles then
		self.db.profile.duplicate.buffer_cycles = in_cycles
	end
end

function addon:GetDuplicateBufferCycles()
	return self.db.profile.duplicate.buffer_cycles
end
