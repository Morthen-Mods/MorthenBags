### 🌟 BetterCombinedBag

BetterCombinedBag is a simple and lightweight addon for World of Warcraft (Retail) that enhances the default combined backpack without replacing it. It gives you more control over your bag's layout and information through targeted customizations, while keeping the look and feel of the default Blizzard UI.

It hooks the frame Blizzard already draws instead of building its own bag, so there are no extra frames, no polling, and only three event registrations while the bag is open.

### ✨ Features

**Reagent Bag Integration**: Draws the reagent bag inside the combined backpack, so you only have one single, unified bag window, with a divider line marking where the reagent section starts.

**Flexible Column Layout**: Define the number of item columns (Columns) to customize the width of your bag.

**Split Bags**: Each bag starts on a new row, regardless of the space left in the previous one, for better visual organization.

**Item Level Display**: Shows the item level of weapons and armor directly on their icon, optionally colored by item quality and scaled to your liking.

**Character Item Counts**: Item tooltips list every character holding that item and how many, with names in their class color. Your own count is read live; alt counts are recorded whenever that character's bags change, so an alt shows up once you have played it with the addon enabled. Only stackable items are tracked, since gear is one-per-slot noise in an alt list. Bag contents only, bank not included.

Every setting applies immediately, even with the bag open.

### ⚙️ Configuration

All settings can be configured through the standard in-game addon options menu:

`Esc` > `Options` > `AddOns` > `BetterCombinedBag`

Settings are stored per character. Recorded item counts are stored account-wide, so every character sees the same list.

### 📋 Notes

The addon keeps the `combinedBags` CVar enabled, since everything it does hangs off the combined bag frame. Disable the addon if you want separate bag windows.

### 🌍 Localization

Available in **English** and **German**. Every user-facing string lives in `Locales/`, one file per language.

`enUS.lua` is the base table and is always loaded. Each other locale file bails out immediately unless it matches the client, then overrides only the keys it translates:

```lua
if GetLocale() ~= "frFR" then return end

local _, ns = ...
local L = ns.L

L.splitBags = "Séparer les sacs"
```

Anything a locale leaves out keeps its English wording, so a partial translation is always safe to ship. Adding a language means dropping in one file and listing it in the `.toc` after `enUS.lua` — no code changes.

Labels come from `L[key]` and tooltips from `L[key .. "_desc"]`, where `key` is the setting name. A key no locale defines renders as its own name instead of erroring, which makes a gap easy to spot.

### 🎯 Compatibility

Built for **Retail 12.1** (`## Interface: 120100`).
