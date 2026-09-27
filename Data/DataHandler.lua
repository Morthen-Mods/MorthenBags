local addonName, MB = ...
local handler = {}

local settingsTable = "BagSettings"

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == addonName then
        handler.OnLoad()

        local flavor = C_AddOns.GetAddOnMetadata(addonName, "X-MB-Game-Flavor")
        MB.GameFlavor = flavor
    end
end)

local function DeepCopy(source)
    local copy = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = DeepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

local function DeepMerge(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" then
            DeepMerge(target[key], value)
        else
            target[key] = value
        end
    end
end

function handler.OnLoad()
    for key, defaults in pairs(MB.Settings.defaults) do
        MB.Settings[key] = DeepCopy(defaults)

        local saved = _G[key]
        if saved ~= nil then
            DeepMerge(MB.Settings[key], saved)
        end

        _G[key] = MB.Settings[key]
    end
end

function handler.IsForever()
    return MB.GameFlavor == "Camelot"
end

function handler.IsRetail()
    return MB.GameFlavor == "Standard"
end

function handler.IsSupported()
    return (handler.IsForever() or handler.IsRetail())
end

function handler.GetSettings()
    return MB.Settings[settingsTable]
end

function handler.SetSetting(key, value)
    local setting = MB.Settings[settingsTable]
    setting[key] = value
end

function handler.GetSetting(key)
   local settings = MB.Settings[settingsTable]
   return settings[key]
end

function handler.GetDefault(key)
   local defaults = MB.Settings.defaults[settingsTable]
   return defaults[key]
end

MB.DataHandler = handler

MB.Settings = {
    defaults = {
        BagSettings =  {
            -- General
            addReagentsBag = false,
            addKeyring = false,

            itemLevel = false,
            itemLevelColor = false,
            itemLevelScale = 125,

            -- ItemSync / Tooltip
            itemSync = true,

            -- Layout
            splitBags = true,
            columns = 10
        }
    }
}