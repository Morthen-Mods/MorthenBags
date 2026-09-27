local addonName, MB = ...

local lang = MB.lang
local handler = MB.DataHandler
local category, layout

local function Setting(key)
    local default = handler.GetDefault(key)
    local setting = Settings.RegisterAddOnSetting(category,
            addonName .. "_" .. key, key, handler.GetSettings(),
            type(default), lang[key], default)

    setting:SetValueChangedCallback(function(_, value) handler.SetSetting(key, value) end)

    return setting
end

local function AddHeader(key)
    local init = CreateSettingsListSectionHeaderInitializer(lang[key], lang[key .. "_desc"])
    layout:AddInitializer(init)
end

local function AddCheckbox(key)
    Settings.CreateCheckbox(category, Setting(key), lang[key .. "_desc"])
end

local function AddSlider(key, min, max, stepSize, suffix)
    local slider = Settings.CreateSliderOptions(min, max, stepSize)
    slider:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return value .. suffix
    end)

    Settings.CreateSlider(category, Setting(key), slider, lang[key .. "_desc"])
end

function MB.InitOptionsMenu()
    category, layout = Settings.RegisterVerticalLayoutCategory(addonName)

    AddHeader("header_general")
    AddCheckbox("addReagentsBag")
    if handler.IsForever() then
        AddCheckbox("addKeyring")
    end
    AddCheckbox("itemSync")

    if handler.IsRetail() then
        AddCheckbox("itemLevel")
        AddCheckbox("itemLevelColor")
        AddSlider("itemLevelScale", 50, 200, 5, "%")
    end

    AddHeader("header_bag")
    AddCheckbox("splitBags")
    AddSlider("columns", 10, 38, 1, "")

    Settings.RegisterAddOnCategory(category)
end