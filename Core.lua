local ADDON, ns = ...

ns.defaults = {
    -- General
    addReagentsBag = false,
    itemLevel      = false,
    itemLevelColor = false,
    itemLevelScale = 125, -- percent

    -- Tooltip
    itemCounts     = true,

    -- Layout
    splitBags      = true,
    columns        = 10,
}

local function LoadSettings()
    local db = BagSettings or {}

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
        C_CVar.SetCVar("combinedBags", "1")
        print("|cff33ff99" .. ADDON .. "|r: " .. ns.L.combinedBagsForced)
    end
end)
