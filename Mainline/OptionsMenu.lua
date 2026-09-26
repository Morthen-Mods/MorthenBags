local _, MB = ...

function MB.InitOptions()
    local o = MB.Options
    o.Init()

    o.AddHeader("header_general")
    o.AddCheckbox("addReagentsBag")
    o.AddCheckbox("itemSync")
    o.AddCheckbox("itemLevel")
    o.AddCheckbox("itemLevelColor")
    o.AddSlider("itemLevelScale", 50, 200, 5, "%")

    o.AddHeader("header_bag")
    o.AddCheckbox("splitBags")
    o.AddSlider("columns", 10, 38, 1, "")

    o.Build()
end