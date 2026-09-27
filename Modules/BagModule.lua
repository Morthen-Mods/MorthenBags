local _, MB = ...

local bags = {}
local lang = MB.lang
local handler = MB.DataHandler
local bagFrame

local GetBagSlots = C_Container.GetContainerNumSlots
local GetSlotInfo = C_Container.GetContainerItemInfo

local buttonCache

-- Listener ----------------------------
-- Frame to trigger ItemButton updates
bags.CustomButtons = {
    [Enum.BagIndex.Keyring] = {},
    [Enum.BagIndex.ReagentBag] = {},
}

local bagListener = CreateFrame("Frame")
bagListener:RegisterEvent("ITEM_LOCK_CHANGED")
bagListener:RegisterEvent("BAG_UPDATE_DELAYED")
bagListener:RegisterEvent("INVENTORY_SEARCH_UPDATE")
bagListener:RegisterEvent("BAG_CONTAINER_UPDATE")

bagListener:SetScript("OnEvent", function(_, event, ...)
    if event == "BAG_CONTAINER_UPDATE" then
        bags.CacheBagButtons()
        return
    end

    if event == "ITEM_LOCK_CHANGED" then
        local bagIndex, slot = ...
        local bag = bags.CustomButtons[bagIndex]
        if bag == nil then return end

        local btn = bag[slot]
        if btn ~= nil then btn:UpdateLockedState() end
        return
    end

    for _, buttons in pairs(bags.CustomButtons) do
        for _, button in pairs(buttons) do
            if button:IsVisible() then
                if event == "INVENTORY_SEARCH_UPDATE" then button:UpdateSearchOverlay() end
                if event == "BAG_UPDATE_DELAYED" then button:Update() end
            end
        end
    end
end)

function bags.CacheBagButtons()
    if bagFrame == nil then return end

    buttonCache = {}
    for _, btn in bagFrame:EnumerateValidItems() do
        if btn ~= nil then
            if btn.ItemLevelComponent == nil then
                local iLvl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
                iLvl:SetPoint("BOTTOMRIGHT", btn, 0, 2)
                iLvl:SetTextColor(1, 1, 1, 1)
                btn.ItemLevelComponent = iLvl
            end

            local bagCache = buttonCache[btn:GetBagID()]
            if bagCache == nil then
                buttonCache[btn:GetBagID()] = {}
            end
            buttonCache[btn:GetBagID()][btn:GetID()] = btn
        end
    end
end

function bags.GenerateButtons(index)
    bags.CustomButtons[index] = {}

    for slot = 1, 40 do
        local btn = MB.CreateBagButton(index, slot)
        bags.CustomButtons[index][slot] = btn
    end
end

local itemLoc = ItemLocation:CreateEmpty()
local function GetItemLevelAndQuality(bag, slot)
    local info = GetSlotInfo(bag, slot)
    if info ~= nil then
        local classID = select(6, C_Item.GetItemInfoInstant(info.itemID))
        if classID ~= Enum.ItemClass.Weapon and classID ~= Enum.ItemClass.Armor then
            return nil, nil
        end

        itemLoc:SetBagAndSlot(bag, slot)
        local level = C_Item.GetCurrentItemLevel(itemLoc)

        return level, info.quality
    end
end

-- Layout ------------------------------------
local columns, column, posX, posY
local step = 41 -- buttonSize(37) + itemGap(4)
local borderPadding = 10
local dividerHeight = 16
local headerHeight = 60
local chromeHeight = 90 -- everything above and below the slots
local currencyHeight = 20

local function Place(button)
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", posX, posY)

    column = column + 1
    if column < columns then
        posX = posX + step
    else
        column, posX, posY = 0, borderPadding, posY - step
    end
end

local function BreakRow()
    if column ~= 0 then
        column, posX, posY = 0, borderPadding, posY - step
    end
end

local function PlaceDivider(title, divider)
    if title == nil or divider == nil then return end

    local y = posY - (dividerHeight / 2) + 8
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", borderPadding + 3, y)
    title:Show()

    divider:ClearAllPoints()
    divider:SetPoint("TOPLEFT", borderPadding + title:GetWidth() + 5, y - 6)
    divider:SetPoint("TOPRIGHT", bagFrame, "TOPRIGHT", -borderPadding - 6, y)
    divider:Show()

    posY = posY - dividerHeight
end

local function PlaceReagentsDivider()
    local title = bagFrame.ReagentsDividerTitle
    if title == nil then
        title = bagFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        bagFrame.ReagentsDividerTitle = title
    end
    title:SetText(lang.reagents)

    local divider = bagFrame.ReagentsDividerLine
    if divider == nil then
        divider = bagFrame:CreateTexture(nil, "ARTWORK")
        divider:SetColorTexture(0.7, 0.7, 0.7, 0.5)
        divider:SetHeight(1)
        bagFrame.ReagentsDividerLine = divider
    end

    PlaceDivider(title, divider)
end

local function HideDivider(withReagents, withKeyring)
    if not withReagents then
        local title = bagFrame.ReagentsDividerTitle
        local line = bagFrame.ReagentsDividerLine
        if title ~= nil then title:Hide() end
        if line ~= nil then line:Hide() end
    end

    if not withKeyring then
        local title = bagFrame.KeyringDividerTitle
        local line = bagFrame.KeyringDividerLine
        if title ~= nil then title:Hide() end
        if line ~= nil then line:Hide() end
    end
end

local function PlaceKeyringDivider()
    local title = bagFrame.KeyringDividerTitle
    if title == nil then
        title = bagFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        bagFrame.KeyringDividerTitle = title
    end
    title:SetText(lang.keyring)

    local divider = bagFrame.KeyringDividerLine
    if divider == nil then
        divider = bagFrame:CreateTexture(nil, "ARTWORK")
        divider:SetColorTexture(0.7, 0.7, 0.7, 0.5)
        divider:SetHeight(1)
        bagFrame.KeyringDividerLine = divider
    end

    PlaceDivider(title, divider)
end

local function WidestBag(withReagents)
    local widest = 0
    for bag = 0, withReagents and Enum.BagIndex.ReagentBag or 4 do
        local slots = GetBagSlots(bag)
        if slots > widest then widest = slots end
    end

    return widest
end

local function GetKeyringSlots()
    local index = Enum.BagIndex.Keyring
    local visibleSlots = 4
    for i = 5, GetBagSlots(index) do
        if GetSlotInfo(index, i) == nil then
            return visibleSlots
        end

        visibleSlots = i
    end
end

local function CountRows(withReagents, withKeyring)
    local rows = 0

    if handler.GetSetting("splitBags") then
        for bag = 0, 4 do
            rows = rows + math.ceil(GetBagSlots(bag) / columns)
        end
    else
        local slots = 0
        for bag = 0, 4 do
            slots = slots + GetBagSlots(bag)
        end

        rows = math.ceil(slots / columns)
    end

    if withReagents then
        rows = rows + math.ceil(GetBagSlots(Enum.BagIndex.ReagentBag) / columns)
    end

    if withKeyring then
        rows = rows + math.ceil(GetKeyringSlots() / columns)
    end

    return rows
end

local function ApplyLayout()
    local reagentSlots = handler.GetSetting("addReagentsBag") and GetBagSlots(Enum.BagIndex.ReagentBag) or 0
    local withReagents = reagentSlots > 0

    local keyringSlots = handler.GetSetting("addKeyring") and GetKeyringSlots() or 0
    local withKeyring = keyringSlots > 0

    columns = handler.GetSetting("columns")
    if handler.GetSetting("splitBags") then
        local widest = WidestBag(withReagents)
        if widest > 0 and widest < columns then columns = widest end
    end

    local height = CountRows(withReagents, withKeyring) * step - 4 + chromeHeight
    if withReagents then height = height + dividerHeight end
    if withKeyring then height = height + dividerHeight end
    if C_CurrencyInfo.GetBackpackCurrencyInfo(1) then
        height = height + currencyHeight
    end

    bagFrame:SetSize(columns * step - 4 + borderPadding * 2, height)

    -- Blizzards shuffles buttons around
    bags.CacheBagButtons()

    -- reposition bag buttons
    column, posX, posY = 0, borderPadding, -headerHeight

    for bag = 0, 4 do
        local slots = buttonCache[bag]
        for slot = 1, GetBagSlots(bag) do
            local btn = slots[slot]
            if btn ~= nil then Place(btn) end
        end

        if handler.GetSetting("splitBags") then BreakRow() end
    end

    -- Add Reagents Buttons
    if withReagents then
        BreakRow()
        PlaceReagentsDivider()
    end

    local reagButtons = bags.CustomButtons[Enum.BagIndex.ReagentBag]
    for i = 1, #reagButtons do
        local btn = reagButtons[i]
        if i <= reagentSlots then
            Place(btn)
            btn:Show()
        else
            btn:Hide()
        end
    end

    -- Add Keyring
    if withKeyring then
        BreakRow()
        PlaceKeyringDivider()
    end

    local keyringButtons = bags.CustomButtons[Enum.BagIndex.Keyring]
    for i = 1, #keyringButtons do
        local btn = keyringButtons[i]
        if i <= keyringSlots then
            Place(btn)
            btn:Show()
        else
            btn:Hide()
        end
    end

    -- Hide Divider
    HideDivider(withReagents, withKeyring)
end

local function CenterSearchBox(self)
    local box = BagItemSearchBox
    if box then
        box:ClearAllPoints()
        box:SetPoint("TOP", self, "TOP", 0, -35)
    end
end

local function RefreshItemLevels()
    local iLvlDisplay = handler.GetSetting("itemLevel")
    local iLvlColor = handler.GetSetting("itemLevelColor")
    local iLvlScale = handler.GetSetting("itemLevelScale")

    for bag = 0, 4 do
        local buttons = buttonCache[bag]
        for slot = 1, GetBagSlots(bag) do
            local btn = buttons[slot]
            if btn ~= nil and btn.ItemLevelComponent ~= nil then
                local itemLevel, quality = GetItemLevelAndQuality(bag, slot)
                local component = btn.ItemLevelComponent
                if itemLevel ~= nil and iLvlDisplay then
                    component:SetText(itemLevel)
                    component:Show()
                else
                    component:Hide()
                end

                if quality ~= nil and iLvlColor then
                    local r, g, b = C_Item.GetItemQualityColor(quality)
                    component:SetTextColor(r, g, b)
                else
                    component:SetTextColor(1, 1, 1)
                end

                component:SetScale(handler.GetSetting("itemLevelScale") / 100)
            end
        end
    end
end

function MB.InitBagLayout()
    bagFrame = ContainerFrameCombinedBags

    bags.GenerateButtons(Enum.BagIndex.ReagentBag)
    bags.GenerateButtons(Enum.BagIndex.Keyring)

    hooksecurefunc(bagFrame, "UpdateItemLayout", ApplyLayout)
    hooksecurefunc(bagFrame, "SetSearchBoxPoint", CenterSearchBox)

    if handler.IsRetail() then
        hooksecurefunc(bagFrame, "Update", RefreshItemLevels)
    end

    -- Keep Keyring hidden
    hooksecurefunc(ContainerFrame2, "SetPoint", function(self)
        if handler.GetSetting("addKeyring") then self:ClearAllPoints() end
    end)

    -- Keep Reagents bag hidden
    hooksecurefunc(ContainerFrame6, "SetPoint", function(self)
        if handler.GetSetting("addReagentsBag") then self:ClearAllPoints() end
    end)
end