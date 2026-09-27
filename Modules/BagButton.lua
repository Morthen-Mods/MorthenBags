local addonName, MB = ...
local BagButton = {}

local function GetSlotInfo(button)
    return C_Container.GetContainerItemInfo(button:GetBagID(), button:GetID())
end

function BagButton:OnShow()
    self:Update()
end

function BagButton:Update()
    local info = GetSlotInfo(self)

    self:SetItemButtonTexture(info ~= nil and info.iconFileID or nil)
    self:SetItemButtonCount(info ~= nil and info.stackCount or nil)
    self:SetItemButtonQuality(info ~= nil and info.quality or 0, info ~= nil and info.itemID or 0)
    self:UpdateNewItem(info ~= nil and info.quality or nil)
    self:UpdateSearchOverlay(info)
    self:UpdateLockedState(info)

    if info ~= nil then SetItemCraftingQualityOverlay(self, info.itemID)
    else ClearItemCraftingQualityOverlay(self) end
end

function BagButton:UpdateSearchOverlay(info)
    info = info or GetSlotInfo(self)
    self.searchOverlay:SetShown(info ~= nil and info.isFiltered or false)
end

function BagButton:UpdateLockedState(info)
    info = info or GetSlotInfo(self)
    SetItemButtonDesaturated(self, info and info.isLocked or false)
end

function MB.CreateBagButton(bag, slot)
    local f = CreateFrame("ItemButton",
    addonName .. bag .. "Slot" .. slot, ContainerFrameCombinedBags,"ContainerFrameItemButtonTemplate")
    Mixin(f, BagButton)

    local bg = f:CreateTexture(nil, "BACKGROUND", nil, -1)
    bg:SetAllPoints()
    bg:SetAtlas("bags-item-slot64", TextureKitConstants.IgnoreAtlasSize)

    f:SetScript("OnShow", f.OnShow)

    f:SetBagID(bag)
    f:SetID(slot)

    return f
end