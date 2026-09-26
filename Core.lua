local addonName, MB = ...
local bagCVar = "combinedBags"

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(self, event, arg)
    if event == "ADDON_LOADED" and arg == addonName then
        MB.InitItemSync()
        MB.InitOptions()

        self:UnregisterEvent("ADDON_LOADED")
        self:RegisterEvent("CVAR_UPDATE")
    end

    if arg == bagCVar and not C_CVar.GetCVarBool(bagCVar) then
        C_CVar.SetCVar(bagCVar, "1")
        print("|cff33ff99" .. addonName .. "|r: " .. MB.lang.combinedBagsForced)
    end
end)