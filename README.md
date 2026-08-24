# 🎒 MorthenBags

A lightweight enhancement for the **default combined bag** in World of Warcraft Retail. It hooks the frame Blizzard already draws instead of replacing it, so you keep the native look and feel — no extra frames, no polling.

## ✨ Features

- **Reagent Bag Integration** — draws the reagent bag inside the combined bag, separated by a divider line, so you only have one bag window.
- **Columns** — set how many items per row (10–38) to control the bag's width.
- **Split Bags** — start every bag on a new row, even when the previous row still has space.
- **Item Level** — shows the item level on weapons and armor, optionally tinted with the item's quality color and scalable from 50% to 200%.
- **Item Sync** — item tooltips list every other character holding that item and how many, in class colors. Bags are recorded once at logout, so an alt appears after you have played it with the addon enabled. Stackable, non-soulbound items only, bags only (no bank).
- **Live Settings** — every option applies immediately, even with the bag open.

## ⚙️ Configuration

`Esc` → `Options` → `AddOns` → `MorthenBags`

Settings are saved per character. Recorded item counts are saved account-wide, so every character sees the same list.

## 🌍 Localization

Available in **English** and **German**. Untranslated strings fall back to English, so partial translations are always safe.

## 📋 Notes

- Built for **Retail 12.1**.
- The `combinedBags` CVar is kept enabled, since everything hangs off the combined bag frame. Disable the addon if you want separate bag windows.
