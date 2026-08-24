local _, ns = ...

-- Base language. Every other locale file overwrites only the keys it actually
-- translates and inherits the rest, so a partial translation is always safe and
-- no fallback logic is needed anywhere else.
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
    itemCounts_desc     = "List every character holding the item, and how many, on its tooltip. Alt counts are recorded whenever that character's bags change. Only stackable items are tracked.",

    -- Bag settings
    splitBags           = "Split Bags",
    splitBags_desc      = "Start every bag on a new row, even when the previous row still has space.",
    columns             = "Columns",
    columns_desc        = "Maximum number of items per row. With 'Split Bags' enabled, a bag narrower than this caps the width.",

    -- Messages
    combinedBagsForced  = "Separate bags are not supported, combined bags stay enabled. Disable the addon to use separate bags.",
}

-- A key that no locale defines shows up as its own name rather than erroring on
-- a nil string, which makes a gap obvious without breaking the options panel.
ns.L = setmetatable(L, { __index = function(_, key) return key end })
