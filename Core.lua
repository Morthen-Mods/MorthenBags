local ADDON, ns = ...

-- Every stored setting, with the value used when a profile does not have one.
ns.defaults = {
    -- General
    addReagentsBag = false, -- draw the reagent bag inside the combined bag
    itemLevel      = false, -- print item level on weapons and armor
    itemLevelColor = false, -- tint that text with the item quality color
    itemLevelScale = 125,   -- percent

    -- Tooltip
    itemCounts     = true,  -- list which characters are holding the item

    -- Layout
    splitBags      = true,  -- every bag starts on a fresh row
    columns        = 10,
}

local function LoadSettings()
    local db = BagSettings or {}

    -- Compare types instead of just filling in nils: a profile written by an
    -- older version can hold the right key with the wrong type, and handing
    -- that to the Settings API throws.
    for key, value in pairs(ns.defaults) do
        if type(db[key]) ~= type(value) then
            db[key] = value
        end
    end

    BagSettings, ns.db = db, db
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg)
    if event == "ADDON_LOADED" then
        if arg ~= ADDON then return end
        self:UnregisterEvent("ADDON_LOADED")

        LoadSettings()
        ns.InitBag()
        ns.InitTooltip()
        ns.InitOptions()

        C_CVar.SetCVar("combinedBags", "1")
        self:RegisterEvent("CVAR_UPDATE")

    elseif arg == "combinedBags" and not C_CVar.GetCVarBool("combinedBags") then
        -- The whole addon hangs off the combined bag frame, so keep it on.
        C_CVar.SetCVar("combinedBags", "1")
        print("|cff33ff99" .. ADDON .. "|r: " .. ns.L.combinedBagsForced)
    end
end)
