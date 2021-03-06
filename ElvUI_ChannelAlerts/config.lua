local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CA = E:NewModule("ChannelAlerts", "AceEvent-3.0")

-- Default Options
P["CA"] = {
	["guild"] = "None",
	["officer"] = "None",
	["battleground"] = "None",
	["party"] = "None",
	["raid"] = "None",
	["channel1"] = "None",
	["channel2"] = "None",
	["channel3"] = "None",
	["channel4"] = "None",
	["channel5"] = "None",
	["channel6"] = "None",
	["channel7"] = "None",
	["channel8"] = "None",
	["channel9"] = "None",
	["channel10"] = "None",
	
	["throttle"] = {
		["guild"] = 5,
		["officer"] = 5,
		["battleground"] = 5,
		["party"] = 5,
		["raid"] = 5,
		["channels"] = 5,
	}
}

function CA:InsertOptions()
	E.Options.args.plugins.args.ChannelAlerts = {
		type = "group",
		name = "ChannelAlerts",
		disabled = function() return not E.private.chat.enable end,
		args = {
			updateChannels = {
				order = 1,
				type = "execute",
				name = L["Update Channels"],
				desc = L["The config should update automatically and add or remove channels. You can force an update by pressing this button."],
				func = function() CA:UpdateChannelsConfig() end,
			},
			spacer = {
				order = 2,
				type = "description",
				name = "",
			},
			alerts = {
				order = 3,
				type = "group",
				name = L["Channel Alerts"],
				guiInline = true,
				args = {
					guild = {
						order = 1,
						type = "select",
						dialogControl = "LSM30_Sound",
						name = CHAT_MSG_GUILD..L[" Alert"],
						desc = L["Set to 'None' to disable alerts for this channel"],
						values = AceGUIWidgetLSMlists.sound,
						get = function(info) return E.db.CA.guild end,
						set = function(info, value) E.db.CA.guild = value; end,
					},
					officer = {
						order = 2,
						type = "select",
						dialogControl = "LSM30_Sound",
						name = CHAT_MSG_OFFICER..L[" Alert"],
						desc = L["Set to 'None' to disable alerts for this channel"],
						values = AceGUIWidgetLSMlists.sound,
						get = function(info) return E.db.CA.officer end,
						set = function(info, value) E.db.CA.officer = value; end,
					},
					battleground = {
						order = 3,
						type = "select",
						dialogControl = "LSM30_Sound",
						name = BATTLEGROUND..L[" Alert"],
						desc = L["Set to 'None' to disable alerts for this channel"],
						values = AceGUIWidgetLSMlists.sound,
						get = function(info) return E.db.CA.battleground end,
						set = function(info, value) E.db.CA.battleground = value; end,
					},
					party = {
						order = 4,
						type = "select",
						dialogControl = "LSM30_Sound",
						name = CHAT_MSG_PARTY..L[" Alert"],
						desc = L["Set to 'None' to disable alerts for this channel"],
						values = AceGUIWidgetLSMlists.sound,
						get = function(info) return E.db.CA.party end,
						set = function(info, value) E.db.CA.party = value; end,
					},
					raid = {
						order = 5,
						type = "select",
						dialogControl = "LSM30_Sound",
						name = CHAT_MSG_RAID..L[" Alert"],
						desc = L["Set to 'None' to disable alerts for this channel"],
						values = AceGUIWidgetLSMlists.sound,
						get = function(info) return E.db.CA.raid end,
						set = function(info, value) E.db.CA.raid = value; end,
					},
				},
			},
			throttle = {
				order = 4,
				type = "group",
				name = L["Sound Throttle"],
				get = function(info) return E.db.CA.throttle[ info[#info] ] end,
				set = function(info, value) E.db.CA.throttle[ info[#info] ] = value; end,
				guiInline = true,
				args = {
					guild = {
						order = 1,
						type = "range",
						name = L["Guild Alert Throttle"],
						desc = L["Amount of time in seconds between each alert"],
						min = 1, max = 30, step = 1,
					},
					officer = {
						order = 2,
						type = "range",
						name = L["Officer Alert Throttle"],
						desc = L["Amount of time in seconds between each alert"],
						min = 1, max = 30, step = 1,
					},
					battleground = {
						order = 3,
						type = "range",
						name = L["Battleground Alert Throttle"],
						desc = L["Amount of time in seconds between each alert"],
						min = 1, max = 30, step = 1,
					},
					party = {
						order = 4,
						type = "range",
						name = L["Party Alert Throttle"],
						desc = L["Amount of time in seconds between each alert"],
						min = 1, max = 30, step = 1,
					},
					raid = {
						order = 5,
						type = "range",
						name = L["Raid Alert Throttle"],
						desc = L["Amount of time in seconds between each alert"],
						min = 1, max = 30, step = 1,
					},
					channels = {
						order = 6,
						type = "range",
						name = L["Channel Alert Throttle"],
						desc = L["Amount of time in seconds between each alert"],
						min = 1, max = 30, step = 1,
					},
				},
			},
		},
	}
	
	local group = E.Options.args.plugins.args.ChannelAlerts.args.alerts.args
	for i = 1, 10 do
		local channelName = CA.Channels[i]
		local hide = false
		if not channelName then hide = true end
		group["channel"..i] = {
			order = i + 5,
			type = "select",
			dialogControl = "LSM30_Sound",
			name = (not hide and channelName..L[" Alert"]) or "",
			desc = L["Set to 'None' to disable alerts for this channel"],
			values = AceGUIWidgetLSMlists.sound,
			hidden = hide,
			get = function(info) return E.db.CA["channel"..i] end,
			set = function(info, value) E.db.CA["channel"..i] = value; end,
		}
	end
	
	--Variable I can use to check whether the config exists or not
	CA.ConfigIsBuild = true
end

local function InitializeCallback()
	CA:Initialize()
end

E:RegisterModule(CA:GetName(), InitializeCallback)