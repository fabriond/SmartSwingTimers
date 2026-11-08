local addon = CreateFrame("Frame")

-- ==========================================
-- CONFIGURATION
-- ==========================================

local CONFIG = {
    meleeFrames = {
        "SwingTimerMainHandFrame",
        "SwingTimerOffHandFrame",
    },

    rangedFrames = {
        "SwingTimerRangedFrame",
    },

    debug = false,
}

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

    for _, name in ipairs(CONFIG.meleeFrames) do
        local frame = _G[name]

        if frame then
            table.insert(meleeFrames, frame)
        else
            Print("Could not find melee frame: " .. name)
        end
    end

    for _, name in ipairs(CONFIG.rangedFrames) do
        local frame = _G[name]

        if frame then
            table.insert(rangedFrames, frame)
        else
            Print("Could not find ranged frame: " .. name)
        end
    end
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

local function AllFramesReady()
    local allFramesReady = true

    for _, name in ipairs(CONFIG.meleeFrames) do
        if not _G[name] then
            allFramesReady = false
            break
        end
    end

    if allFramesReady then
        for _, name in ipairs(CONFIG.rangedFrames) do
            if not _G[name] then
                allFramesReady = false
                break
            end
        end
    end

    return allFramesReady
end


local function InitializeVisibility()

    local initialized = false

    addon:SetScript("OnUpdate", function(self)
        if AllFramesReady then
            RegisterFrames()
            UpdateVisibility()

            initialized = true

            Print("Swing timers initialized")

            self:SetScript("OnUpdate", nil)
        end
    end)

end

-- ==========================================
-- EVENT HANDLING
-- ==========================================

addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("PLAYER_SWING")
addon:RegisterEvent("PLAYER_IN_COMBAT_CHANGED")
addon:RegisterEvent("PLAYER_TARGET_DIED")
addon:RegisterEvent("PLAYER_DEAD")

addon:SetScript("OnEvent", function(self, event, ...)
    Print(event)
    if event == "PLAYER_ENTERING_WORLD" then
        InitializeVisibility()

        Print("Loaded successfully")
    elseif event == "PLAYER_SWING" then
        local swingDuration, swingType = ...

        if swingType == Enum.PlayerSwingType.MainHand or swingType == Enum.PlayerSwingType.OffHand then
            meleeEnabled = true
            rangedEnabled = false
        elseif swingType == Enum.PlayerSwingType.Ranged then
            meleeEnabled = false
            rangedEnabled = true
        end

        UpdateVisibility()
    elseif event == "PLAYER_IN_COMBAT_CHANGED" then
        local inCombat = ...

        if not inCombat then
            meleeEnabled = false
            rangedEnabled = false

            UpdateVisibility()
        end
    elseif event == "PLAYER_DEAD" or event == "PLAYER_TARGET_DIED" then
        meleeEnabled = false
        rangedEnabled = false

        UpdateVisibility()
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
