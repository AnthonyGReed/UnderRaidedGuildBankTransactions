--[[
    Addon: UnderRaidedGBT from GuildBankTransactions found on the WoW Interface Forums
	Author: Thul(Anthony Reed)
	Previous Authors: Xrystal
]]

local tType, tName, itemLink, count, tab1, tab2, year, month, day, hour;
local transactionLine = {};
local maxTabTransactions = 0;
local maxTabs = 0;
local currentDate = date("%m-%d-%y")
local tabCount = 0;
local refreshCount = 0;
local logCount = 0;
local tabProcessed = {};
locak currentDateTime = {};
local diffYear, diffMonth, diffDay, diffHour;

GuildBankTransactionsHistory = GuildBankTransactionsHistory or {}
GuildBankTransactionsTabs = GuildBankTransactionsTabs or {}

local function processTransaction(tab, index)

end

local function processTabLogs()

end

local function refreshLogInfo(tabCount)

end

local function getLogInfo()

end

local function onEvent(self,event,...)

end

local evFrame = CreateFrame("Frame","evFrame",UIParent);

evFrame:SetScript( "OnEvent", onEvent );

-- Inform the frame which events it will process
evFrame:RegisterEvent( "ADDON_LOADED" );
evFrame:RegisterEvent( "BAG_UPDATE" );
evFrame:RegisterEvent( "GUILDBANKLOG_UPDATE" );
evFrame:RegisterEvent( "GUILDBANKFRAME_OPENED" );
evFrame:RegisterEvent( "GUILDBANK_UPDATE_TABS" );
