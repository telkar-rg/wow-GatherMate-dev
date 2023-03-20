--[[-----------------------------------------------------------------

GatherTogether enUS localization

Lists the localized strings in alpha order.

Author: lokicoyote
File Date: 2008-12-23T11:40:40Z
File Revision: 61
Project Revision: 66
Project Version: r0.5.1

-------------------------------------------------------------------]]

local kAddon = "GatherTogether"
local L = LibStub("AceLocale-3.0"):NewLocale(kAddon, "enUS", true)

if not L then return end

L[ kAddon ] = true
L[ "Slash-Commands" ] = { "gathertogether", "GatherTogether" }

L["add"] = "Add"
L["add-desc"] = "Accept incoming add node messages"
L["Added T / N to Z (X, Y) by W"] = function(T,N,Z,X,Y,W) return "Added", T, "/", N, "to", Z, ("(%.4f, %.4f)"):format(X, Y), "by", W end
L["advanced"] = "Advanced"
L["advanced-desc"] = "Change advanced options"
L["advanced.duplicate"] = "Duplicate"
L["advanced.duplicate-desc"] = "Parameters related to duplicate tracking"
L["advanced.duplicate.buffer_cycles"] = "Buffer cycles"
L["advanced.duplicate.buffer_cycles-desc"] = "The number of buffer iterations before rebuilding the duplicate buffers"
L["advanced.duplicate.buffer_length"] = "Buffer length"
L["advanced.duplicate.buffer_length-desc"] = "The number of recent entries to track for duplicates"
L["advanced.duplicate.window"] = "Window"
L["advanced.duplicate.window-desc"] = "The number of seconds during which duplicates will be considered"
L["blacklist"] = "Blacklist"
L["blacklist-desc"] = "Blacklist incoming message sources"
L["blacklist.add"] = "Add"
L["blacklist.add-desc"] = "Blacklist incoming add messages from the listed sources"
L["blacklist.add-usage"] = "List the blacklisted sources separated by a space or tab.  Must match player name exactly"
L["blacklist.delete"] = "Delete"
L["blacklist.delete-desc"] = "Blacklist incoming delete messages from the listed sources"
L["blacklist.delete-usage"] = "List the blacklisted sources separated by a space or tab.  Must match player name exactly"
L["Bridge"] = true
L["bridges"] = "Bridges"
L["bridges-desc"] = "Bridge modules for converting addon broadcasts"
L["bridges.description"] = "Bridge modules allow you to send and receive node information with people using other gather addons."
L["bridges.deactivated"] = "Currently Deactivated by a Support module"
L["bridges.enable"] = "Enable"
L["bridges.enable-desc"] = "Enable this bridge"
L["bridges.options.GatherMate"] = "GatherMate"
L["bridges.options.GatherMate-desc"] = "GatherMate by kagaro, Xinhuan, Ammo, Nevcairiel"
L["bridges.options.Gatherer"] = "Gatherer"
L["bridges.options.Gatherer-desc"] = "Gatherer by Norganna"
L["broadcast"] = "Broadcast"
L["broadcast-desc"] = "Broadcast outgoing message destination"
L["broadcast.list"] = "Broadcast method list"
L["broadcast.list-desc"] = "Enable and prioritize broadcast methods"
L["broadcast.list-usage"] = "List the following methods in order of priority: guild, party, raid, friends, whisper"
L["broadcast.enabled"] = "Enabled methods"
L["broadcast.enabled-desc"] = "Enable which broadcast methods to use"
L["broadcast.priority"] = "Priority"
L["broadcast.priority-desc"] = "The priority order inwhich methods will be used"
L["broadcast.targets"] = "Targets"
L["broadcast.targets-desc"] = "Targets used by specific methods"
L["broadcast.targets.whisper"] = "Whisper"
L["broadcast.targets.whisper-desc"] = "The name of the player to send broadcasts to"
L["delete"] = "Delete"
L["delete-desc"] = "Accept incoming delete node messages"
L["Deleted T / N from Z (X, Y) by W"] = function(T,N,Z,X,Y,W) return "Deleted", T, "/", N, "from", Z, ("(%.4f, %.4f)"):format(X, Y), "by", W end
L["enabled"] = "Enabled"
L["enabled-desc"] = "Enable this module"
L["Feedback"] = true
L["Feedback-desc"] = "Print status messages to console on add or delete"
L["friends"] = true
L["guild"] = true
L["No"] = NO
L["popup.bridge.ConfirmDisable"] = function(X) return "All Bridges have been disabled by support addons.  Do you want to disable " .. X .. "?" end
L["party"] = true
L["profile"] = "Profile"
L["raid"] = true
L["Support"] = true
L["supports"] = "Bridges"
L["supports-desc"] = "Support modules for adding nodes to databases"
L["supports.description"] = "Support modules (addons) allow you to add received nodes to your own databases and send gathered nodes to other people via enabled bridge modules."
L["supports.enable"] = "Enable"
L["supports.enable-desc"] = "Enable this addon"
L["supports.options.GatherMate"] = "GatherMate"
L["supports.options.GatherMate-desc"] = "GatherMate by kagaro, Xinhuan, Ammo, Nevcairiel"
L["supports.options.Gatherer"] = "Gatherer"
L["supports.options.Gatherer-desc"] = "Gatherer by Norganna"
L["supports.options.MetaMap"] = "Gatherer"
L["supports.options.MetaMap-desc"] = "Gatherer by MetaHawk"
L["whisper"] = true
L["Yes"] = YES
