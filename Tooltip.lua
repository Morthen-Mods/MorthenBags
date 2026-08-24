local _, ns = ...

local LAST_BAG = Enum.BagIndex.ReagentBag -- backpack (0) through reagent bag (5)

local GetNumSlots = C_Container.GetContainerNumSlots
local GetSlotInfo = C_Container.GetContainerItemInfo

local db, me, realm
local others = {}
local tracked = {}

local function IsTracked(itemID)
    local known = tracked[itemID]

    if known == nil then
        -- 8 = max stack size, 14 = bind type
        local maxStack, _, _, _, _, _, bindType = select(8, C_Item.GetItemInfo(itemID))
        if not maxStack then return false end

        -- Soulbound items cannot reach another character, so they are never tracked.
        known = maxStack > 1
                and bindType ~= Enum.ItemBind.OnAcquire
                and bindType ~= Enum.ItemBind.Quest
        tracked[itemID] = known
    end

    return known
end

-- Recording -----------------------------------------------------------------

local function Store()
    local entry = InventorySync[me] or {}
    wipe(entry)
    entry.class = select(2, UnitClass("player"))

    for bag = 0, LAST_BAG do
        for slot = 1, GetNumSlots(bag) do
            local info = GetSlotInfo(bag, slot)
            if info and IsTracked(info.itemID) then
                entry[info.itemID] = (entry[info.itemID] or 0) + info.stackCount
            end
        end
    end

    InventorySync[me] = entry
end

-- Display -------------------------------------------------------------------

local function AddCharacter(tooltip, key, count)
    -- Realm names can contain a hyphen (Azjol-Nerub), character names cannot.
    local name, charRealm = strsplit("-", key, 2)
    local entry = InventorySync[key]
    local color = entry and RAID_CLASS_COLORS[entry.class]

    tooltip:AddDoubleLine(
            charRealm == realm and name or key, tostring(count),
            color and color.r or 1, color and color.g or 1, color and color.b or 1,
            1, 1, 1)
end

local function AddItemCounts(tooltip, data)
    if not db.itemCounts then return end
    if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then return end

    local itemID = data and data.id
    if not itemID or not IsTracked(itemID) then return end

    wipe(others)
    for key, entry in pairs(InventorySync) do
        if key ~= me and entry[itemID] then
            others[#others + 1] = key
        end
    end

    if #others == 0 then return end

    table.sort(others)
    tooltip:AddLine(" ")

    for i = 1, #others do
        AddCharacter(tooltip, others[i], InventorySync[others[i]][itemID])
    end
end

-- Setup ---------------------------------------------------------------------

function ns.InitTooltip()
    db = ns.db
    InventorySync = InventorySync or {}

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("PLAYER_LOGOUT")
    f:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_LOGIN" then
            realm = GetRealmName()
            me = UnitName("player") .. "-" .. realm
        end

        if event == "PLAYER_LOGOUT" then Store() end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AddItemCounts)
end
