local addon = CreateFrame("Frame")

-- ==========================================
-- CONFIGURATION
-- ==========================================

local CONFIG = {
    debug = false,
}

local MELEE_ATTACK_SPELL_ID = 6603
local RANGED_ATTACK_SPELL_ID = 75

-- ==========================================
-- ATTACK STATES
-- ==========================================

local meleeEnabled = false
local rangedEnabled = false

local function Print(message)
    if CONFIG.debug then
        print("|cff33ccffSmartSwingTimers:|r " .. message)
    end
end

-- ==========================================
-- FRAME REGISTRATION
-- ==========================================

local meleeFrames = {}
local rangedFrames = {}

local function RegisterFrames()

    wipe(meleeFrames)
    wipe(rangedFrames)

    local mainHandFrame = _G["SwingTimerMainHandFrame"]
    local offHandFrame = _G["SwingTimerOffHandFrame"]
    local rangedFrame = _G["SwingTimerRangedFrame"]

    if mainHandFrame then table.insert(meleeFrames, mainHandFrame) end
    if offHandFrame then table.insert(meleeFrames, offHandFrame) end
    if rangedFrame then table.insert(rangedFrames, rangedFrame) end
end

-- ==========================================
-- VISIBILITY
-- ==========================================

local function SetVisibility(frameList, enabled)
    for _, frame in ipairs(frameList) do
        frame:SetAlpha(enabled and 1 or 0)
        frame:EnableMouse(enabled)
    end
end

local function UpdateVisibility()
    SetVisibility(meleeFrames, meleeEnabled)
    SetVisibility(rangedFrames, rangedEnabled)
end

-- ==========================================
-- EVENT HANDLING
-- ==========================================

addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("PLAYER_SWING")
addon:RegisterEvent("UNIT_SPELLCAST_START")

addon:SetScript("OnEvent", function(self, event, ...)
    Print(event)
    if event == "PLAYER_ENTERING_WORLD" then
        RegisterFrames()
        UpdateVisibility()

        Print("Loaded successfully")
    elseif event == "PLAYER_SWING" then
        local swingDuration, swingType = ...

        meleeEnabled = false
        rangedEnabled = false

        if swingType == Enum.PlayerSwingType.MainHand or swingType == Enum.PlayerSwingType.OffHand then
            meleeEnabled = true
        elseif swingType == Enum.PlayerSwingType.Ranged then
            rangedEnabled = true
        end

        UpdateVisibility()
    elseif event == "UNIT_SPELLCAST_START" then
        local unit, castGUID, spellID, castBarID = ...

        if unit == "player" then
            meleeEnabled = false
            rangedEnabled = false

            if spellID == MELEE_ATTACK_SPELL_ID then
                meleeEnabled = true
            elseif spellID == RANGED_ATTACK_SPELL_ID then
                rangedEnabled = true
            end

            UpdateVisibility()
        end
    end
end)

-- ==========================================
-- SLASH COMMANDS
-- ==========================================
if CONFIG.debug then
    SLASH_SMART_SWING_TIMERS1 = "/sst"

    SlashCmdList["SMART_SWING_TIMERS"] = function(message)
        message = string.lower(message or "")

        if message == "melee" then
            meleeEnabled = not meleeEnabled
            UpdateVisibility()
        elseif message == "ranged" then
            rangedEnabled = not rangedEnabled
            UpdateVisibility()
        elseif message == "status" then
            Print("Melee: " .. tostring(meleeEnabled))
            Print("Ranged: " .. tostring(rangedEnabled))
        else
            Print("/sst melee - Toggle melee display")
            Print("/sst ranged - Toggle ranged display")
            Print("/sst status - Show current states")
        end
    end
end
