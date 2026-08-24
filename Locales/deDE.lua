if GetLocale() ~= "deDE" then return end

local _, ns = ...
local L = ns.L

-- Section headers
L.header_general      = "Allgemein"
L.header_general_desc = "Komfortoptionen für die kombinierte Tasche."
L.header_tooltip      = "Tooltip"
L.header_tooltip_desc = "Zusätzliche Informationen in Gegenstands-Tooltips."
L.header_bag          = "Tascheneinstellungen"
L.header_bag_desc     = "Legt fest, wie die Tasche ihre Plätze anordnet."

-- General
L.addReagentsBag      = "Materialtasche einfügen"
L.addReagentsBag_desc = "Zeigt die Materialtasche innerhalb der kombinierten Tasche an, statt in einem eigenen Fenster."
L.itemLevel           = "Gegenstandsstufe anzeigen"
L.itemLevel_desc      = "Zeigt die Gegenstandsstufe auf Waffen und Rüstung an."
L.itemLevelColor      = "Gegenstandsstufe einfärben"
L.itemLevelColor_desc = "Färbt die Gegenstandsstufe in der Qualitätsfarbe des Gegenstands."
L.itemLevelScale      = "Größe der Gegenstandsstufe"
L.itemLevelScale_desc = "Größe des Textes der Gegenstandsstufe."

-- Tooltip
L.itemCounts          = "Items Synchronisation"
L.itemCounts_desc     = "Listet im Tooltip alle Charaktere auf, die den Gegenstand besitzen, und wie viele. Die Werte werden aktualisiert, sobald sich die Taschen des jeweiligen Charakters ändern. Es werden nur stapelbare Gegenstände erfasst."

-- Bag settings
L.splitBags           = "Taschen trennen"
L.splitBags_desc      = "Jede Tasche beginnt in einer neuen Zeile, auch wenn in der vorherigen Zeile noch Platz frei ist."
L.columns             = "Spalten"
L.columns_desc        = "Maximale Anzahl an Gegenständen pro Zeile. Bei aktiviertem 'Taschen trennen' begrenzt eine schmalere Tasche die Breite."

-- Messages
L.combinedBagsForced  = "Getrennte Taschen werden nicht unterstützt, kombinierte Taschen bleiben aktiviert. Deaktiviere das AddOn, um getrennte Taschen zu verwenden."
