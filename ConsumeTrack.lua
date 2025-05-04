local addonName, addon = ...
local BT = CreateFrame("Frame")
_G[addonName] = addon

-- Initialize addon database
ConsumeTrackerDB = ConsumeTrackerDB or {
    records = {}, -- New structure organized by raid instance and date
    checks = {}, -- Keeping legacy data structure for backward compatibility
    
    zones = {
		[409] = "Molten Core",
		[469] = "Blackwing Lair",
		[531] = "Temple of Ahn'Qiraj",
		[533] = "Naxxramas",
		[2856] = "Scarlet Enclave"
		-- Can add additional zones to track. (Uncomment for Smaller Instance IDs)
		--[249] = "Onyxia's Lair",
		--[309] = "Zul'Gurub",
		--[509] = "Ruins of Ahn'Qiraj",
		--[2804] = "The Crystal Vale",
		--[] = "Emerald Dragons",
		--[] = "Kazzak",
		--[] = "Azuregos",
    },
    consumables = {
    [1213892] = "Flask of Ancient Knowledge",
    [17628] = "Flask of Supreme Power",
    [17629] = "Flask of Chromatic Resistance",
    [17627] = "Flask of Distilled Wisdom",
    [1213897] = "Flask of Madness",
    [1213901] = "Flask of the Old Gods",
    [17626] = "Flask of the Titans",
    [1213886] = "Flask of Unyielding Sorrow",
    [17629] = "Flask of Chromatic Resistance",
	[17539] = "Greater Arcane Elixir",
	[24363] = "Mageblood Potion",
	[11474] = "Elixir of Shadow Power",
	[26276] = "Elixir of Greater Firepower",
	[21920] = "Elixir of Frost Power",
	[1213914] = "Elixir of the Mage Lord",
	[11405] = "Elixir of the Giants",
	[17538] = "Elixir of the Mongoose",
	[1213904] = "Elixir of the Honey Badger",
	[3593] = "Elixir of Fortitude",
	[13448] = "Elixir of Superior Defense",
	[1213917] = "Elixir of the Ironside",
	[17537] = "Elixir of Brute Force",
	[16323] = "Juju Power",
	[16329] = "Juju Might",
	[17629] = "Flask of Chromatic Resistance",
	[11371] = "Gift of Arthas",
	[25661] = "Dirge's Kickin' Chimaerok Chops",
	[18141] = "Blessed Sunfruit Juice",
	[18125] = "Blessed Sunfruit",
	[470367] = "Smoked Redgill",
	[18192] = "Grilled Squid",
	[24799] = "Smoked Desert Dumplings",
	[15851] = "Dragonbreath Chili",
	[22730] = "Run Tum Tuber Surprise",
	[470361] = "Darkclaw Bisque",
	[19710] = "12 Sta/Spi Food",
	[10667] = "ROIDS",
	[10668] = "Lung Juice",
	[10669] = "Scorpid Assay",
	[10692] = "Cerebral Cortex",
	[10693] = "Gizzard Gum",
	[10670] = "ROIDS",
	[10671] = "Lung Juice",
	[10672] = "Scorpid Assay",
	[10690] = "Cerebral Cortex",
	[10691] = "Gizzard Gum",
	[30003] = "Sheen of Zanza",
	[24383] = "Swiftness of Zanza",
	[24382] = "Spirit of Zanza",
	[24361] = "Troll Blood",
	[25804] = "Rumsey Rum Black",
	[1225782] = "Feast",
    [1225778] = "25 Str/10 Sta",
    [1225780] = "29 spell dmg/55 heal/10 Sta",
    [1225779] = "25 Agi/10 Sta",
	[1219539] = "Seal of the Dawn - DPS - Rank 1",
	[1220514] = "Seal of the Dawn - Tank - Rank 1",
	[1219548] = "Seal of the Dawn - Healer - Rank 1",
	[1223348] = "Seal of the Dawn - DPS - Rank 2",
	[1223367] = "Seal of the Dawn - Tank - Rank 2",
	[1223379] = "Seal of the Dawn - Healer - Rank 2",
	[1223349] = "Seal of the Dawn - DPS - Rank 3",
	[1223368] = "Seal of the Dawn - Tank - Rank 3",
	[1223380] = "Seal of the Dawn - Healer - Rank 3",
	[1223350] = "Seal of the Dawn - DPS - Rank 4",
	[1223370] = "Seal of the Dawn - Tank - Rank 4",
	[1223381] = "Seal of the Dawn - Healer - Rank 4",
	[1223351] = "Seal of the Dawn - DPS - Rank 5",
	[1223371] = "Seal of the Dawn - Tank - Rank 5",
	[1223382] = "Seal of the Dawn - Healer - Rank 5",
	[1223352] = "Seal of the Dawn - DPS - Rank 6",
	[1223391] = "Seal of the Dawn - Tank - Rank 6",
	[1223383] = "Seal of the Dawn - Healer - Rank 6",
	[1223353] = "Seal of the Dawn - DPS - Rank 7",
	[1223373] = "Seal of the Dawn - Tank - Rank 7",
	[1223384] = "Seal of the Dawn - Healer - Rank 7",
	[1223353] = "Seal of the Dawn - DPS - Rank 8",
	[1223374] = "Seal of the Dawn - Tank - Rank 8",
	[1223385] = "Seal of the Dawn - Healer - Rank 8",
	[1223355] = "Seal of the Dawn - DPS - Rank 9",
	[1223375] = "Seal of the Dawn - Tank - Rank 9",
	[1223386] = "Seal of the Dawn - Healer - Rank 9",
	[1223357] = "Seal of the Dawn - DPS - Rank 10",
	[1223376] = "Seal of the Dawn - Tank - Rank 10",
	[1223387] = "Seal of the Dawn - Healer - Rank 10",
        -- Add more consumables as needed
    }
}

-- Local variables
local currentCheck = nil
local playerData = {}
local recordIndex = {} -- Maps numeric indexes to zone-date combinations

-- Helper function to get consumable consume information
local function GetConsumableConsumes(unit)
    local consumes = {}
	local i = 1
	while true do
    	local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
    	if not auraData then break end
    	local spellId = auraData.spellId
    	if ConsumeTrackerDB.consumables[spellId] then
        	consumes[spellId] = {
           	name = auraData.name,
            	remaining = auraData.expirationTime - GetTime(),
            	duration = auraData.duration
        	}
    	end
    	i = i + 1
	end
	return consumes
end

local function GetInitiatorUnit(initiatorName)
 
    -- Check raid members
    for i = 1, MAX_RAID_MEMBERS do
        local unit = "raid" .. i
        if UnitName(unit) == initiatorName then
            return unit
        end
    end
    
    -- Check party members
    for i = 1, MAX_PARTY_MEMBERS do
        local unit = "party" .. i
        if UnitName(unit) == initiatorName then
            return unit
        end
    end
    
    return nil
end

-- Event handler function
function BT:OnEvent(event, ...)
    if event == "ENCOUNTER_START" then
		local encounterID, encounterName = ...
		local _, _, _, _, _, _, _, zoneID, _ = GetInstanceInfo()
		local currentTime = date("%H:%M:%S", time())
		local currentDate = date("%m/%d/%y", time())
		local zoneName = ConsumeTrackerDB.zones[zoneID] or "Unknown Zone"
		
		--print("|cff17FDFDEncounter started: " .. encounterName .. " (ID: " .. encounterID .. ")|r")
		activeEncounter = encounterID   
		
		if ConsumeTrackerDB.zones[zoneID] then
			--print("|cff17FDFDConsumeTracker: Logging Raid Consumables!|r")
			
			-- Ensure zone exists in records
			ConsumeTrackerDB.records[zoneName] = ConsumeTrackerDB.records[zoneName] or {}
			-- Ensure date exists for this zone
			ConsumeTrackerDB.records[zoneName][currentDate] = ConsumeTrackerDB.records[zoneName][currentDate] or {
				encounters = {}
			}
			
			currentCheck = {
				name = encounterName,
				timestamp = currentTime,
				players = {}
			}
			
			if GetNumGroupMembers() > 0 then
				local isInRaid = IsInRaid()
				local numMembers = GetNumGroupMembers()
			
				-- Process each group member
				for i = 1, numMembers do
					local unit = isInRaid and "raid"..i or "party"..i
					local playerName = UnitName(unit)
					local className, _ = UnitClass(unit)
					if playerName then
						currentCheck.players[playerName] = {
							class = className,
							consumes = GetConsumableConsumes(unit)
						}
					end
				end
			else
				local initiator = UnitName("player")
				local className, _ = UnitClass("player")
    			
    			-- Add the player data
    			currentCheck.players[initiator] = {
        			class = className,
        			consumes = GetConsumableConsumes(initiator)
    			}
			end
			
			-- Add to both data structures
			table.insert(ConsumeTrackerDB.records[zoneName][currentDate].encounters, currentCheck)
			
			-- For backward compatibility
			local legacyCheck = {
				timestamp = encounterName .. " - " .. currentDate .. " " .. currentTime,
				players = currentCheck.players
			}
			table.insert(ConsumeTrackerDB.checks, legacyCheck)
			
			currentCheck = nil
		end
	end
end

-- Register events
BT:RegisterEvent("ENCOUNTER_START")
BT:SetScript("OnEvent", BT.OnEvent)

-- Slash command to export data
SLASH_ConsumeTRACKER1 = "/ct"
SLASH_ConsumeTRACKER2 = "/consumetracker"

local function ExportToCSV(filterZone, filterDate)
    local csv = "Date,Zone,Encounter,Time,Player,Class,Consumable,\n"
    
    -- Use the new structured format
    for zoneName, zoneDates in pairs(ConsumeTrackerDB.records) do
        -- Skip if we're filtering by zone and this isn't the zone we want
        if filterZone and filterZone ~= zoneName then
            -- Skip this zone
        else
            for dateStr, dateData in pairs(zoneDates) do
                -- Skip if we're filtering by date and this isn't the date we want
                if filterDate and filterDate ~= dateStr then
                    -- Skip this date
                else
                    for _, encounter in ipairs(dateData.encounters) do
                        for playerName, data in pairs(encounter.players) do
                            if data.consumes and next(data.consumes) then
                                for spellId, consume in pairs(data.consumes) do
                                    csv = csv .. string.format("%s,%s,%s,%s,%s,%s,%s,\n",
                                        dateStr,
                                        zoneName,
                                        encounter.name,
                                        encounter.timestamp,
                                        playerName,
                                        data.class,
                                        ConsumeTrackerDB.consumables[spellId]
                                    )
                                end
                            else
                                -- Player has no tracked consumables
                                csv = csv .. string.format("%s,%s,%s,%s,%s,%s,None,\n",
                                    dateStr,
                                    zoneName,
                                    encounter.name,
                                    encounter.timestamp,
                                    playerName,
                                    data.class
                                )
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- If there's no data in the new structure but there is in the old one, 
    -- and we're not filtering (default export), fall back to legacy format
    if csv == "Date,Zone,Encounter,Time,Player,Class,Consumable,\n" and 
       #ConsumeTrackerDB.checks > 0 and
       not filterZone and not filterDate then
        
        csv = "Boss,Player,Class,Consumable,\n"
        
        for _, check in ipairs(ConsumeTrackerDB.checks) do
            for playerName, data in pairs(check.players) do
                if data.consumes and next(data.consumes) then
                    for spellId, consume in pairs(data.consumes) do
                        csv = csv .. string.format("%s,%s,%s,%s,\n",
                            check.timestamp,
                            playerName,
                            data.class,
                            ConsumeTrackerDB.consumables[spellId]
                        )
                    end
                else
                    -- Player has no tracked consumables
                    csv = csv .. string.format("%s,%s,%s,None\n",
                        check.timestamp,
                        playerName,
                        data.class
                    )
                end
            end
        end
    end
    
    return csv
end

-- Helper function to get sorted list of records
local function GetSortedRecords()
    local recordList = {}
    
    -- Collect all zone-date combinations
    for zoneName, zoneDates in pairs(ConsumeTrackerDB.records) do
        for dateStr, dateData in pairs(zoneDates) do
            local encounterCount = #dateData.encounters
            table.insert(recordList, {
                zone = zoneName,
                date = dateStr,
                count = encounterCount
            })
        end
    end
    
    -- Sort records by date (newer first), then by zone name
    table.sort(recordList, function(a, b)
        -- Extract date components for comparison
        local aMonth, aDay, aYear = a.date:match("(%d+)/(%d+)/(%d+)")
        local bMonth, bDay, bYear = b.date:match("(%d+)/(%d+)/(%d+)")
        
        -- Convert to numbers
        aMonth, aDay, aYear = tonumber(aMonth), tonumber(aDay), tonumber(aYear)
        bMonth, bDay, bYear = tonumber(bMonth), tonumber(bDay), tonumber(bYear)
        
        -- Compare by year, month, day
        if aYear ~= bYear then return aYear > bYear end
        if aMonth ~= bMonth then return aMonth > bMonth end
        if aDay ~= bDay then return aDay > bDay end
        
        -- If dates are equal, sort by zone name
        return a.zone < b.zone
    end)
    
    return recordList
end

-- Helper function to list available recorded data
local function ListRecords(showNumbers)
    print("ConsumeTracker: Available records:")
    local recordList = GetSortedRecords()
    
    -- Clear the record index
    recordIndex = {}
    
    if #recordList > 0 then
        for i, record in ipairs(recordList) do
            local plural = record.count == 1 and "encounter" or "encounters"
            local prefix = showNumbers and (i .. " - ") or "  - "
            print(string.format("%s%s (%s) - %d %s", 
                prefix,
                record.zone, 
                record.date, 
                record.count,
                plural
            ))
            
            -- Store in the index if showing numbers
            if showNumbers then
                recordIndex[i] = {
                    zone = record.zone,
                    date = record.date
                }
            end
        end
    else
        print("  No raid data recorded yet")
    end
    
    if showNumbers then
        print("\nUse: /ct export [number] to export a specific record set")
    else
        print("\nUse: /ct export zone [ZoneName] or /ct export date [Date] to export specific data")
    end
end

SlashCmdList["ConsumeTRACKER"] = function(msg)
    -- Parse the command arguments
    local args = {}
    for arg in string.gmatch(msg, "%S+") do
        table.insert(args, arg)
    end
    
    local command = args[1] or ""
    
    if command == "export" then
        local filterZone = nil
        local filterDate = nil
        local exportNumber = tonumber(args[2])
        
        -- Check if we're using numbered export
        if exportNumber and recordIndex[exportNumber] then
            filterZone = recordIndex[exportNumber].zone
            filterDate = recordIndex[exportNumber].date
        -- Otherwise check for standard filters
        elseif args[2] == "zone" and args[3] then
            filterZone = args[3]
        elseif args[2] == "date" and args[3] then
            filterDate = args[3]
        -- If no args, show numbered listing
        elseif not args[2] then
            -- Show numbered listing and return
            ListRecords(true)
            return
        end
        
        local csv = ExportToCSV(filterZone, filterDate)
        local exportTitle = "Complete Export"
        
        if filterZone and filterDate then
            exportTitle = "Export for " .. filterZone .. " (" .. filterDate .. ")"
        elseif filterZone then
            exportTitle = "Export for " .. filterZone
        elseif filterDate then
            exportTitle = "Export for " .. filterDate
        end
        
        -- Create a popup with the CSV data
        StaticPopupDialogs["ConsumeTRACKER_EXPORT"] = {
            text = "Copy the " .. exportTitle .. " data below:",
            button1 = "Close",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            hasEditBox = true,
            editBoxWidth = 350,
            OnShow = function(self)
                self.editBox:SetText(csv)
                self.editBox:HighlightText()
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end
        }
        StaticPopup_Show("ConsumeTRACKER_EXPORT")
    elseif msg == "check" then
		local currentTime = date("%H:%M:%S", time())
		local currentDate = date("%m/%d/%y", time())
		local _, _, _, _, _, _, _, zoneID, _ = GetInstanceInfo()
		local zoneName = ConsumeTrackerDB.zones[zoneID] or "Manual Check"
		
		-- Ensure zone exists in records
		ConsumeTrackerDB.records[zoneName] = ConsumeTrackerDB.records[zoneName] or {}
		-- Ensure date exists for this zone
		ConsumeTrackerDB.records[zoneName][currentDate] = ConsumeTrackerDB.records[zoneName][currentDate] or {
			encounters = {}
		}
		
		currentCheck = {
			name = "Manual Check",
			timestamp = currentTime,
			players = {}
		}
		
		if GetNumGroupMembers() > 0 then
			local isInRaid = IsInRaid()
			local numMembers = GetNumGroupMembers()
        
			-- Process each group member
			for i = 1, numMembers do
				local unit = isInRaid and "raid"..i or "party"..i
				local playerName = UnitName(unit)
				local className, _ = UnitClass(unit)
				if playerName then
					currentCheck.players[playerName] = {
						class = className,
						consumes = GetConsumableConsumes(unit)
					}
				end
			end
		else
			local initiator = UnitName("player")
			local className, _ = UnitClass("player")
    
			-- Add the player data
			currentCheck.players[initiator] = {
				class = className,
				consumes = GetConsumableConsumes(initiator)
			}
    	
			if not currentCheck.players[initiator].consumes then
				currentCheck.players[initiator].consumes = nil  -- or remove this line if you don't need it
			end
		end
		
		-- Add to both data structures
		table.insert(ConsumeTrackerDB.records[zoneName][currentDate].encounters, currentCheck)
		
		-- For backward compatibility
		local legacyCheck = {
			timestamp = "Manual Check - " .. currentDate .. " " .. currentTime,
			players = currentCheck.players
		}
		table.insert(ConsumeTrackerDB.checks, legacyCheck)
		
		currentCheck = nil
		print("ConsumeTracker: Manual check recorded")
    elseif command == "clear" then
        if args[2] == "zone" and args[3] then
            local zoneToDelete = args[3]
            if ConsumeTrackerDB.records[zoneToDelete] then
                ConsumeTrackerDB.records[zoneToDelete] = nil
                print("ConsumeTracker: Data for " .. zoneToDelete .. " cleared")
            else
                print("ConsumeTracker: Zone " .. zoneToDelete .. " not found")
            end
        elseif args[2] == "date" and args[3] then
            local dateToDelete = args[3]
            local found = false
            for zoneName, zoneDates in pairs(ConsumeTrackerDB.records) do
                if zoneDates[dateToDelete] then
                    zoneDates[dateToDelete] = nil
                    found = true
                end
            end
            if found then
                print("ConsumeTracker: Data for " .. dateToDelete .. " cleared")
            else
                print("ConsumeTracker: Date " .. dateToDelete .. " not found")
            end
        else
            ConsumeTrackerDB.checks = {}
            ConsumeTrackerDB.records = {}
            print("ConsumeTracker: All data cleared")
        end
    elseif command == "list" then
        -- New simplified list command that shows zone-date combinations
        ListRecords(false)
    else
        print("ConsumeTracker commands:")
        print("/ct export - Show numbered listing of available records")
        print("/ct export [number] - Export data for the numbered record")
        print("/ct export zone [ZoneName] - Export data for specific raid zone")
        print("/ct export date [Date] - Export data for specific date (format: mm/dd/yy)")
        print("/ct check - Adds manual check to records")
        print("/ct list - List all available recorded data (zone-date combinations)")
        print("/ct clear - Clear all stored data")
        print("/ct clear zone [ZoneName] - Clear data for specific raid zone")
        print("/ct clear date [Date] - Clear data for specific date (format: mm/dd/yy)")
    end
end
