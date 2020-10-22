local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CA = E:GetModule("ChannelAlerts")
local CH = E:GetModule("Chat")
local LSM = LibStub("LibSharedMedia-3.0")
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, ns = ...
local gsub = string.gsub

local select = select
local GetChannelList = GetChannelList
local PlaySoundFile = PlaySoundFile
local UnitName = UnitName
local playerGUID

-- Function which monitors numbered channels 1-10 and plays sound
function CA:MonitorChannels(event, _, authorFullName, _, _, author, _, _, channelNumber, _, _, _, guid, ...)
	if (guid == playerGUID) then return end -- Don"t play sound if the message is from yourself
	if event == "CHAT_MSG_CHANNEL" and E.db.CA["channel"..channelNumber] ~= "None" and not CH.SoundTimer then
		PlaySoundFile(LSM:Fetch("sound", E.db.CA["channel"..channelNumber]), "Master")
		CH.SoundTimer = E:Delay(E.db.CA.throttle.channels, CH.ThrottleSound)
	end
end

-- Function which monitors guild channel and plays sound
function CA:MonitorGuild(event, _, authorFullName, _, _, author, _, _, _, _, _, _, guid, ...)
	if (guid == playerGUID) then return end -- Don"t play sound if the message is from yourself
	if event == "CHAT_MSG_GUILD" and E.db.CA.guild ~= "None" and not CH.SoundTimer then
		PlaySoundFile(LSM:Fetch("sound", E.db.CA.guild), "Master")
		CH.SoundTimer = E:Delay(E.db.CA.throttle.guild, CH.ThrottleSound)
	end
end

-- Function which monitors officer channel and plays sound
function CA:MonitorOfficer(event, _, authorFullName, _, _, author, _, _, _, _, _, _, guid, ...)
	if (guid == playerGUID) then return end -- Don"t play sound if the message is from yourself
	if event == "CHAT_MSG_OFFICER" and E.db.CA.officer ~= "None" and not CH.SoundTimer then
		PlaySoundFile(LSM:Fetch("sound", E.db.CA.officer), "Master")
		CH.SoundTimer = E:Delay(E.db.CA.throttle.officer, CH.ThrottleSound)
	end
end

-- Function which monitors battleground channel and plays sound
function CA:MonitorBattleground(event, _, authorFullName, _, _, author, _, _, _, _, _, _, guid, ...)
	if (guid == playerGUID) then return end -- Don"t play sound if the message is from yourself
	if (event == "CHAT_MSG_BATTLEGROUND" or event == "CHAT_MSG_BATTLEGROUND_LEADER") and E.db.CA.battleground ~= "None" and not CH.SoundTimer then
		PlaySoundFile(LSM:Fetch("sound", E.db.CA.battleground), "Master")
		CH.SoundTimer = E:Delay(E.db.CA.throttle.battleground, CH.ThrottleSound)
	end
end

-- Function which monitors party channel and plays sound
function CA:MonitorParty(event, _, authorFullName, _, _, author, _, _, _, _, _, _, guid, ...)
	if (guid == playerGUID) then return end -- Don"t play sound if the message is from yourself
	if (event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER") and E.db.CA.party ~= "None" and not CH.SoundTimer then
		PlaySoundFile(LSM:Fetch("sound", E.db.CA.party), "Master")
		CH.SoundTimer = E:Delay(E.db.CA.throttle.party, CH.ThrottleSound)
	end
end

-- Function which monitors raid channel and plays sound
function CA:MonitorRaid(event, _, authorFullName, _, _, author, _, _, _, _, _, _, guid, ...)
	if (guid == playerGUID) then return end -- Don"t play sound if the message is from yourself
	if (event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER") and E.db.CA.raid ~= "None" and not CH.SoundTimer then
		PlaySoundFile(LSM:Fetch("sound", E.db.CA.raid), "Master")
		CH.SoundTimer = E:Delay(E.db.CA.throttle.raid, CH.ThrottleSound)
	end
end

--Table we store our 1-10 channels in: [1] = ChannelName
CA.Channels = {}

local function buildChannelList(...)
	for i = 1, select("#", ...), 2 do
		local id, name = select(i, ...)
		CA.Channels[id] = name
	end
end

--Function which updates the CA.Channels table
function CA:UpdateChannelTable(event, msg, _, _, _, _, _, _, chanID, chanName, ...)
	if msg == "YOU_LEFT" and CA.Channels[chanID] then
		CA.Channels[chanID] = nil
		CA:UpdateChannelsConfig()
	--YOU_JOINED seems to have been replaced by YOU_CHANGED in 6.0
	--Keep YOU_JOINED just in case, and also for backwards compatibility
	elseif msg == "YOU_JOINED" or msg == "YOU_CHANGED" then
		local name = gsub(chanName, " ", "")
		CA.Channels[chanID] = name
		CA:UpdateChannelsConfig()
	end
end

--Do stuff when entering world
function CA:PLAYER_ENTERING_WORLD()
	--Build CA.Channels table
	buildChannelList(GetChannelList())
end

--Function which gets executed when user presses "Update Channels" in config
function CA:UpdateChannelsConfig()
	if not CA.ConfigIsBuild then return; end
	local group = E.Options.args.plugins.args.ChannelAlerts.args.alerts.args
	for i = 1, 10 do
		local channelName = CA.Channels[i]
		if channelName then
			group["channel"..i].name = channelName..L[" Alert"]
			group["channel"..i].hidden = false
		else
			group["channel"..i].hidden = true
		end
	end
	LibStub("AceConfigRegistry-3.0-ElvUI"):NotifyChange("ElvUI")
end

-- Stuff to do when addon is initialized
function CA:Initialize()
	-- Register callback with LibElvUIPlugin
	EP:RegisterPlugin(addon, CA.InsertOptions)
	
	--ElvUI Chat is not enabled, stop right here!
	if E.private.chat.enable ~= true then return end
	
	-- Register monitoring functions
	self:RegisterEvent("CHAT_MSG_CHANNEL", "MonitorChannels")
	self:RegisterEvent("CHAT_MSG_GUILD", "MonitorGuild")
	self:RegisterEvent("CHAT_MSG_OFFICER", "MonitorOfficer")
	self:RegisterEvent("CHAT_MSG_BATTLEGROUND", "MonitorBattleground")
	self:RegisterEvent("CHAT_MSG_BATTLEGROUND_LEADER", "MonitorBattleground")
	self:RegisterEvent("CHAT_MSG_PARTY", "MonitorParty")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER", "MonitorParty")
	self:RegisterEvent("CHAT_MSG_RAID", "MonitorRaid")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", "MonitorRaid")
	
	-- Update CA.Channels table on channel joined/left
	self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE", "UpdateChannelTable")
	
	--Initial setup
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	--Set GUID
	playerGUID = UnitGUID("player")
end