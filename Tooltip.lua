local _, ns = ...

local GetNumSlots = C_Container.GetContainerNumSlots
local GetSlotInfo = C_Container.GetContainerItemInfo
local GetItemInfo = C_Item.GetItemInfo

local db, me, realm
local charData = {}

local function IsTrackable(itemID)
    local maxStack, _, _, _, _, _, bindType = select(8, GetItemInfo(itemID))

    return maxStack and maxStack > 1 and bindType ~= Enum.ItemBind.OnAcquire and bindType ~= Enum.ItemBind.Quest
end

local function LoadCharData()
    for key, table in pairs(InventorySync) do
        if key ~= me then
            charData[key] = table
        end
    end
end

local function SaveData()
    local entry = {}
    entry.class = select(2, UnitClass("player"))

    for bag = 0, Enum.BagIndex.ReagentBag do
        for slot = 1, GetNumSlots(bag) do
            local info = GetSlotInfo(bag, slot)
            if info and IsTrackable(info.itemID) then
                entry[info.itemID] = (entry[info.itemID] or 0) + info.stackCount
            end
        end
    end

    InventorySync[me] = entry
end

local function AddTooltipLine(tooltip, key, count)
    local name = strsplit("-", key, 2)
    local entry = InventorySync[key]
    local color = RAID_CLASS_COLORS[entry.class]
    if count == nil or count == 0 then return end

    tooltip:AddDoubleLine(name, count, color.r, color.g, color.b, 1, 1, 1)
end

local function AddItemCounts(tooltip, data)
    if not db.itemCounts then return end
    if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then return end

    local itemID = data.id
    if not IsTrackable(itemID) then return end

    tooltip:AddLine(" ")
    tooltip:AddLine(ns.L.itemCounts_chars)
    for key, table in pairs(charData) do
        AddTooltipLine(tooltip, key, charData[key][itemID])
    end
    tooltip:AddLine(" ")
end

function ns.InitTooltip()
    db = ns.db
    InventorySync = InventorySync or {}

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("BAG_UPDATE_DELAYED")
    f:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_LOGIN" then
            realm = GetRealmName()
            me = UnitName("player") .. "-" .. realm
            LoadCharData()
        end

        if event == "BAG_UPDATE_DELAYED" then SaveData() end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AddItemCounts)
end
