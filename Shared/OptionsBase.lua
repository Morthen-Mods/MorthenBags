local addonName, MB = ...

local options = {}
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

function options.Init()
    category, layout = Settings.RegisterVerticalLayoutCategory(addonName)
end

function options.Build()
    Settings.RegisterAddOnCategory(category)
end

function options.AddHeader(key)
    local init = CreateSettingsListSectionHeaderInitializer(lang[key], lang[key .. "_desc"])
    layout:AddInitializer(init)
end

function options.AddCheckbox(key)
    Settings.CreateCheckbox(category, Setting(key), lang[key .. "_desc"])
end

function options.AddSlider(key, min, max, stepSize, suffix)
    local slider = Settings.CreateSliderOptions(min, max, stepSize)
    slider:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return value .. suffix
    end)

    Settings.CreateSlider(category, Setting(key), slider, lang[key .. "_desc"])
end

MB.Options = options