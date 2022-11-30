--[[
	Addon: UnderRaidedGBT from GuildBankTransactions found on the WoW Interface Forums
	Author: Thul(Anthony Reed)
	Previous Authors: Xrystal

]]

-- These are values that once set are available throughout the addon, set them when you need to and then use them anywhere afterwards
local tType, tName, itemLink, count, tab1, tab2, year, month, day, hour;
local queryCount = 0;
local messageCount= 0;
local transactionLine = {};
local maxTabTransactions = 0;
local maxTabs = 0;
local maxMoneyTransactions = 0;
local currentDate = date("%m-%d-%y")
local pName;
local tabCount = 0;
local refreshCount = 0;
local logCount = 0;
local tabProcessed = {};
local Queried = false;
local currentDateTime = {};
local diffYear, diffMonth, diffDay, diffHour

GuildBankTransactionsHistory = GuildBankTransactionsHistory or {}
GuildBankTransactionsTabs = GuildBankTransactionsTabs or {}
GuildBankTransactionsMoney = GuildBankTransactionsMoney or {}

-- The following is a block comment and allows for large segments to be comments instead of a line by line basis
--[[  Functions and their uses

Functions you can change to suit your requirements
=====================================================================================================================================
updateTransactionHistory(tab,index) - You use this to write to the GuildBankTransactionsHistory saved variable table specifically for tab transactions
updateMoneyTransactionHistory(index) - You use this to write to the GuildBankTransactionsHistory saved variable table specifically for money transactions
updateLastPlayerTransaction(tab) - You use this to write to the GuildBankTransactionsTabs saved variable table if you made the last tab transaction
updateLastPlayerMoneyTransaction() - You use this to write to the GuildBankTransactionsMoney saved variable table if you made the last money transaction

Functions you can change if you want to change what to store on each transaction line
=====================================================================================================================================
processTransaction(tab,index) - You use this to grab the information you want to store from the tab log in the saved variable table and when 
processMoneyTransaction(index) - You use this to grab the information you want to store from the money log into the saved variable tables and when

Functions you can change as you see fit
=====================================================================================================================================
displayMessages() - This is your function to display a message to you the user

Functions you should no longer need to change as they do every they need and passes the information onto another function to process
=====================================================================================================================================
processMoneyLog() - This function grabs every information it can from the money log transaction ready for you to use
processTabLogs() - This function grabs every information it can from the tab logs transactions ready for you to use
refreshLogInfo() - This function queries the log so that the transaction information is ready for us to use
getLogInfo() - This function gets us ready to use the data we just queried
onEvent(self,event,...) - This is the addons main frames event function and is the starting point of any addon process

--]]

-- This is the function that will update the relevant SavedVariables table
local function updateTransactionHistory(tab,index)    
	-- For this we are using GuildBankTransactionsHistory table
	
	-- Use the existing table or create a new one
	GuildBankTransactionsHistory = GuildBankTransactionsHistory or {}
	
	-- Use the existing sub table or create a new one
	GuildBankTransactionsHistory[tab] = GuildBankTransactionsHistory[tab] or {}
	
	-- Use the existing sub table or create a new one
	GuildBankTransactionsHistory[tab][currentDate] = GuildBankTransactionsHistory[tab][currentDate] or {}
	
	-- Use the existing sub table or create a new one
	GuildBankTransactionsHistory[tab][currentDate][index] = GuildBankTransactionsHistory[tab][currentDate][index] or {};
	
	-- Add the transaction
	GuildBankTransactionsHistory[tab][currentDate][index] = transactionLine;
	
end

-- This is the function that will update the relevant Saved Variables table
local function updateMoneyTransactionHistory(index)
	-- For this we are using GuildBankTransactionsHistory table
	
	-- Use the existing table or create a new one
	GuildBankTransactionsHistory = GuildBankTransactionsHistory or {}
	
	-- Use the existing sub table or create a new one
	GuildBankTransactionsHistory["Money"] = GuildBankTransactionsHistory["Money"] or {}
	
	-- Use the existing sub table or create a new one
	GuildBankTransactionsHistory["Money"][currentDate] = GuildBankTransactionsHistory["Money"][currentDate] or {}

	-- Use the existing sub table or create a new one
	GuildBankTransactionsHistory["Money"][currentDate][index] = GuildBankTransactionsHistory["Money"][currentDate][index] or {};
	
	-- Add the transaction
	GuildBankTransactionsHistory["Money"][currentDate][index] = transactionLine;
end

-- This is the function that will update the relevant SavedVariables table
local function updateLastPlayerTransaction(tab)
	-- For this we are using GuildBankTransactionsTabs to hold information

	-- Use the existing table or create a new one
	GuildBankTransactionsTabs = GuildBankTransactionsTabs or {}
	
	-- Use the existing sub table or create a new one
	GuildBankTransactionsTabs[tab] = GuildBankTransactionsTabs[tab] or {}
	
	-- Use the existing sub table or create a new one
	GuildBankTransactionsTabs[tab][pName] = GuildBankTransactionsTabs[tab][pName] or {};
	
	-- If you made this transaction then store the details or store another message
	if ( tName == pName ) then
		GuildBankTransactionsTabs[tab][pName] = transactionLine;
	else
		GuildBankTransactionsTabs[tab][pName] = { "You didn't make the last transaction" };
	end
	
end

-- This is the function that will update the relevant SavedVariables table
local function updateLastPlayerMoneyTransaction()
	-- We are using GuildBankTransactionsMoney as a SavedVariables table to hold the money transactions for your player
	
	-- Use the existing table or create a new one
	GuildBankTransactionsMoney = GuildBankTransactionsMoney or {}
	
	-- Use the existing table or create a new one
	GuildBankTransactionsMoney[pName] = GuildBankTransactionsMoney[pName] or {}
	
	-- If you made this transaction then store the details or store another message
	if ( tName == pName ) then
		GuildBankTransactionsMoney[pName] = transactionLine;
	else
		GuildBankTransactionsMoney[pName] = { "You didn't make the last transaction" };
	end
	
end

-- This is the function we can use to process the last tab transaction line read 
local function processTransaction(tab,index)

	-- If tab1 and tab2 have valid values then get their names for clarity
	if ( tab1 ) then tab1 = GetGuildBankTabInfo(tab1); end
	if ( tab2 ) then tab2 = GetGuildBankTabInfo(tab2); end       
	
	-- Record the transaction line in a table for easier insertion into main table
	transactionLine = { 
		["Transaction Type"] = tType,
		["Tab"] = tab,
		["Players Name"] = tName,
		["Item"] = itemLink,
		["Item Count"] = count,
		["Transaction Time"] = hour,
	};
	
	-- We want to update the transaction history regardless of who or which transaction it is
	updateTransactionHistory(tab,index);
	
	-- If this is the last transaction for the tab then see if it was yours
	if ( index == maxTabTransactions ) then

		diffYear = currentDateTime.year - year;
		diffMonth = currentDateTime.month - month;
		diffDay = currentDateTime.day - day;
		diffHour = currentDateTime.hour - hour;
		
		cdtString = currentDateTime.year .. ":".. currentDateTime.month..":"..currentDateTime.day..":"..currentDateTime.hour;
		tdtString = year..":"..month..":"..day..":"..hour;
		ddtString = diffYear..":"..diffMonth..":"..diffDay..":"..diffHour;
		
		print("Tab : ", tab, " Current: ", cdtString, " Transaction : ", tdtString, " Difference : ", ddtString);
	
		updateLastPlayerTransaction(tab); 
	end
end

-- This is the function we can use to process the last money transaction line read.
local function processMoneyTransaction(index)

	-- Because the data is in memory since the last read we can just format the information we want into a transaction line
	transactionLine = { 
		["Transaction Type"] = tType,
		["Player's Name"] = tName,
		["Amount"] = amount,
		["Transaction Time"] = hour,
	};
	
	-- Store transaction history for the Money Log
	updateMoneyTransactionHistory(index);
	
	-- If this is the last transaction then we want to see if you the player made it
	if ( index == maxMoneyTransactions ) then
		updateLastPlayerMoneyTransaction();
	end
end

-- Once you have the functions below doing what you want you shouldn't need to touch them anymore.  
-- Just adjust the functions above to change what you want to do with the data

-- This is the function that will process the Money Logs
local function processMoneyLog()

	-- if we have processed this tab already then no need to do it again
	if ( tabProcessed[maxTabs+1] ) then return end

	-- Get the maximum number of transaction that the money log contains
	maxMoneyTransactions = GetNumGuildBankMoneyTransactions();
	
	-- Give us a debug message of how many transactions there are... you will know if it is wrong :D
	print("processMoneyLog : maxMoneyTransactions = ", maxMoneyTransactions);
	
	-- For each line in the transactions we want to process them
	for index = 1,maxMoneyTransactions do
	
		-- Get the details for the transaction line
		tType, tName, amount, years, months, days, hours = GetGuildBankMoneyTransaction(index);
		
		-- Process the transaction as we see fit
		processMoneyTransaction(index);
		
	end
	
	-- If there were transactions or we have read all the tabs then we must have processed this log already
	if ( maxMoneyTransactions > 0 or queryCount > maxTabs ) then
		tabProcessed[maxTabs+1] = true;
	end
	
end

-- This is the function that you use to get the information out of the tabs
local function processTabLogs()
	
	-- Get your player name for testing later on
	pName = GetUnitName("player");
	
	-- For each tab in the guild bank we want to process the transactions
	for tab = maxTabs, 1, -1 do
	
		-- Set the current tab we want to work with ( its seems to like us to do this :D )
		SetCurrentGuildBankTab(tab);
	
		-- Get the maximum number of transactions this tab contains
		maxTabTransactions = GetNumGuildBankTransactions(tab);
		
		-- If this tab has not been processed yet and it has transactions then process it
		if ( not tabProcessed[tab] and maxTabTransactions > 0 ) then
			
			-- Give us a debug message of how many transactions on the current tab there are... you will know if it is wrong :D
			print("ProcessTabLogs : tab = ", tab, " maxTabTransactions = ", maxTabTransactions);
				
			-- For each line in the transactions we want to process the information
			for index = 1, maxTabTransactions do       
			
				-- Get the values for this transaction
				tType, tName, itemLink, count, tab1, tab2, year, month, day, hour = GetGuildBankTransaction(tab, index);

				-- process the transaction we have now retrieved
				processTransaction(tab,index);
			end

		end
		
		-- If there were transactions or we have read all the tabs then we must have processed this tab already
		if ( maxTabTransactions > 0 or queryCount > maxTabs ) then
			tabProcessed[tab] = true;
		end
		
	end
	SetCurrentGuildBankTab(1);
end

-- This is the function that will refresh the log information
local function refreshLogInfo(tabCount)
	-- Get the maximum number of bank tabs the guild bank currently has
	maxTabs = GetNumGuildBankTabs();
	queryCount = 0;
	
	-- We have been incrementing tabCount to ensure we get all the information
	-- But if the tabCount is more than there are tabs then we have all the information at hand so query the whole lot
	if ( tabCount > maxTabs ) then
		QueryGuildBankLog(MAX_GUILDBANK_TABS+1);
		for tab = 1,maxTabs do
			SetCurrentGuildBankTab(tab);
			QueryGuildBankLog(tab);
			QueryGuildBankTab(tab);
		end
		
		-- Then reset back to the original tab and reset the tabCount
		SetCurrentGuildBankTab(1);
		tabCount = 0;
	end
	
end

local function extractTableContents(t)
	for i,v in pairs(t) do
	    if ( type(v) == "table" ) then
		    extractTableContents(v);
		else
			print(type(v),i,v);
		end
	end
end

-- This is the function that starts the information gathering off
local function getLogInfo()
	queryCount = queryCount + 1;
	currentDateTime = date("*t");
	print("currentDateTime Start Block");
	extractTableContents(currentDateTime);
	print("currentDateTime End Block");
	processTabLogs();	
	processMoneyLog();	
end

-- This is the function that the frame will use to process the events as they happen
local function onEvent(self,event,...)
	
	-- When this addon is loaded make sure the Blizzard GuildBank UI is loaded
	if ( event == "ADDON_LOADED" ) then
		if ( arg1 == "GuildBankTransactions" ) then
			if ( not IsAddOnLoaded("Blizzard_GuildBankUI") ) then
				LoadAddOn("Blizzard_GuildBankUI");
			end
			tabCount = 0;
			logCount = 0;
		end

	-- If you have just opened the guild bank frame then refresh the Log Information
	elseif ( event == "GUILDBANKFRAME_OPENED" ) then
		-- reset the tabProcessing status whenever we open the frame
		tabProcessed = {};
		tabCount = tabCount + 1;
		logCount = 0;
		refreshLogInfo(tabCount);

	-- If your bag has had an update and the guild bank frame is open then refresh the Log Info just in case it was a guild bank transaction too
	elseif ( event == "BAG_UPDATE" ) then
		if ( GuildBankFrame:IsVisible() ) then 
			refreshLogInfo(maxTabs+1);
		end
		
	-- When the blizzard GuildBankUI is loaded it processes each tab so lets use that to get our info
	-- It also does this when you first open the frame 
	elseif ( event == "GUILDBANK_UPDATE_TABS" ) then
		tabCount = tabCount + 1;
		refreshLogInfo(tabCount);
		
	-- If the GUILDBANKLOG_UPDATE event has been triggered due to refreshing the Log Info then process the Log Information we now have
	elseif ( event == "GUILDBANKLOG_UPDATE" ) then
		logCount = logCount + 1;
		getLogInfo(logCount);
	end
end

-- Create the Frame that will handle any events, it currently has no physical form but it is in memory
local evFrame = CreateFrame("Frame","evFrame",UIParent);

-- Inform the frame that it will process several events
evFrame:SetScript( "OnEvent", onEvent );

-- Inform the frame which events it will process
evFrame:RegisterEvent( "ADDON_LOADED" );
evFrame:RegisterEvent( "BAG_UPDATE" );
evFrame:RegisterEvent( "GUILDBANKLOG_UPDATE" );
evFrame:RegisterEvent( "GUILDBANKFRAME_OPENED" );
evFrame:RegisterEvent( "GUILDBANK_UPDATE_TABS" );
