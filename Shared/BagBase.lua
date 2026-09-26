local _, MB = ...

MB.Bags = {}
local lang = MB.lang
local handler = MB.DataHandler

local GetBagSlots = C_Container.GetContainerNumSlots
local GetSlotInfo = C_Container.GetContainerItemInfo

local buttonCache

-- Listener ----------------------------
-- Frame to trigger ItemButton updates
MB.CustomButtons = {
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
        MB.CacheBagButtons()
        return
    end

    if event == "ITEM_LOCK_CHANGED" then
        local bagIndex, slot = ...
        local bag = MB.CustomButtons[bagIndex]
        if bag == nil then return end

        local btn = bag[slot]
        if btn ~= nil then btn:UpdateLockedState() end
        return
    end

    for _, buttons in pairs(MB.CustomButtons) do
        for _, button in pairs(buttons) do
            if button:IsVisible() then
                if event == "INVENTORY_SEARCH_UPDATE" then button:UpdateSearchOverlay() end
                if event == "BAG_UPDATE_DELAYED" then button:Update() end
            end
        end
    end
end)

function MB.CacheBagButtons()
    local container = ContainerFrameCombinedBags
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

function MB.GenerateButtons(index)
    local slots = GetBagSlots(index)
    MB.CustomButtons[index] = {}

    for slot = 1, slots do
        local btn = MB.CreateBagButton(index, slot)
        MB.CustomButtons[index][slot] = btn
    end
end