-- FishingLog FR10.2 - integrated FishingHelper guide
-- UI and integration code by Dusk-92.
-- Data is vendored from FishingHelper by Homeopatix under the MIT License.
-- See FishingHelper_LICENSE.txt.

import "Turbine.UI"
import "Turbine.UI.Lotro"
import "Dusk.FishingLog.FL_HelperMap"

FL_Helper = FL_Helper or {}

local UI = {
    title = "Fishing guide",
    close = "Close",
    level = "Fishing level",
    count = "entries",
    categories = {
        rods = "Rods",
        masters = "Hobby Masters",
        quests = "Quests",
        normal = "Normal fish",
        rare = "Rare fish",
        wall = "Wall trophies",
        garbage = "Junk"
    }
}

if FL_Lang == "FR" then
    UI = {
        title = "Guide de pêche",
        close = "Fermer",
        level = "Niveau de pêche",
        count = "entrées",
        categories = {
            rods = "Cannes",
            masters = "Maîtres du hobby",
            quests = "Quêtes",
            normal = "Poissons normaux",
            rare = "Poissons rares",
            wall = "Poissons trophées",
            garbage = "Ordures"
        }
    }
elseif FL_Lang == "DE" then
    UI = {
        title = "Angelhilfe",
        close = "Schließen",
        level = "Angelfertigkeit",
        count = "Einträge",
        categories = {
            rods = "Angelruten",
            masters = "Hobby-Meister",
            quests = "Quests",
            normal = "Normale Fische",
            rare = "Seltene Fische",
            wall = "Wandtrophäen",
            garbage = "Abfall"
        }
    }
end

local DATA_GLOBALS = {
    "datasNormalFish", "datasRareFish", "datasGarbageFish", "datasMountableWallFish",
    "datasNormalLocation", "datasRareLocation", "datasGarbageFishLocation", "datasMountableWallFishLocation",
    "datasNormalFishNames", "datasRareFishLVL", "datasRareFishNames", "datasGarbageFishNames",
    "datasMountableWallFishLVL", "datasMountableWallFishNames",
    "DatasMasterNPC", "DatasMasterNPCExactPosition", "DatasMasterNPCLocation",
    "DatasMasterNPCCoordExact", "DatasMasterNPCCoord",
    "DatasFishingRod", "DatasFishingRodName", "DatasFishingRodLocation",
    "DatasFishingQuests", "DatasFishingQuestsLocation", "DatasFishingQuestsLocationMap",
    "DatasFishingQuestsCoord", "DatasFishingQuestsCoordExact"
}

local function safeArray(value)
    if type(value) == "table" then return value end
    return {}
end

local function loadData()
    if FL_Helper.data then return FL_Helper.data end

    if FL_Lang == "FR" then
        import "Dusk.FishingLog.FH_DATA_FR"
    elseif FL_Lang == "DE" then
        import "Dusk.FishingLog.FH_DATA_DE"
    else
        import "Dusk.FishingLog.FH_DATA_EN"
    end

    FL_Helper.data = {
        rods = {
            names = safeArray(DatasFishingRodName),
            locations = safeArray(DatasFishingRodLocation),
            icons = safeArray(DatasFishingRod)
        },
        masters = {
            names = safeArray(DatasMasterNPC),
            locations = safeArray(DatasMasterNPCLocation),
            details = safeArray(DatasMasterNPCExactPosition)
        },
        quests = {
            names = safeArray(DatasFishingQuests),
            locations = safeArray(DatasFishingQuestsLocation),
            details = safeArray(DatasFishingQuestsLocationMap),
            questTitles = FL_HelperMap and FL_HelperMap.quests or {}
        },
        normal = {
            names = safeArray(datasNormalFishNames),
            locations = safeArray(datasNormalLocation),
            icons = safeArray(datasNormalFish),
            ids = FL_HelperMap and FL_HelperMap.ids.normal or {}
        },
        rare = {
            names = safeArray(datasRareFishNames),
            locations = safeArray(datasRareLocation),
            levels = safeArray(datasRareFishLVL),
            icons = safeArray(datasRareFish),
            ids = FL_HelperMap and FL_HelperMap.ids.rare or {}
        },
        wall = {
            names = safeArray(datasMountableWallFishNames),
            locations = safeArray(datasMountableWallFishLocation),
            levels = safeArray(datasMountableWallFishLVL),
            icons = safeArray(datasMountableWallFish),
            ids = FL_HelperMap and FL_HelperMap.ids.wall or {}
        },
        garbage = {
            names = safeArray(datasGarbageFishNames),
            locations = safeArray(datasGarbageFishLocation),
            icons = safeArray(datasGarbageFish),
            ids = FL_HelperMap and FL_HelperMap.ids.garbage or {}
        }
    }

    if _G then
        for _,name in ipairs(DATA_GLOBALS) do _G[name] = nil end
    end

    return FL_Helper.data
end

local function cleanText(value)
    if value == nil then return "" end
    local s = tostring(value)
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    return s
end

local function buildRows(key)
    local data = loadData()
    local src = data[key] or {}
    local rows = {}
    local names = src.names or {}

    for i=1,#names do
        local name = cleanText(names[i])
        local location = cleanText(src.locations and src.locations[i])
        local detail = cleanText(src.details and src.details[i])
        local level = src.levels and tonumber(src.levels[i]) or nil
        local icon = src.icons and src.icons[i] or nil
        local id = src.ids and src.ids[i] or nil

        -- FishingLog owns canonical FR item names. FishingHelper contributes
        -- locations, levels and icons, but no longer overrides a known game name.
        if FL_Lang=="FR" and id and ID and ID[id] then
            name = ID[id].ln or ID[id].n or name
        end

        -- Same rule for quest titles: keep FishingHelper's displayed level, but
        -- source the French title from FishingLog's canonical quest dictionary.
        if FL_Lang=="FR" and src.questTitles and src.questTitles[i] then
            local prefix = name:match("^(%[%d+%])")
            local questKey = src.questTitles[i]
            local canonical = (FL_QuestFR and FL_QuestFR[questKey]) or questKey
            name = (prefix and (prefix.." ") or "")..canonical
        end

        if detail ~= "" and detail ~= location then
            if location ~= "" then
                location = location .. " — " .. detail
            else
                location = detail
            end
        end

        rows[#rows+1] = {
            name = name ~= "" and name or ("#" .. tostring(i)),
            location = location,
            level = level,
            icon = icon,
            id = id
        }
    end

    return rows
end

local gold = Turbine.UI.Color(0.90, 0.74, 0.22)
local white = Turbine.UI.Color(1, 1, 1)
local muted = Turbine.UI.Color(0.72, 0.72, 0.72)
local green = Turbine.UI.Color(0.35, 0.95, 0.35)
local dark = Turbine.UI.Color(0.06, 0.06, 0.06)

local function centerAndScale(window)
    local scale = FL_ToNumber(FL_Options and FL_Options.scale) or 1
    scale = math.max(0.5,math.min(2,scale))
    window:SetScale(scale)
    local sw,sh = Turbine.UI.Display.GetWidth(),Turbine.UI.Display.GetHeight()
    local ww,wh = window:GetWidth()*scale,window:GetHeight()*scale
    window:SetPosition(
        math.max(0,math.floor((sw-ww)/2)),
        math.max(0,math.floor((sh-wh)/2))
    )
end

FL_HelperWindow = class(Turbine.UI.Lotro.GoldWindow)

function FL_HelperWindow:Constructor()
    Turbine.UI.Lotro.GoldWindow.Constructor(self)

    self:SetSize(650, 535)
    self:SetText(UI.title)
    self:SetVisible(false)
    self:SetWantsKeyEvents(false)

    self.categoryButtons = {}
    local order = {"rods","masters","quests","normal","rare","wall","garbage"}

    for index,key in ipairs(order) do
        local button = Turbine.UI.Lotro.GoldButton()
        button:SetParent(self)
        button:SetSize(145, 24)

        local row = math.floor((index - 1) / 4)
        local col = (index - 1) % 4
        button:SetPosition(20 + col * 155, 42 + row * 32)
        button:SetText(UI.categories[key])

        local category = key
        button.Click = function()
            self:ShowCategory(category)
        end

        self.categoryButtons[key] = button
    end

    self.header = Turbine.UI.Label()
    self.header:SetParent(self)
    self.header:SetPosition(20, 112)
    self.header:SetSize(610, 24)
    self.header:SetFont(Turbine.UI.Lotro.Font.BookAntiquaBold18)
    self.header:SetForeColor(gold)
    self.header:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)

    self.closeButton = Turbine.UI.Lotro.GoldButton()
    self.closeButton:SetParent(self)
    self.closeButton:SetPosition(250, 495)
    self.closeButton:SetSize(150, 25)
    self.closeButton:SetText(UI.close)
    self.closeButton.Click = function()
        self:SetVisible(false)
    end

    self:ShowCategory("rare")
end

function FL_HelperWindow:ClearList()
    if self.listBox then
        self.listBox:SetParent(nil)
        self.listBox = nil
    end
    if self.scrollBar then
        self.scrollBar:SetParent(nil)
        self.scrollBar = nil
    end
end

function FL_HelperWindow:ShowCategory(key)
    self:ClearList()
    self.currentCategory = key

    local rows = buildRows(key)
    local fp = FL_ToFishingLevel and FL_ToFishingLevel(Totals and Totals.fp) or nil
    local levelText = fp ~= nil and tostring(fp) or "—"

    self.header:SetText(
        UI.categories[key] .. "  •  " .. UI.level .. " : " .. levelText ..
        "  •  " .. tostring(#rows) .. " " .. UI.count
    )

    self.listBox = Turbine.UI.ListBox()
    self.listBox:SetParent(self)
    self.listBox:SetPosition(20, 142)
    self.listBox:SetSize(595, 338)
    self.listBox:SetMouseVisible(true)

    for index,row in ipairs(rows) do
        local item = Turbine.UI.Control()
        item:SetSize(575, 54)
        if index % 2 == 0 then item:SetBackColor(dark) end

        local textX = 12
        if type(row.icon) == "number" then
            local icon = Turbine.UI.Control()
            icon:SetParent(item)
            icon:SetPosition(8, 10)
            icon:SetSize(32, 32)
            pcall(function() icon:SetBackground(row.icon) end)
            icon:SetBlendMode(Turbine.UI.BlendMode.Overlay)
            textX = 50
        end

        local name = Turbine.UI.Label()
        name:SetParent(item)
        name:SetPosition(textX, 5)
        name:SetSize(390, 22)
        name:SetFont(Turbine.UI.Lotro.Font.BookAntiquaBold18)
        name:SetForeColor(gold)
        name:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        name:SetText(row.name)

        if row.level then
            local level = Turbine.UI.Label()
            level:SetParent(item)
            level:SetPosition(445, 5)
            level:SetSize(120, 22)
            level:SetFont(Turbine.UI.Lotro.Font.Verdana14)
            level:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)
            local enough = fp ~= nil and fp >= row.level
            level:SetForeColor(enough and green or white)
            local prefix = FL_Lang == "FR" and "Niv. " or (FL_Lang == "DE" and "Stufe " or "Lvl ")
            level:SetText(prefix .. tostring(row.level) .. (enough and " ✓" or ""))
        end

        local location = Turbine.UI.Label()
        location:SetParent(item)
        location:SetPosition(textX, 28)
        location:SetSize(515 - textX, 20)
        location:SetFont(Turbine.UI.Lotro.Font.Verdana12)
        location:SetForeColor(muted)
        location:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        location:SetText(row.location ~= "" and row.location or " ")

        self.listBox:AddItem(item)
    end

    self.scrollBar = Turbine.UI.Lotro.ScrollBar()
    self.scrollBar:SetParent(self)
    self.scrollBar:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.scrollBar:SetPosition(620, 142)
    self.scrollBar:SetSize(10, 338)
    self.listBox:SetVerticalScrollBar(self.scrollBar)
end

function FL_HelperWindow:Refresh()
    self:ShowCategory(self.currentCategory or "rare")
end

FL_HelperWindow.VisibleChanged = function(sender,args)
    sender:SetWantsKeyEvents(sender:IsVisible())
end

FL_HelperWindow.KeyDown = function(sender,args)
    if args.Action == Turbine.UI.Lotro.Action.Escape and not (FL_Options and FL_Options.esc) then
        sender:SetVisible(false)
    end
end

function FL_HelperOpen(category)
    if not FL_helperWindow then
        FL_helperWindow = FL_HelperWindow()
    end
    if category then FL_helperWindow:ShowCategory(category) else FL_helperWindow:Refresh() end
    centerAndScale(FL_helperWindow)
    FL_helperWindow:SetVisible(true)
    FL_helperWindow:SetZOrder(3)
end

function FL_HelperRefresh()
    if FL_helperWindow and FL_helperWindow:IsVisible() then
        FL_helperWindow:Refresh()
    end
end
