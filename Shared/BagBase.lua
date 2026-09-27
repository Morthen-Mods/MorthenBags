local _, MB = ...

local bags = {}
local lang = MB.lang
local handler = MB.DataHandler
local bagFrame
local flavor

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
    local container = bagFrame
    if container == nil then return end

    buttonCache = {}

    for _, btn in container:EnumerateValidItems() do
        if btn ~= nil then
            if btn.ItemLevelComponent == nil then
                local iLvl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
                iLvl:SetPoint("BOTTOMRIGHT", btn, 0, 1)
                iLvl:SetTextColor(1, 1, 1, 1)
                btn.ItemLevelComponent = iLvl
            end

            buttonCache[btn:GetBagID()] = {}
            buttonCache[btn:GetBagID()][btn:GetID()] = btn
        end
    end
end

function bags.GenerateButtons(index)
    local slots = GetBagSlots(index)
    bags.CustomButtons[index] = {}

    for slot = 1, slots do
        local btn = MB.CreateBagButton(index, slot)
        bags.CustomButtons[index][slot] = btn
    end
end

-- Layout ------------------------------------
local columns, column, posX, posY
local step = 41 -- buttonSize(37) + itemGap(4)
local borderPadding = 7
local dividerHeight = 12

function MB.InitBagBase(version)
    bagFrame = ContainerFrameCombinedBags
    flavor = version
end

local function Place(button)
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT")

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

    local y = posY - (dividerHeight / 2) + 2
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", borderPadding + 3, y)
    title:Show()

    divider:ClearAllPoints()
    divider:SetPoint("TOPLEFT", borderPadding + title:GetWidth() + 3, y - 6)
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

local function PlaceKeyringDivider()
    local title = bagFrame.KeyringReagentsDividerTitle
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