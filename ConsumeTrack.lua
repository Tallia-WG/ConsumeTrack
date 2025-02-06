local addonName, addon = ...
local BT = CreateFrame("Frame")
_G[addonName] = addon

-- Initialize addon database
ConsumeTrackerDB = ConsumeTrackerDB or {
    checks = {},
    
    zones = {
		[409] = "Molten Core",
		[469] = "Blackwing Lair",
		[531] = "Temple of Ahn'Qiraj",
		[533] = "Naxxramas",
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
	[13445] = "Elixir of Superior Defense",
	[1213917] = "Elixir of the Ironside",
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
	[1223348] = "Seal of the Dawn - DPS - Rank 2",
	[1223367] = "Seal of the Dawn - Tank - Rank 2",
	[1223379] = "Seal of the Dawn - Healer - Rank 2",
        -- Add more consumables as needed
    }
}

-- Local variables
local currentCheck = nil
local playerData = {}

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
		local _, _, _, _, _, _, _, zone, _ = GetInstanceInfo()
		--print("|cff17FDFDEncounter started: " .. encounterName .. " (ID: " .. encounterID .. ")|r")
		activeEncounter = encounterID   
		if ConsumeTrackerDB.zones[zone] then
			--print("|cff17FDFDConsumeTracker: Logging Raid Consumables!|r")
			if GetNumGroupMembers() > 0 then
				currentCheck = {
					timestamp = encounterName, 
					players = {}
				}
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
				table.insert(ConsumeTrackerDB.checks, currentCheck)
				currentCheck = nil   
			else
				local initiator = UnitName("player")
				local className, _ = UnitClass("player")
    			currentCheck = {
       			timestamp = encounterName,
        		players = {}  -- Initialize as empty table
    			}
    
    	-- Add the player data
    			currentCheck.players[initiator] = {
        			class = className,
        			consumes = GetConsumableConsumes(initiator)
    			}
				table.insert(ConsumeTrackerDB.checks, currentCheck)
				currentCheck = nil    -- moved outside the if block
			end
		end
	end
end

-- Register events
BT:RegisterEvent("ENCOUNTER_START")
BT:SetScript("OnEvent", BT.OnEvent)

-- Slash command to export data
SLASH_ConsumeTRACKER1 = "/ct"
SLASH_ConsumeTRACKER2 = "/consumetracker"

local function ExportToCSV()
    local csv = "Boss,Player,Class,Consumable,\n"
    
    for _, check in ipairs(ConsumeTrackerDB.checks) do
        for playerName, data in pairs(check.players) do
            if next(data.consumes) then
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
    
    return csv
end

SlashCmdList["ConsumeTRACKER"] = function(msg)
    if msg == "export" then
        local csv = ExportToCSV()
        -- Create a popup with the CSV data
        StaticPopupDialogs["ConsumeTRACKER_EXPORT"] = {
            text = "Copy the CSV data below:",
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
    	local currentTime = date("%m/%d/%y %H:%M:%S", time())
    	if GetNumGroupMembers() > 0 then
    		currentCheck = {
    			timestamp = currentTime,
    			players = {}
    		}
    		local isInRaid = IsInRaid()
        	local numMembers = GetNumGroupMembers()
        
        	-- Process each group member
        	for i = 1, numMembers do
            	local unit = isInRaid and "raid"..i or "party"..i
            	local playerName = UnitName(unit)
            	local className, _ = UnitClass("player")
            	if playerName then
                	currentCheck.players[playerName] = {
                	class = className,
                    consumes = GetConsumableConsumes(unit)
                	}
            	end
       		 end
  		table.insert(ConsumeTrackerDB.checks, currentCheck)
    	currentCheck = nil
    	else
   			local initiator = UnitName("player")
			local className, _ = UnitClass("player")
    		currentCheck = {
       		timestamp = currentTime,
        	players = {}  -- Initialize as empty table
    		}
    
    	-- Add the player data
    		currentCheck.players[initiator] = {
        		class = className,
        		consumes = GetConsumableConsumes(initiator)
    		}
    	
    		if not currentCheck.players[initiator].consumes then
        		currentCheck.players[initiator].consumes = nil  -- or remove this line if you don't need it
   	 		end
    	table.insert(ConsumeTrackerDB.checks, currentCheck)
    	currentCheck = nil
    	end
    elseif msg == "clear" then
        ConsumeTrackerDB.checks = {}
        print("ConsumeTracker: Data cleared")
    else
        print("ConsumeTracker commands:")
        print("/ct export - Export data to CSV")
        print("/ct check - Adds faux ready check to tables")
        print("/ct clear - Clear stored data")
    end
end
