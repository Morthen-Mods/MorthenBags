local _, MB = ...

function MB.InitOptions()
    local o = MB.Options
    o.Init()

    o.AddHeader("header_general")
    o.AddCheckbox("addReagentsBag")
    o.AddCheckbox("addKeyring")
    o.AddCheckbox("itemSync")

    o.AddHeader("header_bag")
    o.AddCheckbox("splitBags")
    o.AddSlider("columns", 10, 38, 1, "")

    o.Build()
end