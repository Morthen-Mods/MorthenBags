local _, ns = ...

local L = {
    -- Section headers
    header_general      = "General",
    header_general_desc = "Quality of life tweaks for the combined bag.",
    header_tooltip      = "Tooltip",
    header_tooltip_desc = "Extra information shown on item tooltips.",
    header_bag          = "Bag Settings",
    header_bag_desc     = "Control how the bag arranges its slots.",

    -- General
    addReagentsBag      = "Add Reagent Bag",
    addReagentsBag_desc = "Draw the reagent bag inside the combined bag instead of in its own window.",
    itemLevel           = "Show Item Level",
    itemLevel_desc      = "Show the item level on weapons and armor.",
    itemLevelColor      = "Color Item Level",
    itemLevelColor_desc = "Tint the item level with the item's quality color.",
    itemLevelScale      = "Item Level Scale",
    itemLevelScale_desc = "Size of the item level text.",

    -- Tooltip
    itemCounts          = "Item Sync",
    itemCounts_desc     = "List every other character holding the item, and how many, on its tooltip. Their bags are recorded when they log out. Only stackable items that are not soulbound are tracked.",

    -- Bag settings
    splitBags           = "Split Bags",
    splitBags_desc      = "Start every bag on a new row, even when the previous row still has space.",
    columns             = "Columns",
    columns_desc        = "Maximum number of items per row. With 'Split Bags' enabled, a bag narrower than this caps the width.",

    -- Messages
    combinedBagsForced  = "Separate bags are not supported, combined bags stay enabled. Disable the addon to use separate bags.",
}

ns.L = setmetatable(L, { __index = function(_, key) return key end })
