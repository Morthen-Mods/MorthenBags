local _, MB = ...

local L = {
    -- Section headers
    header_general      = "General",
    header_general_desc = "Quality of life tweaks for the combined bag.",
    header_bag          = "Bag Settings",
    header_bag_desc     = "Control how the bag arranges its slots.",

    -- General
    addReagentsBag      = "Add Reagent Bag",
    addReagentsBag_desc = "Draw the reagent bag inside the combined bag instead of in its own window.",
    addKeyring          = "Add Keyring",
    addKeyring_desc     = "Draw the Keyring inside the combined bag instead of in its own window.",
    itemLevel           = "Show Item Level",
    itemLevel_desc      = "Show the item level on weapons and armor.",
    itemLevelColor      = "Color Item Level",
    itemLevelColor_desc = "Tint the item level with the item's quality color.",
    itemLevelScale      = "Item Level Scale",
    itemLevelScale_desc = "Size of the item level text.",

    -- Tooltip
    itemSync            = "Item Sync",
    itemSync_desc       = "List every other character holding the item, and how many, on its tooltip. Their bags are recorded when they log out. Only stackable items that are not soulbound are tracked.",
    itemSync_chars      = "Other Characters:",

    -- Bag settings
    splitBags           = "Split Bags",
    splitBags_desc      = "Start every bag on a new row, even when the previous row still has space.",
    columns             = "Columns",
    columns_desc        = "Maximum number of items per row. With 'Split Bags' enabled, a bag narrower than this caps the width.",

    -- Messages
    combinedBagsForced  = "Separate bags are not supported, combined bags stay enabled. Disable the addon to use separate bags.",
}

MB.lang = setmetatable(L, { __index = function(_, key) return key end })