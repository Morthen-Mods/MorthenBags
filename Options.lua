local ADDON, ns = ...

local category, layout, L

-- Every control takes its label from L[key] and its tooltip from L[key .. "_desc"],
-- so a setting is declared once here and worded once in the locale files.
local function AddSetting(key)
    local default = ns.defaults[key]
    local setting = Settings.RegisterAddOnSetting(category, ADDON .. "_" .. key, key,
            ns.db, type(default), L[key], default)

    setting:SetValueChangedCallback(function(_, value)
        ns.db[key] = value
        ns.Refresh()
    end)

    return setting
end

local function AddHeader(key)
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L[key], L[key .. "_desc"]))
end

local function AddCheckbox(key)
    Settings.CreateCheckbox(category, AddSetting(key), L[key .. "_desc"])
end

-- The suffix stays a literal: "%" reads the same in every language.
local function AddSlider(key, min, max, stepSize, suffix)
    local options = Settings.CreateSliderOptions(min, max, stepSize)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return value .. suffix
    end)

    Settings.CreateSlider(category, AddSetting(key), options, L[key .. "_desc"])
end

function ns.InitOptions()
    L = ns.L
    category, layout = Settings.RegisterVerticalLayoutCategory(ADDON)

    AddHeader("header_general")
    AddCheckbox("addReagentsBag")
    AddCheckbox("itemLevel")
    AddCheckbox("itemLevelColor")
    AddSlider("itemLevelScale", 50, 200, 5, "%")

    AddHeader("header_tooltip")
    AddCheckbox("itemCounts")

    AddHeader("header_bag")
    AddCheckbox("splitBags")
    AddSlider("columns", 10, 38, 1, "")

    Settings.RegisterAddOnCategory(category)
end
