local ADDON, ns = ...

local BUTTON_SIZE     = 37 -- Blizzard's container item button
local ITEM_GAP        = 4  -- space between two slots
local STEP            = BUTTON_SIZE + ITEM_GAP
local BORDER          = 7  -- space between the slots and the frame edge
local LAST_BAG        = 4  -- backpack (0) plus the four equipped bag slots
local REAGENT_BAG     = Enum.BagIndex.ReagentBag
local HEADER_HEIGHT   = 60 -- title bar and search row above the first slot
local CHROME_HEIGHT   = 90 -- everything above and below the slots
local CURRENCY_HEIGHT = 20
local DIVIDER_HEIGHT  = 12 -- row the reagent bag divider sits on

local GetNumSlots = C_Container.GetContainerNumSlots
local GetSlotInfo = C_Container.GetContainerItemInfo

local db, frame
local itemButtons = { [0] = {}, {}, {}, {}, {} }
local reagentButtons, reagentDivider
local levelShown = false

-- Item level ----------------------------------------------------------------

-- Reused so a full bag walk does not allocate one location table per slot.
local location = ItemLocation:CreateEmpty()

local function GetItemLevel(bag, slot, itemID)
    local classID = select(6, C_Item.GetItemInfoInstant(itemID))
    if classID ~= Enum.ItemClass.Weapon and classID ~= Enum.ItemClass.Armor then
        return nil
    end

    location:SetBagAndSlot(bag, slot)
    local level = C_Item.GetCurrentItemLevel(location)

    -- Tabards, shirts and cosmetics all sit at 1 and are only noise.
    return (level and level > 1) and level or nil
end

local function SetItemLevel(button, info)
    local level = info and db.itemLevel
            and GetItemLevel(button:GetBagID(), button:GetID(), info.itemID)

    if not level then
        if button.BCBItemLevel then button.BCBItemLevel:Hide() end
        return
    end

    local text = button.BCBItemLevel
    if not text then
        text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
        text:SetPoint("BOTTOMRIGHT", 0, 1)
        button.BCBItemLevel = text
    end

    text:SetScale(db.itemLevelScale / 100)
    text:SetText(level)

    if db.itemLevelColor then
        local r, g, b = C_Item.GetItemQualityColor(info.quality)
        text:SetTextColor(r, g, b)
    else
        text:SetTextColor(1, 1, 1)
    end

    text:Show()
    levelShown = true
end

local function RefreshItemLevels()
    -- Nothing to draw and nothing left over from before: skip the walk.
    if not (db.itemLevel or levelShown) then return end
    levelShown = false

    for _, button in frame:EnumerateValidItems() do
        SetItemLevel(button, GetSlotInfo(button:GetBagID(), button:GetID()))
    end
end

-- Reagent slots -------------------------------------------------------------

local function UpdateReagentSlot(button)
    local info = GetSlotInfo(REAGENT_BAG, button:GetID())

    if info then
        button:SetItemButtonTexture(info.iconFileID)
        button:SetItemButtonCount(info.stackCount)
        button:SetItemButtonQuality(info.quality, info.itemID)
        button:UpdateNewItem(info.quality)
        SetItemButtonDesaturated(button, info.isLocked)
        SetItemCraftingQualityOverlay(button, info.itemID)
        button.searchOverlay:SetShown(info.isFiltered)
    else
        local icon = button.icon or button.Icon
        if icon then icon:SetTexture(nil) end
        button:SetItemButtonCount(nil)
        button:SetItemButtonQuality(0, 0)
        button:UpdateNewItem()
        SetItemButtonDesaturated(button, false)
        ClearItemCraftingQualityOverlay(button)
        button.searchOverlay:Hide()
    end
end

local function UpdateReagentSlots()
    if not reagentButtons then return end

    for i = 1, #reagentButtons do
        local button = reagentButtons[i]
        if button:IsShown() then UpdateReagentSlot(button) end
    end
end

local function StartWatching(self)
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("ITEM_LOCK_CHANGED")
    self:RegisterEvent("INVENTORY_SEARCH_UPDATE")
    UpdateReagentSlots()
end

local function OnWatchedEvent(_, event, bag, slot)
    if event ~= "ITEM_LOCK_CHANGED" then
        UpdateReagentSlots()
    elseif bag == REAGENT_BAG and reagentButtons[slot] then
        local info = GetSlotInfo(REAGENT_BAG, slot)
        SetItemButtonDesaturated(reagentButtons[slot], info and info.isLocked)
    end
end

-- Blizzard drives its own slots from the container frame they belong to. These
-- are ours, so they share one listener instead of registering three events each.
local function CreateWatcher()
    -- Parented to the bag frame, so it only listens while the bag is open.
    local watcher = CreateFrame("Frame", nil, frame)
    watcher:SetScript("OnShow", StartWatching)
    watcher:SetScript("OnHide", watcher.UnregisterAllEvents)
    watcher:SetScript("OnEvent", OnWatchedEvent)

    -- The bag is already open the first time we get here, and a frame created
    -- inside a visible parent does not fire OnShow.
    StartWatching(watcher)
end

local function EnsureReagentSlots(count)
    if not reagentButtons then
        reagentButtons = {}
        CreateWatcher()
    end

    for i = #reagentButtons + 1, count do
        local button = CreateFrame("ItemButton", ADDON .. "ReagentSlot" .. i, frame,
                "ContainerFrameItemButtonTemplate")

        -- Matches the slot art Blizzard draws on its own bag buttons. Pinned to a
        -- negative sublevel so it is always behind the icon rather than wherever
        -- creation order happens to put it.
        local background = button:CreateTexture(nil, "BACKGROUND", nil, -1)
        background:SetAllPoints()
        background:SetAtlas("bags-item-slot64", TextureKitConstants.IgnoreAtlasSize)

        -- Silence the template's own event handling; we update these by hand.
        button:UnregisterAllEvents()
        button:SetScript("OnEvent", nil)
        button:SetScript("OnShow", nil)
        button:SetScript("OnHide", nil)

        button:SetBagID(REAGENT_BAG)
        button:SetID(i)

        reagentButtons[i] = button
    end
end

-- Layout --------------------------------------------------------------------

local columns, column, posX, posY

local function Place(button)
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", posX, posY)

    column = column + 1
    if column < columns then
        posX = posX + STEP
    else
        column, posX, posY = 0, BORDER, posY - STEP
    end
end

local function BreakRow()
    if column ~= 0 then
        column, posX, posY = 0, BORDER, posY - STEP
    end
end

-- Without a line above them the reagent slots read as one more row of the last
-- bag. It spans the slot area, centered in the row it reserves.
local function PlaceDivider()
    if not reagentDivider then
        reagentDivider = frame:CreateTexture(nil, "ARTWORK")
        reagentDivider:SetColorTexture(0.7, 0.7, 0.7, 0.5)
        reagentDivider:SetHeight(1)
    end

    local y = posY - (DIVIDER_HEIGHT / 2) + 2

    reagentDivider:ClearAllPoints()
    reagentDivider:SetPoint("TOPLEFT", BORDER, y)
    reagentDivider:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -BORDER, y)
    reagentDivider:Show()

    posY = posY - DIVIDER_HEIGHT
end

local function WidestBag(withReagents)
    local widest = 0
    for bag = 0, withReagents and REAGENT_BAG or LAST_BAG do
        local slots = GetNumSlots(bag)
        if slots > widest then widest = slots end
    end

    return widest
end

local function CountRows(withReagents)
    local rows = 0

    if db.splitBags then
        for bag = 0, LAST_BAG do
            rows = rows + math.ceil(GetNumSlots(bag) / columns)
        end
    else
        local slots = 0
        for bag = 0, LAST_BAG do
            slots = slots + GetNumSlots(bag)
        end
        rows = math.ceil(slots / columns)
    end

    -- The reagent bag always starts on a row of its own.
    if withReagents then
        rows = rows + math.ceil(GetNumSlots(REAGENT_BAG) / columns)
    end

    return rows
end

local function ApplyLayout()
    local reagentSlots = db.addReagentsBag and GetNumSlots(REAGENT_BAG) or 0
    local withReagents = reagentSlots > 0

    -- With split bags on, a bag narrower than the column count would pad every
    -- row it owns with dead space, so let the widest bag cap the frame.
    columns = db.columns
    if db.splitBags then
        local widest = WidestBag(withReagents)
        if widest > 0 and widest < columns then columns = widest end
    end

    local height = CountRows(withReagents) * STEP - ITEM_GAP + CHROME_HEIGHT
    if withReagents then
        height = height + DIVIDER_HEIGHT
    end
    if C_CurrencyInfo.GetBackpackCurrencyInfo(1) then
        height = height + CURRENCY_HEIGHT
    end

    frame:SetSize(columns * STEP - ITEM_GAP + BORDER * 2, height)

    -- Blizzard reuses and reshuffles its buttons, so re-index them by bag and
    -- slot before walking the bags in display order.
    for _, button in frame:EnumerateValidItems() do
        local slots = itemButtons[button:GetBagID()]
        if slots then slots[button:GetID()] = button end
    end

    column, posX, posY = 0, BORDER, -HEADER_HEIGHT

    for bag = 0, LAST_BAG do
        local slots = itemButtons[bag]
        for slot = 1, GetNumSlots(bag) do
            local button = slots[slot]
            if button then Place(button) end
        end

        if db.splitBags then BreakRow() end
    end

    if withReagents then
        EnsureReagentSlots(reagentSlots)
        BreakRow()
        PlaceDivider()
    elseif reagentDivider then
        reagentDivider:Hide()
    end

    for i = 1, reagentButtons and #reagentButtons or 0 do
        local button = reagentButtons[i]
        if i <= reagentSlots then
            Place(button)
            button:Show()
            UpdateReagentSlot(button)
        else
            button:Hide()
        end
    end

    if db.addReagentsBag then
        -- An unanchored frame is not drawn, which keeps Blizzard's reagent
        -- window out of the way without fighting its show/hide logic.
        ContainerFrame6:ClearAllPoints()
    elseif ContainerFrame6:GetNumPoints() == 0 then
        -- We unanchored it earlier, so hide it and let Blizzard place it again
        -- the next time the bags open.
        ContainerFrame6:Hide()
    end
end

-- Hooks ---------------------------------------------------------------------

local function KeepReagentFrameHidden(self)
    if db.addReagentsBag then self:ClearAllPoints() end
end

local function CenterSearchBox(self)
    local box = BagItemSearchBox
    if box then
        box:ClearAllPoints()
        box:SetPoint("TOP", self, "TOP", 0, -35)
    end
end

-- Re-run the layout after a setting changes, instead of waiting for the next
-- bag update to pick it up.
function ns.Refresh()
    if frame:IsShown() then
        ApplyLayout()
        RefreshItemLevels()
    end
end

function ns.InitBag()
    db = ns.db
    frame = ContainerFrameCombinedBags

    hooksecurefunc(frame, "UpdateItemLayout", ApplyLayout)
    hooksecurefunc(frame, "Update", RefreshItemLevels)
    hooksecurefunc(frame, "SetSearchBoxPoint", CenterSearchBox)
    hooksecurefunc(ContainerFrame6, "SetPoint", KeepReagentFrameHidden)
end
