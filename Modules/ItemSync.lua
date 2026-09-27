local _, MB = ...

InventorySync = InventorySync or {}

local handler = MB.DataHandler
local type = Enum.ItemBind
local GetItemInfo = C_Item.GetItemInfo

local charData = {}
local me

local function IsTrackable(itemID)
    local maxStack, _, _, _, _, _, bindType = select(8, GetItemInfo(itemID))

    if bindType ~= nil and (bindType == type.OnAcquire or bindType == type.Quest) then
        return false
    end

    return maxStack ~= nil and maxStack > 1
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
    entry.name = UnitName("player")
    entry.class = select(2, UnitClass("player"))

    local GetNumSlots = C_Container.GetContainerNumSlots

    for bag = 0, Enum.BagIndex.ReagentBag do
        local slots = GetNumSlots(bag)
        if slots > 0 then
            for slot = 1, slots do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info ~= nil and IsTrackable(info.itemID) then
                    entry[info.itemID] = (entry[info.itemID] or 0) + info.stackCount
                end
            end
        end
    end

    InventorySync[me] = entry
end

local function AddTooltipLine(tooltip, key, count)
    local entry = InventorySync[key]
    local color = RAID_CLASS_COLORS[entry.class] or HIGHLIGHT_FONT_COLOR
    if count ~= nil and count > 0 then
        tooltip:AddDoubleLine(entry.name, count, color.r, color.g, color.b, 1, 1, 1)
    end
end

local function AddItemCount(tooltip, data)
    if not handler.GetSetting("itemSync") then return end
    if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then return end

    local itemID = data.id
    if not IsTrackable(itemID) then return end

    local added = false

    for key, table in pairs(charData) do
        local count = charData[key][itemID]
        if count ~= nil and not added then
            tooltip:AddLine(" ")
            tooltip:AddLine(MB.lang.itemSync_chars)
            added = true
        end
        if count ~= nil then
            AddTooltipLine(tooltip, key, charData[key][itemID])
        end
    end
    if added then tooltip:AddLine(" ") end
end

function MB.InitItemSync()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("BAG_UPDATE_DELAYED")
    f:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_LOGIN" then
            local realm = GetRealmName()
            me = UnitName("player") .. "-" .. realm
            LoadCharData()
        end

        if event == "BAG_UPDATE_DELAYED" then SaveData() end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AddItemCount)
end